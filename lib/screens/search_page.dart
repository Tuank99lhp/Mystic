import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:mystic/widgets/gradient_containers.dart';
import '../services/data_manager.dart';
import '../widgets/search_bar.dart';
import '../API/mystic.dart';
import '../widgets/song_bar.dart';

class SearchPage extends StatefulWidget {
  final String query;
  final bool fromHome;
  final bool autofocus;
  const SearchPage({
    super.key,
    required this.query,
    this.fromHome = false,
    this.autofocus = false,
  });

  @override
  _SearchPageState createState() => _SearchPageState();
}

List searchHistory = Hive.box('user').get('searchHistory', defaultValue: []);

class _SearchPageState extends State<SearchPage> {
  String query = '';
  bool status = false;
  final ValueNotifier<List<String>> topSearch = ValueNotifier<List<String>>(
    [],
  );
  bool fetched = false;
  bool alertShown = false;
  bool? fromHome;
  List search = Hive.box('settings').get(
    'search',
    defaultValue: [],
  ) as List;
  bool liveSearch =
      Hive.box('settings').get('liveSearch', defaultValue: true) as bool;

  final controller = TextEditingController();

  @override
  void initState() {
    controller.text = widget.query;
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  List _searchResult = [];

  Future<void> Search() async {
    final Query = query == '' ? widget.query : query;
    if (Query.isEmpty) {
      _searchResult = [];
      setState(() {});
      return;
    }

    if (!searchHistory.contains(Query)) {
      searchHistory.insert(0, Query);
      addOrUpdateData('user', 'searchHistory', searchHistory);
    }

    try {
      _searchResult = await fetchSongsList(Query);
    } catch (e) {
      debugPrint('Error while searching online songs: $e');
    }
    fetched = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    fromHome ??= widget.fromHome;
    if (!status) {
      status = true;
      fromHome! ? null : Search();
    }
    return GradientContainer(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: SearchBar(
                  isYt: false,
                  controller: controller,
                  liveSearch: liveSearch,
                  autofocus: widget.autofocus,
                  hintText: AppLocalizations.of(context)!.searchText,
                  body: (fromHome!)
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 100,
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Wrap(
                                  children: List<Widget>.generate(
                                    search.length,
                                    (int index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5.0,
                                        ),
                                        child: GestureDetector(
                                          child: Chip(
                                            label: Text(
                                              search[index].toString(),
                                            ),
                                            labelStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .color,
                                              fontWeight: FontWeight.normal,
                                            ),
                                            onDeleted: () {
                                              setState(() {
                                                search.removeAt(index);
                                                Hive.box('settings').put(
                                                  'search',
                                                  search,
                                                );
                                              });
                                            },
                                          ),
                                          onTap: () {
                                            setState(
                                              () {
                                                fetched = false;
                                                query = search[index]
                                                    .toString()
                                                    .trim();
                                                controller.text = query;
                                                status = false;
                                                fromHome = false;
                                              },
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : !fetched
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.only(
                                top: 100,
                              ),
                              physics: const BouncingScrollPhysics(),
                              child: ListView.builder(
                                shrinkWrap: true,
                                addAutomaticKeepAlives: false,
                                addRepaintBoundaries: false,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _searchResult.length,
                                itemBuilder: (BuildContext ctxt, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, bottom: 5),
                                    child: SongBar(
                                      _searchResult[index],
                                      true,
                                    ),
                                  );
                                },
                              )),
                  onSubmitted: (String submittedQuery) {
                    setState(
                      () {
                        fetched = false;
                        query = submittedQuery;
                        status = false;
                        fromHome = false;
                      },
                    );
                  },
                  onQueryCleared: () {
                    setState(() {
                      fromHome = true;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

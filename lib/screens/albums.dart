import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mystic/API/apis.dart';
import '../widgets/bouncy_sliver_scroll_view.dart';
import '../widgets/copy_clipboard.dart';
import '../widgets/empty_screen.dart';
import '../widgets/miniplayer.dart';

class AlbumSearchPage extends StatefulWidget {
  final String query;
  final String type;

  const AlbumSearchPage({
    super.key,
    required this.query,
    required this.type,
  });

  @override
  _AlbumSearchPageState createState() => _AlbumSearchPageState();
}

class _AlbumSearchPageState extends State<AlbumSearchPage> {
  int page = 1;
  bool loading = false;
  List<Map>? _searchedList;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !loading) {
        page += 1;
        _fetchData();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _fetchData() {
    loading = true;
    switch (widget.type) {
      case 'Playlists':
        MysticAPI()
            .fetchAlbums(
          searchQuery: widget.query,
          type: 'playlist',
          page: page,
        )
            .then((value) {
          final temp = _searchedList ?? [];
          temp.addAll(value);
          setState(() {
            _searchedList = temp;
            loading = false;
          });
        });
        break;
      case 'Albums':
        MysticAPI()
            .fetchAlbums(
          searchQuery: widget.query,
          type: 'album',
          page: page,
        )
            .then((value) {
          final temp = _searchedList ?? [];
          temp.addAll(value);
          setState(() {
            _searchedList = temp;
            loading = false;
          });
        });
        break;
      case 'Artists':
        MysticAPI()
            .fetchAlbums(
          searchQuery: widget.query,
          type: 'artist',
          page: page,
        )
            .then((value) {
          final temp = _searchedList ?? [];
          temp.addAll(value);
          setState(() {
            _searchedList = temp;
            loading = false;
          });
        });
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: _searchedList == null
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _searchedList!.isEmpty
                      ? emptyScreen(
                          context,
                          AppLocalizations.of(context)!.resultsNotFound,
                          20,
                        )
                      : BouncyImageSliverScrollView(
                          scrollController: _scrollController,
                          title: widget.type,
                          placeholderImage: widget.type == 'Artists'
                              ? 'assets/artist.png'
                              : 'assets/album.png',
                          sliverList: SliverList(
                            delegate: SliverChildListDelegate(
                              _searchedList!.map(
                                (Map entry) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 7),
                                    child: ListTile(
                                      title: Text(
                                        '${entry["title"]}',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      onLongPress: () {
                                        copyToClipboard(
                                          context: context,
                                          text: '${entry["title"]}',
                                        );
                                      },
                                      subtitle: entry['subtitle'] == ''
                                          ? null
                                          : Text(
                                              '${entry["subtitle"]}',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                      leading: Card(
                                        margin: EdgeInsets.zero,
                                        elevation: 8,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            widget.type == 'Artists'
                                                ? 50.0
                                                : 7.0,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          errorWidget: (context, _, __) =>
                                              Image(
                                            fit: BoxFit.cover,
                                            image: AssetImage(
                                              widget.type == 'Artists'
                                                  ? 'assets/artist.png'
                                                  : 'assets/album.png',
                                            ),
                                          ),
                                          imageUrl:
                                              '${entry["image"].replaceAll('http:', 'https:')}',
                                          placeholder: (context, url) => Image(
                                            fit: BoxFit.cover,
                                            image: AssetImage(
                                              widget.type == 'Artists'
                                                  ? 'assets/artist.png'
                                                  : 'assets/album.png',
                                            ),
                                          ),
                                        ),
                                      ),
                                      trailing:
                                          widget.type != 'Albums' ? null : null,
                                      onTap: () {},
                                    ),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ),
            ),
          ),
          MiniPlayer(),
        ],
      ),
    );
  }
}

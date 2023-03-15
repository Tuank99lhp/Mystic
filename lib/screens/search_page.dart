import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          style: TextStyle(
            color: Theme.of(context).iconTheme.color,
          ),
          AppLocalizations.of(context)!.search,
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: 100.0,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: TextField(
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search for songs,...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (query) {},
                ),
              ),
            ),
          ];
        },
        body: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: const Icon(Icons.search),
              title: Text('Suggestion $index'),
            );
          },
          itemCount: 50,
        ),
      ),
    );
  }
}

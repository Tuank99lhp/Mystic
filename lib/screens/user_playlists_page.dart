import 'package:flutter/material.dart';
import 'package:mystic/API/mystic.dart';
import '../widgets/song_bar.dart';

class UserPlaylistsPage extends StatefulWidget {
  @override
  State<UserPlaylistsPage> createState() => _UserPlaylistsPageState();
}

class _UserPlaylistsPageState extends State<UserPlaylistsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            contentPadding: const EdgeInsets.only(
              bottom: 10,
            ),
            leading: SongBar(
              activePlaylist['list'][index],
              false,
            ),
          );
        },
        itemCount: 50,
      ),
    );
  }
}

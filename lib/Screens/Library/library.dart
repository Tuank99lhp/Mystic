/*
 *  This file is part of Mystic (https://github.com/Sangwan5688/Mystic).
 * 
 * Mystic is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Mystic is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Mystic.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Copyright (c) 2021-2022, Ankit Sangwan
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mystic/Screens/Library/liked.dart';
import 'package:mystic/Screens/LocalMusic/downed_songs.dart';
import 'package:mystic/Screens/LocalMusic/downed_songs_desktop.dart';

import 'package:mystic/Screens/Settings/setting.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List sectionsToShow = Hive.box('settings').get(
    'sectionsToShow',
    defaultValue: ['Home', 'YouTube', 'Library', 'More'],
  ) as List;

  void callback() {
    sectionsToShow = Hive.box('settings').get(
      'sectionsToShow',
      defaultValue: ['Home', 'YouTube', 'Library', 'More'],
    ) as List;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //final double screenWidth = MediaQuery.of(context).size.width;
    //final bool rotated = MediaQuery.of(context).size.height < screenWidth;
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        AppBar(
          title: Text(
            AppLocalizations.of(context)!.more,
            style: TextStyle(
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        // LibraryTile(
        //   title: AppLocalizations.of(context)!.nowPlaying,
        //   icon: Icons.queue_music_rounded,
        //   onTap: () {
        //     Navigator.pushNamed(context, '/nowplaying');
        //   },
        // ),
        LibraryTile(
          title: AppLocalizations.of(context)!.lastSession,
          icon: Icons.history_rounded,
          onTap: () {
            Navigator.pushNamed(context, '/recent');
          },
        ),
        LibraryTile(
          title: AppLocalizations.of(context)!.favorites,
          icon: Icons.favorite_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LikedSongs(
                  playlistName: 'Favorite Songs',
                  showName: AppLocalizations.of(context)!.favSongs,
                ),
              ),
            );
          },
        ),
        if (!Platform.isIOS)
          LibraryTile(
            title: AppLocalizations.of(context)!.myMusic,
            icon: MdiIcons.folderMusic,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => (Platform.isWindows || Platform.isLinux)
                      ? const DownloadedSongsDesktop()
                      : const DownloadedSongs(
                          showPlaylists: true,
                        ),
                ),
              );
            },
          ),
        LibraryTile(
          title: AppLocalizations.of(context)!.downs,
          icon: Icons.download_done_rounded,
          onTap: () {
            Navigator.pushNamed(context, '/downloads');
          },
        ),
        LibraryTile(
          title: AppLocalizations.of(context)!.settings,
          icon: Icons.settings_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Placeholder(), // SettingPage(callback: callback),
              ),
            );
          },
        ),
        // LibraryTile(
        //   title: AppLocalizations.of(context)!.stats,
        //   icon: Icons.auto_graph_rounded,
        //   onTap: () {
        //     Navigator.pushNamed(context, '/stats');
        //   },
        // ),
      ],
    );
  }
}

class LibraryTile extends StatelessWidget {
  const LibraryTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).iconTheme.color,
        ),
      ),
      leading: Icon(
        icon,
        color: Theme.of(context).iconTheme.color,
      ),
      onTap: onTap,
    );
  }
}

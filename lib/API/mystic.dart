import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mystic/helpers/formatSong.dart';
import 'package:mystic/services/data_manager.dart';
import 'package:mystic/services/lyrics_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

List userLikedSongsList = Hive.box('user').get('likedSongs', defaultValue: []);
final youtube = YoutubeExplode();
final random = Random();
String lastFetchedLyrics = '';
final lyrics = ValueNotifier<String>('null');
final yt = YoutubeExplode();

Map activePlaylist = {
  'ytid': '',
  'title': 'No Playlist',
  'header_desc': '',
  'image': '',
  'list': [],
};

int id = 0;
Future<List> fetchSongList(String searchQuery) async {
  final List listYoutubeSearch = await youtube.search.search(searchQuery);
  final listSongbyQuery = [
    for (final song in listYoutubeSearch) {returnSongLayout(0, song)}
  ];
  return listSongbyQuery;
}

Future<dynamic> getSong(dynamic songId) async {
  final manifest = await youtube.videos.streamsClient.getManifest(songId);
  return manifest.audioOnly.withHighestBitrate().url.toString();
}

Future getSongDetails(dynamic songIndex, dynamic songId) async {
  final song = await youtube.videos.get(songId);
  return returnSongLayout(
    songIndex,
    song,
  );
}

Future getSongLyrics(String artist, String title) async {
  if (lastFetchedLyrics != '$artist - $title') {
    lyrics.value = 'null';
    final lyr = await Lyrics().getLyrics(artist: artist, track: title);
    lyrics.value = lyr;
    lastFetchedLyrics = '$artist - $title';
    return lyr;
  }

  return lyrics.value;
}

Future<List> getSearchSuggestions(String query) async {
  const baseUrl =
      'https://suggestqueries.google.com/complete/search?client=firefox&ds=yt&q=';
  final link = Uri.parse(baseUrl + query);
  try {
    final response = await http.get(
      link,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; rv:96.0) Gecko/20100101 Firefox/96.0'
      },
    );
    if (response.statusCode != 200) {
      return [];
    }
    final res = jsonDecode(response.body)[1] as List;
    return res;
  } catch (e) {
    debugPrint('Error in getSearchSuggestions: $e');
    return [];
  }
}

bool isSongAlreadyLiked(songIdToCheck) =>
    userLikedSongsList.any((song) => song['ytid'] == songIdToCheck);

Future<Map> getRandomSong() async {
  const playlistId = 'PLgzTt0k8mXzEk586ze4BjvDXR7c-TUSnx';
  final playlistSongs = await getSongsFromPlaylist(playlistId);

  return playlistSongs[random.nextInt(playlistSongs.length)];
}

Future<List> getSongsFromPlaylist(dynamic playlistId) async {
  final songList = await getData('cache', 'playlistSongs$playlistId') ?? [];

  if (songList.isEmpty) {
    await for (final song in yt.playlists.getVideos(playlistId)) {
      songList.add(returnSongLayout(songList.length, song));
    }

    addOrUpdateData('cache', 'playlistSongs$playlistId', songList);
  }

  return songList;
}

Future<void> updateLikeStatus(dynamic songId, bool add) async {
  if (add) {
    userLikedSongsList
        .add(await getSongDetails(userLikedSongsList.length, songId));
  } else {
    userLikedSongsList.removeWhere((song) => song['ytid'] == songId);
  }
  addOrUpdateData('user', 'likedSongs', userLikedSongsList);
}

Future<List> fetchSongsList(String searchQuery) async {
  final List list = await yt.search.search(searchQuery);
  final searchedList = [
    for (final s in list)
      returnSongLayout(
        0,
        s,
      )
  ];

  return searchedList;
}
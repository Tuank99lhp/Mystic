import 'dart:convert';
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mystic/helpers/formatSong.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final youtube = YoutubeExplode();
final random = Random();
String lastFetchedLyrics = '';
final lyrics = ValueNotifier<String>('null');

Future<List> fetchSongList(String searchQuery) async {
  final List listYoutubeSearch = await youtube.search.search(searchQuery);
  final List listSongbyQuery = [
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
    final _lyrics = await Lyrics().getLyrics(artist: artist, track: title);
    lyrics.value = _lyrics;
    lastFetchedLyrics = '$artist - $title';
    return _lyrics;
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

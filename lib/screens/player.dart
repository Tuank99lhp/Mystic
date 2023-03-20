import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mystic/API/mystic.dart';
import 'package:mystic/helpers/media_item.dart';
import 'package:mystic/helpers/mediaitem_converter.dart';
import 'package:mystic/screens/more_page.dart';
import 'package:mystic/services/audio_manager.dart';
import 'package:mystic/services/download.dart';
import 'package:mystic/style/app_themes.dart';
import 'package:mystic/widgets/download_button.dart';
import 'package:mystic/widgets/favorite_button.dart';
import 'package:mystic/widgets/marque.dart';
import 'package:mystic/widgets/song_bar.dart';
import 'package:mystic/widgets/spinner.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';

class AudioApp extends StatefulWidget {
  const AudioApp({super.key});

  @override
  AudioAppState createState() => AudioAppState();
}

@override
class AudioAppState extends State<AudioApp> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: size.height * 0.09,
        title: Text(
          AppLocalizations.of(context)!.nowPlaying,
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: IconButton(
            focusColor: Colors.transparent,
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: Icon(
              FluentIcons.chevron_down_20_regular,
              color: colorScheme.primary,
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<SequenceState?>(
          stream: audioPlayer.sequenceStateStream,
          builder: (context, snapshot) {
            final state = snapshot.data;
            if (state?.sequence.isEmpty ?? true) {
              return const SizedBox();
            }
            final metadata = state!.currentSource!.tag;
            final songLikeStatus = ValueNotifier<bool>(
              isSongAlreadyLiked(metadata.extras['ytid']),
            );
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (metadata.extras['localSongId'] is int)
                  QueryArtworkWidget(
                    id: metadata.extras['localSongId'] as int,
                    type: ArtworkType.AUDIO,
                    artworkBorder: BorderRadius.circular(8),
                    artworkQuality: FilterQuality.high,
                    quality: 100,
                    artworkWidth: size.width - 100,
                    artworkHeight: size.width - 100,
                    nullArtworkWidget: Container(
                      width: size.width - 100,
                      height: size.width - 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(30, 255, 255, 255),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            FluentIcons.music_note_1_24_regular,
                            size: size.width / 8,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                    keepOldArtwork: true,
                  )
                else
                  SizedBox(
                    width: size.width - 100,
                    height: size.width - 100,
                    child: CachedNetworkImage(
                      imageUrl: metadata.artUri.toString(),
                      imageBuilder: (context, imageProvider) => DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => const Spinner(),
                      errorWidget: (context, url, error) => DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromARGB(30, 255, 255, 255),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              FluentIcons.music_note_1_24_regular,
                              size: size.width / 8,
                              color: colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                    top: size.height * 0.04,
                    bottom: size.height * 0.01,
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        metadata!.title
                            .toString()
                            .split(' (')[0]
                            .split('|')[0]
                            .trim(),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.height * 0.035,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${metadata!.artist}',
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: size.height * 0.015,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  child: _buildPlayer(
                    size,
                    songLikeStatus,
                    metadata.extras['ytid'],
                    metadata,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlayer(
    Size size,
    ValueNotifier<bool> songLikeStatus,
    dynamic ytid,
    dynamic metadata,
  ) =>
      Container(
        padding: EdgeInsets.only(
          top: size.height * 0.01,
          left: 16,
          right: 16,
          bottom: size.height * 0.03,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<PositionData>(
              stream: positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (positionData != null)
                      Slider(
                        activeColor: colorScheme.primary,
                        inactiveColor: Colors.green[50],
                        value: positionData.position.inMilliseconds.toDouble(),
                        onChanged: (double? value) {
                          setState(() {
                            audioPlayer.seek(
                              Duration(
                                milliseconds: value!.round(),
                              ),
                            );
                            value = value;
                          });
                        },
                        max: positionData.duration.inMilliseconds.toDouble(),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (positionData != null)
                          Text(
                            positionData.position
                                .toString()
                                .split('.')
                                .first
                                .replaceFirst('0:0', '0'),
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        if (positionData != null)
                          Text(
                            positionData.duration
                                .toString()
                                .split('.')
                                .first
                                .replaceAll('0:', ''),
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).hintColor,
                            ),
                          )
                      ],
                    )
                  ],
                );
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: size.height * 0.03),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        if (metadata.extras['ytid'].toString().isNotEmpty)
                          Column(
                            children: [
                              IconButton(
                                color: colorScheme.primary,
                                icon: const Icon(
                                  FluentIcons.arrow_download_24_regular,
                                ),
                                onPressed: () => downloadSong(
                                  context,
                                  mediaItemToMap(metadata as MediaItem),
                                ),
                              ),
                              ValueListenableBuilder<bool>(
                                valueListenable: muteNotifier,
                                builder: (_, value, __) {
                                  return IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      FluentIcons.speaker_mute_24_filled,
                                      color: value
                                          ? colorScheme.primary
                                          : Theme.of(context).hintColor,
                                    ),
                                    iconSize: 20,
                                    onPressed: mute,
                                    splashColor: Colors.transparent,
                                  );
                                },
                              ),
                            ],
                          ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            FluentIcons.arrow_shuffle_24_filled,
                            color: shuffleNotifier.value
                                ? colorScheme.primary
                                : Theme.of(context).hintColor,
                          ),
                          iconSize: 20,
                          onPressed: changeShuffleStatus,
                          splashColor: Colors.transparent,
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            FluentIcons.previous_24_filled,
                            color: hasPrevious
                                ? Theme.of(context).hintColor
                                : Colors.grey,
                          ),
                          iconSize: 40,
                          onPressed: () async => {
                            await playPrevious(),
                          },
                          splashColor: Colors.transparent,
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: StreamBuilder<PlayerState>(
                            stream: audioPlayer.playerStateStream,
                            builder: (context, snapshot) {
                              final playerState = snapshot.data;
                              final processingState =
                                  playerState?.processingState;
                              final playing = playerState?.playing;
                              if (processingState == ProcessingState.loading ||
                                  processingState ==
                                      ProcessingState.buffering) {
                                return Container(
                                  margin: const EdgeInsets.all(8),
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).hintColor,
                                    ),
                                  ),
                                );
                              } else if (playing != true) {
                                return IconButton(
                                  icon: Icon(
                                    FluentIcons.play_12_filled,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  iconSize: 40,
                                  onPressed: audioPlayer.play,
                                  splashColor: Colors.transparent,
                                );
                              } else if (processingState !=
                                  ProcessingState.completed) {
                                return IconButton(
                                  icon: Icon(
                                    FluentIcons.pause_12_filled,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  iconSize: 40,
                                  onPressed: audioPlayer.pause,
                                  splashColor: Colors.transparent,
                                );
                              } else {
                                return IconButton(
                                  icon: Icon(
                                    FluentIcons.replay_20_filled,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  iconSize: 30,
                                  onPressed: () => audioPlayer.seek(
                                    Duration.zero,
                                    index: audioPlayer.effectiveIndices!.first,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            FluentIcons.next_24_filled,
                            color: hasNext
                                ? Theme.of(context).hintColor
                                : Colors.grey,
                          ),
                          iconSize: 40,
                          onPressed: () async => {
                            await playNext(),
                          },
                          splashColor: Colors.transparent,
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            FluentIcons.arrow_repeat_1_24_filled,
                            color: repeatNotifier.value
                                ? colorScheme.primary
                                : Theme.of(context).hintColor,
                          ),
                          iconSize: 20,
                          onPressed: changeLoopStatus,
                          splashColor: Colors.transparent,
                        ),
                        if (metadata.extras['ytid'].toString().isNotEmpty)
                          Column(
                            children: [
                              ValueListenableBuilder<bool>(
                                valueListenable: songLikeStatus,
                                builder: (_, value, __) {
                                  if (value == true) {
                                    return IconButton(
                                      color: colorScheme.primary,
                                      icon: const Icon(
                                        FluentIcons.star_24_filled,
                                      ),
                                      iconSize: 20,
                                      splashColor: Colors.transparent,
                                      onPressed: () => {
                                        updateLikeStatus(ytid, false),
                                        songLikeStatus.value = false
                                      },
                                    );
                                  } else {
                                    return IconButton(
                                      color: Theme.of(context).hintColor,
                                      icon: const Icon(
                                        FluentIcons.star_24_regular,
                                      ),
                                      iconSize: 20,
                                      splashColor: Colors.transparent,
                                      onPressed: () => {
                                        updateLikeStatus(ytid, true),
                                        songLikeStatus.value = true
                                      },
                                    );
                                  }
                                },
                              ),
                              ValueListenableBuilder<bool>(
                                valueListenable: playNextSongAutomatically,
                                builder: (_, value, __) {
                                  return IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      value
                                          ? FluentIcons
                                              .music_note_2_play_20_filled
                                          : FluentIcons
                                              .music_note_2_play_20_regular,
                                      color: value
                                          ? colorScheme.primary
                                          : Theme.of(context).hintColor,
                                    ),
                                    iconSize: 20,
                                    splashColor: Colors.transparent,
                                    onPressed: changeAutoPlayNextStatus,
                                  );
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  if (metadata.extras['ytid'].toString().isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: size.height * 0.047),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Builder(
                            builder: (context) {
                              return TextButton(
                                onPressed: () {
                                  showBottomSheet(
                                    context: context,
                                    builder: (context) => Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(18),
                                          topRight: Radius.circular(18),
                                        ),
                                      ),
                                      height: size.height / 2.14,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(
                                                top: size.height * 0.012,
                                              ),
                                              child: Row(
                                                children: <Widget>[
                                                  IconButton(
                                                    icon: Icon(
                                                      FluentIcons
                                                          .arrow_between_down_24_filled,
                                                      color:
                                                          colorScheme.primary,
                                                      size: 20,
                                                    ),
                                                    onPressed: () => {
                                                      Navigator.pop(context)
                                                    },
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        right: 42,
                                                        bottom: 42,
                                                      ),
                                                      child: Center(
                                                        child: MarqueeWidget(
                                                          child: Text(
                                                            activePlaylist[
                                                                'title'],
                                                            style: TextStyle(
                                                              color: colorScheme
                                                                  .primary,
                                                              fontSize: 30,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              addAutomaticKeepAlives: false,
                                              addRepaintBoundaries: false,
                                              itemCount:
                                                  activePlaylist['list'].length,
                                              itemBuilder: (
                                                BuildContext context,
                                                int index,
                                              ) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    top: 5,
                                                    bottom: 5,
                                                  ),
                                                  child: SongBar(
                                                    activePlaylist['list']
                                                        [index],
                                                    false,
                                                  ),
                                                );
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.playlist,
                                ),
                              );
                            },
                          ),
                          const Text(' | '),
                          Builder(
                            builder: (context) {
                              return TextButton(
                                onPressed: () {
                                  getSongLyrics(
                                    metadata.artist.toString(),
                                    metadata.title.toString(),
                                  );

                                  showBottomSheet(
                                    context: context,
                                    builder: (context) => Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(18),
                                          topRight: Radius.circular(18),
                                        ),
                                      ),
                                      height: size.height / 2.14,
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(
                                              top: size.height * 0.012,
                                            ),
                                            child: Row(
                                              children: <Widget>[
                                                IconButton(
                                                  icon: Icon(
                                                    FluentIcons
                                                        .arrow_between_down_24_filled,
                                                    color: colorScheme.primary,
                                                    size: 20,
                                                  ),
                                                  onPressed: () =>
                                                      {Navigator.pop(context)},
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      right: 42,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!
                                                            .lyrics,
                                                        style: TextStyle(
                                                          color: colorScheme
                                                              .primary,
                                                          fontSize: 30,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          ValueListenableBuilder<String>(
                                            valueListenable: lyrics,
                                            builder: (_, value, __) {
                                              if (value != 'null' &&
                                                  value != 'not found') {
                                                return Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    child: Center(
                                                      child:
                                                          SingleChildScrollView(
                                                        child: Text(
                                                          value,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              } else if (value == 'null') {
                                                return const SizedBox(
                                                  child: Spinner(),
                                                );
                                              } else {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    top: 120,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      AppLocalizations.of(
                                                        context,
                                                      )!
                                                          .lyricsNotAvailable,
                                                      style: const TextStyle(
                                                        fontSize: 25,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.lyrics,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
}

class QueueState {
  const QueueState(
    this.queue,
    this.queueIndex,
    this.shuffleIndices,
    this.repeatMode,
  );
  static const QueueState empty =
      QueueState([], 0, [], AudioServiceRepeatMode.none);

  final List<MediaItem> queue;
  final int? queueIndex;
  final List<int>? shuffleIndices;
  final AudioServiceRepeatMode repeatMode;

  bool get hasPrevious =>
      repeatMode != AudioServiceRepeatMode.none || (queueIndex ?? 0) > 0;
  bool get hasNext =>
      repeatMode != AudioServiceRepeatMode.none ||
      (queueIndex ?? 0) + 1 < queue.length;

  List<int> get indices =>
      shuffleIndices ?? List.generate(queue.length, (i) => i);
}

class ControlButtons extends StatelessWidget {
  const ControlButtons(
    this.audioHandler, {
    super.key,
    this.shuffle = false,
    this.miniplayer = false,
    this.buttons = const ['Previous', 'Play/Pause', 'Next'],
    this.dominantColor,
  });
  final AudioPlayerHandler audioHandler;
  final bool shuffle;
  final bool miniplayer;
  final List buttons;
  final Color? dominantColor;

  @override
  Widget build(BuildContext context) {
    final mediaItem = audioHandler.mediaItem.value!;
    final online = mediaItem.extras!['url'].toString().startsWith('http');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: buttons.map((e) {
        switch (e) {
          case 'Like':
            return !online
                ? const SizedBox()
                : FavoriteButton(
                    mediaItem: mediaItem,
                    size: 22.0,
                  );
          case 'Previous':
            return StreamBuilder<QueueState>(
              stream: audioHandler.queueState,
              builder: (context, snapshot) {
                final queueState = snapshot.data;
                return IconButton(
                  icon: const Icon(Icons.skip_previous_rounded),
                  iconSize: miniplayer ? 24.0 : 45.0,
                  tooltip: AppLocalizations.of(context)!.skipPrevious,
                  color: dominantColor ?? Theme.of(context).iconTheme.color,
                  onPressed: queueState?.hasPrevious ?? true
                      ? audioHandler.skipToPrevious
                      : null,
                );
              },
            );
          case 'Play/Pause':
            return SizedBox(
              height: miniplayer ? 40.0 : 65.0,
              width: miniplayer ? 40.0 : 65.0,
              child: StreamBuilder<PlaybackState>(
                stream: audioHandler.playbackState,
                builder: (context, snapshot) {
                  final playbackState = snapshot.data;
                  final processingState = playbackState?.processingState;
                  final playing = playbackState?.playing ?? true;
                  return Stack(
                    children: [
                      if (processingState == AudioProcessingState.loading ||
                          processingState == AudioProcessingState.buffering)
                        Center(
                          child: SizedBox(
                            height: miniplayer ? 40.0 : 65.0,
                            width: miniplayer ? 40.0 : 65.0,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).iconTheme.color!,
                              ),
                            ),
                          ),
                        ),
                      if (miniplayer)
                        Center(
                          child: playing
                              ? IconButton(
                                  tooltip: AppLocalizations.of(context)!.pause,
                                  onPressed: audioHandler.pause,
                                  icon: const Icon(
                                    Icons.pause_rounded,
                                  ),
                                  color: Theme.of(context).iconTheme.color,
                                )
                              : IconButton(
                                  tooltip: AppLocalizations.of(context)!.play,
                                  onPressed: audioHandler.play,
                                  icon: const Icon(
                                    Icons.play_arrow_rounded,
                                  ),
                                  color: Theme.of(context).iconTheme.color,
                                ),
                        )
                      else
                        Center(
                          child: SizedBox(
                            height: 59,
                            width: 59,
                            child: Center(
                              child: playing
                                  ? FloatingActionButton(
                                      elevation: 10,
                                      tooltip:
                                          AppLocalizations.of(context)!.pause,
                                      backgroundColor: Colors.white,
                                      onPressed: audioHandler.pause,
                                      child: const Icon(
                                        Icons.pause_rounded,
                                        size: 40.0,
                                        color: Colors.black,
                                      ),
                                    )
                                  : FloatingActionButton(
                                      elevation: 10,
                                      tooltip:
                                          AppLocalizations.of(context)!.play,
                                      backgroundColor: Colors.white,
                                      onPressed: audioHandler.play,
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        size: 40.0,
                                        color: Colors.black,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          case 'Next':
            return StreamBuilder<QueueState>(
              stream: audioHandler.queueState,
              builder: (context, snapshot) {
                final queueState = snapshot.data;
                return IconButton(
                  icon: const Icon(Icons.skip_next_rounded),
                  iconSize: miniplayer ? 24.0 : 45.0,
                  tooltip: AppLocalizations.of(context)!.skipNext,
                  color: dominantColor ?? Theme.of(context).iconTheme.color,
                  onPressed: queueState?.hasNext ?? true
                      ? audioHandler.skipToNext
                      : null,
                );
              },
            );
          case 'Download':
            return !online
                ? const SizedBox()
                : DownloadButton(
                    size: 20.0,
                    icon: 'download',
                    data: MediaItemConverter.mediaItemToMap(mediaItem),
                  );
          default:
            break;
        }
        return const SizedBox();
      }).toList(),
    );
  }
}

abstract class AudioPlayerHandler implements AudioHandler {
  Stream<QueueState> get queueState;
  Future<void> moveQueueItem(int currentIndex, int newIndex);
  ValueStream<double> get volume;
  Future<void> setVolume(double volume);
  ValueStream<double> get speed;
}

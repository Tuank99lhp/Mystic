import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import '../API/mystic.dart';
import '../services/audio_manager.dart';
import '../services/download.dart';
import '../style/app_themes.dart';

class SongBar extends StatelessWidget {
  SongBar(this.song, this.clearPlaylist, {super.key});
  final ValueNotifier<bool> _isLiked = ValueNotifier<bool>(false);
  late final dynamic song;
  late final bool clearPlaylist;
  late final songLikeStatus =
      ValueNotifier<bool>(isSongAlreadyLiked(song['ytid']));

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          playSong(song);
          if (activePlaylist.isNotEmpty && clearPlaylist) {
            activePlaylist = {
              'ytid': '',
              'title': 'No Playlist',
              'header_desc': '',
              'image': '',
              'list': [],
            };
            id = 0;
          }
        },
        splashColor: colorScheme.primary.withOpacity(0.4),
        hoverColor: colorScheme.primary.withOpacity(0.4),
        focusColor: colorScheme.primary.withOpacity(0.4),
        highlightColor: colorScheme.primary.withOpacity(0.4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            CachedNetworkImage(
              width: 60,
              height: 60,
              imageUrl: song['lowResImage'].toString(),
              imageBuilder: (context, imageProvider) => DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: imageProvider,
                    centerSlice: const Rect.fromLTRB(1, 1, 1, 1),
                  ),
                ),
              ),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 30,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 15),
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        final text = song['title']
                            .toString()
                            .split('(')[0]
                            .replaceAll('&quot;', '"')
                            .replaceAll('&amp;', '&');
                        final textSpan = TextSpan(
                          text: text,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                        final textPainter = TextPainter(
                            text: textSpan,
                            maxLines: 1,
                            textDirection: TextDirection.ltr);
                        textPainter.layout(maxWidth: constraints.maxWidth);
                        final isOverflow = textPainter.didExceedMaxLines;
                        return isOverflow
                            ? Marquee(
                                text: text,
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                scrollAxis: Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                blankSpace: 20.0,
                                velocity: 50.0,
                                startPadding: 10.0,
                                accelerationDuration:
                                    const Duration(seconds: 1),
                                accelerationCurve: Curves.linear,
                                decelerationDuration:
                                    const Duration(milliseconds: 500),
                                decelerationCurve: Curves.easeOut,
                              )
                            : Text(
                                text,
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      song['more_info']['singers'].toString(),
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: _isLiked,
                  builder: (_, value, __) {
                    if (value == true) {
                      return IconButton(
                        color: Colors.red,
                        icon: const Icon(Icons.favorite),
                        onPressed: () => {
                          _isLiked.value = !_isLiked.value,
                          updateLikeStatus(song['ytid'], false)
                        },
                      );
                    } else {
                      return IconButton(
                        color: null,
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () => {
                          _isLiked.value = !_isLiked.value,
                          updateLikeStatus(song['ytid'], true)
                        },
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => downloadSong(context, song),
                ),
                PopupMenuButton(
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        child: Text('Tùy chọn 1'),
                        value: 1,
                      ),
                      PopupMenuItem(
                        child: Text('Tùy chọn 2'),
                        value: 2,
                      ),
                      PopupMenuItem(
                        child: Text('Tùy chọn 3'),
                        value: 3,
                      ),
                    ];
                  },
                  onSelected: (value) {

                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

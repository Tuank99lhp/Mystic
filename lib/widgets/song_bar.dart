import 'package:flutter/material.dart';
import 'package:mystic/style/app_themes.dart';
import 'package:marquee/marquee.dart';

class SongBar extends StatelessWidget {
  SongBar(this.song, this.clearPlaylist, {super.key});

  late final dynamic song;
  late final bool clearPlaylist;
  // late final songLikeStatus =
  //     ValueNotifier<bool>(isSongAlreadyLiked(song['ytid']));
  final ValueNotifier<bool> _isLiked = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: 60,
        padding: const EdgeInsets.only(left: 30),
        child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {},
            splashColor: colorScheme.primary.withOpacity(0.4),
            hoverColor: colorScheme.primary.withOpacity(0.4),
            focusColor: colorScheme.primary.withOpacity(0.4),
            highlightColor: colorScheme.primary.withOpacity(0.4),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    height: 60.0,
                    width: 60.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTn6GQFIELn3G3JW9UDuJSGDKdVDuTchgP3Yg&usqp=CAU'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 30,
                          alignment: Alignment.centerLeft,
                          child: LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              final text = "Song's nameeeeeeeeeeeeeeeeeeeeee";
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
                              textPainter.layout(
                                  maxWidth: constraints.maxWidth);
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                        Text(
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          'Singer',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14.0,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10.0),
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
                              onPressed: () =>
                                  {_isLiked.value = !_isLiked.value},
                            );
                          } else {
                            return IconButton(
                              color: null,
                              icon: const Icon(Icons.favorite_border),
                              onPressed: () =>
                                  {_isLiked.value = !_isLiked.value},
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () {},
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
                          // Xử lý khi người dùng chọn một tùy chọn
                        },
                      ),
                    ],
                  ),
                ])));
  }
}

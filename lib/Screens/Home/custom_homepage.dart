import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:blackhole/CustomWidgets/collage.dart';
import 'package:blackhole/CustomWidgets/horizontal_albumlist_separated.dart';
import 'package:blackhole/CustomWidgets/on_hover.dart';
import 'package:blackhole/Screens/Library/liked.dart';
import 'package:blackhole/Services/player_service.dart';
import 'package:blackhole/Services/youtube_services.dart';

bool fetched = false;
List preferredLanguage = Hive.box('settings')
    .get('preferredLanguage', defaultValue: ['Hindi']) as List;
List likedRadio =
    Hive.box('settings').get('likedRadio', defaultValue: []) as List;
Map data = Hive.box('cache').get('homepage', defaultValue: {}) as Map;
List lists = ['recent', 'playlist', 'trending'];
ValueNotifier<bool> homepageChanged = ValueNotifier<bool>(false);

class CustomHomePage extends StatefulWidget {
  @override
  _CustomHomePageState createState() => _CustomHomePageState();
}

class _CustomHomePageState extends State<CustomHomePage>
    with AutomaticKeepAliveClientMixin<CustomHomePage> {
  List trendingList =
      Hive.box('cache').get('ytHomeTrending', defaultValue: []) as List;
  List recentList =
      Hive.box('cache').get('recentSongs', defaultValue: []) as List;
  List playlistNames =
      Hive.box('settings').get('playlistNames')?.toList() as List? ??
          ['Favorite Songs'];
  Map playlistDetails =
      Hive.box('settings').get('playlistDetails', defaultValue: {}) as Map;
  int recentIndex = 0;
  int playlistIndex = 1;
  int trendingIndex = 2;

  // @override
  // void initState() {
  //   YouTubeServices().getTrendingSongs().then((value) {
  //     if (value.isNotEmpty) {
  //       setState(() {
  //         trendingList = value;
  //         Hive.box('cache').put('ytHomeTrending', value);
  //       });
  //     }
  //   });
  //   super.initState();
  // }
  Future<void> getHomePageData() async {
    // Map recievedData = await SaavnAPI().fetchHomePageData();
    // if (recievedData.isNotEmpty) {
    //   Hive.box('cache').put('homepage', recievedData);
    //   data = recievedData;
    //   lists = ['recent', 'playlist', ...?data['collections']];
    //   lists.insert((lists.length / 2).round(), 'likedArtists');
    // }
    await YouTubeServices().getTrendingSongs().then((value) {
      if (value.isNotEmpty) {
        setState(() {
          trendingList = value;
          Hive.box('cache').put('ytHomeTrending', value);
        });
      }
    });
    setState(() {});
  }

  int likedCount() {
    return Hive.box('Favorite Songs').length;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    trendingList =
        Hive.box('cache').get('ytHomeTrending', defaultValue: []) as List;
    recentList = Hive.box('cache').get('recentSongs', defaultValue: []) as List;
    playlistNames =
        Hive.box('settings').get('playlistNames')?.toList() as List? ??
            ['Favorite Songs'];
    playlistDetails =
        Hive.box('settings').get('playlistDetails', defaultValue: {}) as Map;
    if (!fetched) {
      getHomePageData();
      fetched = true;
    }
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;
    if (boxSize > 250) boxSize = 250;
    recentIndex = 0;
    playlistIndex = 1;
    trendingIndex = 2;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      itemCount: data.isEmpty ? 3 : lists.length,
      itemBuilder: (context, idx) {
        if (idx == recentIndex) {
          return (recentList.isEmpty ||
                  !(Hive.box('settings').get('showRecent', defaultValue: true)
                      as bool))
              ? const SizedBox()
              : Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
                          child: Text(
                            AppLocalizations.of(context)!.lastSession,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    HorizontalAlbumsListSeparated(
                      songsList: recentList,
                      onTap: (int idx) {
                        PlayerInvoke.init(
                          songsList: [recentList[idx]],
                          index: 0,
                          isOffline: false,
                        );
                        Navigator.pushNamed(context, '/player');
                      },
                    ),
                  ],
                );
        }
        if (idx == playlistIndex) {
          return (playlistNames.isEmpty ||
                  !(Hive.box('settings').get('showPlaylist', defaultValue: true)
                      as bool) ||
                  (playlistNames.length == 1 &&
                      playlistNames.first == 'Favorite Songs' &&
                      likedCount() == 0))
              ? const SizedBox()
              : Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
                          child: Text(
                            AppLocalizations.of(context)!.yourPlaylists,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: boxSize + 15,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: playlistNames.length,
                        itemBuilder: (context, index) {
                          final String name = playlistNames[index].toString();
                          final String showName =
                              playlistDetails.containsKey(name)
                                  ? playlistDetails[name]['name']?.toString() ??
                                      name
                                  : name;
                          final String? subtitle = playlistDetails[name] ==
                                      null ||
                                  playlistDetails[name]['count'] == null ||
                                  playlistDetails[name]['count'] == 0
                              ? null
                              : '${playlistDetails[name]['count']} ${AppLocalizations.of(context)!.songs}';
                          return GestureDetector(
                            child: SizedBox(
                              width: boxSize - 30,
                              child: HoverBox(
                                child: (playlistDetails[name] == null ||
                                        playlistDetails[name]['imagesList'] ==
                                            null ||
                                        (playlistDetails[name]['imagesList']
                                                as List)
                                            .isEmpty)
                                    ? Card(
                                        elevation: 5,
                                        color: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10.0,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: name == 'Favorite Songs'
                                            ? const Image(
                                                image: AssetImage(
                                                  'assets/cover.jpg',
                                                ),
                                              )
                                            : const Image(
                                                image: AssetImage(
                                                  'assets/album.png',
                                                ),
                                              ),
                                      )
                                    : Collage(
                                        borderRadius: 10.0,
                                        imageList: playlistDetails[name]
                                            ['imagesList'] as List,
                                        showGrid: true,
                                        placeholderImage: 'assets/cover.jpg',
                                      ),
                                builder: (
                                  BuildContext context,
                                  bool isHover,
                                  Widget? child,
                                ) {
                                  return Card(
                                    color: isHover ? null : Colors.transparent,
                                    elevation: 0,
                                    margin: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        10.0,
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      children: [
                                        SizedBox.square(
                                          dimension: isHover
                                              ? boxSize - 25
                                              : boxSize - 30,
                                          child: child,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                showName,
                                                textAlign: TextAlign.center,
                                                softWrap: false,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              if (subtitle != null &&
                                                  subtitle.isNotEmpty)
                                                Text(
                                                  subtitle,
                                                  textAlign: TextAlign.center,
                                                  softWrap: false,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .color,
                                                  ),
                                                )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            onTap: () async {
                              await Hive.openBox(name);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LikedSongs(
                                    playlistName: name,
                                    showName: playlistDetails.containsKey(name)
                                        ? playlistDetails[name]['name']
                                                ?.toString() ??
                                            name
                                        : name,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    )
                  ],
                );
        }
        if (idx == trendingIndex) {
          if (lists[idx] == 'trending' && trendingList.isNotEmpty) {
            return Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
                      child: Text(
                        AppLocalizations.of(context)!.trending,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 730,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: trendingList.length,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: 200,
                        child: ListTile(
                          leading: Card(
                            margin: EdgeInsets.zero,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                5.0,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: SizedBox.square(
                              dimension: 50,
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                errorWidget: (context, _, __) => const Image(
                                  fit: BoxFit.cover,
                                  image: AssetImage(
                                    'assets/cover.jpg',
                                  ),
                                ),
                                imageUrl:
                                    trendingList[index]['image'].toString(),
                                placeholder: (context, url) => const Image(
                                  fit: BoxFit.cover,
                                  image: AssetImage(
                                    'assets/cover.jpg',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          title: SizedBox(
                            width: 60,
                            child: Text(
                              trendingList[index]['title'].toString(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          subtitle: trendingList[index]['subtitle'] == ''
                              ? null
                              : Text(
                                  trendingList[index]['subtitle'].toString(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                          onTap: () async {
                            final Map? response =
                                await YouTubeServices().formatVideoFromId(
                              id: trendingList[index]['videoId'].toString(),
                            );
                            PlayerInvoke.init(
                              songsList: [response],
                              index: 0,
                              isOffline: false,
                            );
                            Navigator.pushNamed(context, '/player');
                            // for (var i = 0;
                            //     i < searchedList.length;
                            //     i++) {
                            //   YouTubeServices()
                            //       .formatVideo(
                            //     video: searchedList[i],
                            //     quality: Hive.box('settings')
                            //         .get(
                            //           'ytQuality',
                            //           defaultValue: 'Low',
                            //         )
                            //         .toString(),
                            //   )
                            //       .then((songMap) {
                            //     final MediaItem mediaItem =
                            //         MediaItemConverter.mapToMediaItem(
                            //       songMap!,
                            //     );
                            //     addToNowPlaying(
                            //       context: context,
                            //       mediaItem: mediaItem,
                            //       showNotification: false,
                            //     );
                            //   });
                            // }
                          },
                          // trailing: YtSongTileTrailingMenu(data: entry),
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          }
        }
        return const SizedBox();
      },
    );
  }
}

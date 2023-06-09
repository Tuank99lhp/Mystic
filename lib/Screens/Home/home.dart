import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:blackhole/CustomWidgets/custom_physics.dart';
import 'package:blackhole/CustomWidgets/gradient_containers.dart';
import 'package:blackhole/CustomWidgets/miniplayer.dart';
import 'package:blackhole/CustomWidgets/snackbar.dart';
import 'package:blackhole/Screens/Home/custom_homepage.dart';
import 'package:blackhole/Screens/Library/library.dart';
import 'package:blackhole/Screens/Library/playlists.dart';
import 'package:blackhole/Screens/Settings/setting.dart';
import 'package:blackhole/Screens/YouTube/youtube_search.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  bool checked = false;
  String? appVersion;
  String name =
      Hive.box('settings').get('name', defaultValue: 'Guest') as String;
  bool checkUpdate =
      Hive.box('settings').get('checkUpdate', defaultValue: false) as bool;
  bool autoBackup =
      Hive.box('settings').get('autoBackup', defaultValue: false) as bool;
  List sectionsToShow = Hive.box('settings').get(
    'sectionsToShow',
    defaultValue: ['Home', 'YouTube', 'Library', 'More'],
  ) as List;
  DateTime? backButtonPressTime;

  void callback() {
    sectionsToShow = Hive.box('settings').get(
      'sectionsToShow',
      defaultValue: ['Home', 'YouTube', 'Library', 'More'],
    ) as List;
    setState(() {});
  }

  void _onItemTapped(int index) {
    _selectedIndex.value = index;
    _pageController.jumpToPage(
      index,
    );
  }

  bool compareVersion(String latestVersion, String currentVersion) {
    bool update = false;
    final List latestList = latestVersion.split('.');
    final List currentList = currentVersion.split('.');

    for (int i = 0; i < latestList.length; i++) {
      try {
        if (int.parse(latestList[i] as String) >
            int.parse(currentList[i] as String)) {
          update = true;
          break;
        }
      } catch (e) {
        Logger.root.severe('Error while comparing versions: $e');
        break;
      }
    }
    return update;
  }

  Future<bool> handleWillPop(BuildContext context) async {
    final now = DateTime.now();
    final backButtonHasNotBeenPressedOrSnackBarHasBeenClosed =
        backButtonPressTime == null ||
            now.difference(backButtonPressTime!) > const Duration(seconds: 3);

    if (backButtonHasNotBeenPressedOrSnackBarHasBeenClosed) {
      backButtonPressTime = now;
      ShowSnackBar().showSnackBar(
        context,
        AppLocalizations.of(context)!.exitConfirm,
        duration: const Duration(seconds: 2),
        noAction: true,
      );
      return false;
    }
    return true;
  }

  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool rotated = MediaQuery.of(context).size.height < screenWidth;
    return GradientContainer(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        // drawer: Drawer(
        //   child: GradientContainer(
        //     child: CustomScrollView(
        //       shrinkWrap: true,
        //       physics: const BouncingScrollPhysics(),
        //       slivers: [
        //         SliverAppBar(
        //           backgroundColor: Colors.transparent,
        //           automaticallyImplyLeading: false,
        //           elevation: 0,
        //           stretch: true,
        //           expandedHeight: MediaQuery.of(context).size.height * 0.2,
        //           flexibleSpace: FlexibleSpaceBar(
        //             title: RichText(
        //               text: TextSpan(
        //                 text: AppLocalizations.of(context)!.appTitle,
        //                 style: const TextStyle(
        //                   fontSize: 30.0,
        //                   fontWeight: FontWeight.w500,
        //                 ),
        //                 children: <TextSpan>[
        //                   TextSpan(
        //                     text: appVersion == null ? '' : '\nv$appVersion',
        //                     style: const TextStyle(
        //                       fontSize: 7.0,
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //               textAlign: TextAlign.end,
        //             ),
        //             titlePadding: const EdgeInsets.only(bottom: 40.0),
        //             centerTitle: true,
        //             background: ShaderMask(
        //               shaderCallback: (rect) {
        //                 return LinearGradient(
        //                   begin: Alignment.topCenter,
        //                   end: Alignment.bottomCenter,
        //                   colors: [
        //                     Colors.black.withOpacity(0.8),
        //                     Colors.black.withOpacity(0.1),
        //                   ],
        //                 ).createShader(
        //                   Rect.fromLTRB(0, 0, rect.width, rect.height),
        //                 );
        //               },
        //               blendMode: BlendMode.dstIn,
        //               child: Image(
        //                 fit: BoxFit.cover,
        //                 alignment: Alignment.topCenter,
        //                 image: AssetImage(
        //                   Theme.of(context).brightness == Brightness.dark
        //                       ? 'assets/header-dark.jpg'
        //                       : 'assets/header.jpg',
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ),
        //         SliverList(
        //           delegate: SliverChildListDelegate(
        //             [
        //               ListTile(
        //                 title: Text(
        //                   AppLocalizations.of(context)!.home,
        //                   style: TextStyle(
        //                     color: Theme.of(context).colorScheme.secondary,
        //                   ),
        //                 ),
        //                 contentPadding:
        //                     const EdgeInsets.symmetric(horizontal: 20.0),
        //                 leading: Icon(
        //                   Icons.home_rounded,
        //                   color: Theme.of(context).colorScheme.secondary,
        //                 ),
        //                 selected: true,
        //                 onTap: () {
        //                   Navigator.pop(context);
        //                 },
        //               ),
        //               if (Platform.isAndroid)
        //                 ListTile(
        //                   title: Text(AppLocalizations.of(context)!.myMusic),
        //                   contentPadding:
        //                       const EdgeInsets.symmetric(horizontal: 20.0),
        //                   leading: Icon(
        //                     MdiIcons.folderMusic,
        //                     color: Theme.of(context).iconTheme.color,
        //                   ),
        //                   onTap: () {
        //                     Navigator.pop(context);
        //                     Navigator.push(
        //                       context,
        //                       MaterialPageRoute(
        //                         builder: (context) => const DownloadedSongs(
        //                           showPlaylists: true,
        //                         ),
        //                       ),
        //                     );
        //                   },
        //                 ),
        //               ListTile(
        //                 title: Text(AppLocalizations.of(context)!.downs),
        //                 contentPadding:
        //                     const EdgeInsets.symmetric(horizontal: 20.0),
        //                 leading: Icon(
        //                   Icons.download_done_rounded,
        //                   color: Theme.of(context).iconTheme.color,
        //                 ),
        //                 onTap: () {
        //                   Navigator.pop(context);
        //                   Navigator.pushNamed(context, '/downloads');
        //                 },
        //               ),
        //               ListTile(
        //                 title: Text(AppLocalizations.of(context)!.playlists),
        //                 contentPadding:
        //                     const EdgeInsets.symmetric(horizontal: 20.0),
        //                 leading: Icon(
        //                   Icons.playlist_play_rounded,
        //                   color: Theme.of(context).iconTheme.color,
        //                 ),
        //                 onTap: () {
        //                   Navigator.pop(context);
        //                   Navigator.pushNamed(context, '/playlists');
        //                 },
        //               ),
        //               ListTile(
        //                 title: Text(AppLocalizations.of(context)!.settings),
        //                 contentPadding:
        //                     const EdgeInsets.symmetric(horizontal: 20.0),
        //                 leading: Icon(
        //                   Icons
        //                       .settings_rounded, // miscellaneous_services_rounded,
        //                   color: Theme.of(context).iconTheme.color,
        //                 ),
        //                 onTap: () {
        //                   Navigator.pop(context);
        //                   Navigator.push(
        //                     context,
        //                     MaterialPageRoute(
        //                       builder: (context) =>
        //                           SettingPage(callback: callback),
        //                     ),
        //                   );
        //                 },
        //               ),
        //               ListTile(
        //                 title: Text(AppLocalizations.of(context)!.about),
        //                 contentPadding:
        //                     const EdgeInsets.symmetric(horizontal: 20.0),
        //                 leading: Icon(
        //                   Icons.info_outline_rounded,
        //                   color: Theme.of(context).iconTheme.color,
        //                 ),
        //                 onTap: () {
        //                   Navigator.pop(context);
        //                   Navigator.pushNamed(context, '/about');
        //                 },
        //               ),
        //             ],
        //           ),
        //         ),
        //         SliverFillRemaining(
        //           hasScrollBody: false,
        //           child: Column(
        //             children: <Widget>[
        //               const Spacer(),
        //               Padding(
        //                 padding: const EdgeInsets.fromLTRB(5, 30, 5, 20),
        //                 child: Center(
        //                   child: Text(
        //                     AppLocalizations.of(context)!.madeBy,
        //                     textAlign: TextAlign.center,
        //                     style: const TextStyle(fontSize: 12),
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        body: WillPopScope(
          onWillPop: () => handleWillPop(context),
          child: SafeArea(
            child: Row(
              children: [
                if (rotated)
                  ValueListenableBuilder(
                    valueListenable: _selectedIndex,
                    builder:
                        (BuildContext context, int indexValue, Widget? child) {
                      return NavigationRail(
                        minWidth: 70.0,
                        groupAlignment: 0.0,
                        backgroundColor:
                            // Colors.transparent,
                            Theme.of(context).cardColor,
                        selectedIndex: indexValue,
                        onDestinationSelected: (int index) {
                          _onItemTapped(index);
                        },
                        labelType: screenWidth > 1050
                            ? NavigationRailLabelType.selected
                            : NavigationRailLabelType.none,
                        selectedLabelTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelTextStyle: TextStyle(
                          color: Theme.of(context).iconTheme.color,
                        ),
                        selectedIconTheme: Theme.of(context).iconTheme.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                        unselectedIconTheme: Theme.of(context).iconTheme,
                        useIndicator: screenWidth < 1050,
                        indicatorColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.2),
                        destinations: [
                          NavigationRailDestination(
                            icon: const Icon(Icons.home_rounded),
                            label: Text(AppLocalizations.of(context)!.home),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(MdiIcons.youtube),
                            label: Text(
                              AppLocalizations.of(context)!.youTube,
                            ),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.my_library_music_rounded),
                            label: Text(AppLocalizations.of(context)!.library),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.more_horiz_rounded),
                            label: Text(AppLocalizations.of(context)!.more),
                          ),
                        ],
                      );
                    },
                  ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView(
                          physics: const CustomPhysics(),
                          onPageChanged: (indx) {
                            _selectedIndex.value = indx;
                          },
                          controller: _pageController,
                          children: [
                            Stack(
                              children: [
                                NestedScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  controller: _scrollController,
                                  headerSliverBuilder: (
                                    BuildContext context,
                                    bool innerBoxScrolled,
                                  ) {
                                    return <Widget>[
                                      SliverAppBar(
                                        expandedHeight: 40,
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        // pinned: true,
                                        toolbarHeight: 65,
                                        // floating: true,
                                        automaticallyImplyLeading: false,
                                        flexibleSpace: LayoutBuilder(
                                          builder: (
                                            BuildContext context,
                                            BoxConstraints constraints,
                                          ) {
                                            return Column(
                                              children: [
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                      8.0,
                                                    ),
                                                    child: Text(
                                                      'Homepage',
                                                      style: TextStyle(
                                                        fontSize:
                                                            25, // set the font size to 20
                                                        fontWeight: FontWeight
                                                            .bold, // set the font weight to bold
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                      // SliverAppBar(
                                      //   automaticallyImplyLeading: false,
                                      //   pinned: true,
                                      //   backgroundColor: Colors.transparent,
                                      //   elevation: 0,
                                      //   stretch: true,
                                      //   toolbarHeight: 65,
                                      //   title: Align(
                                      //     alignment: Alignment.centerRight,
                                      //     child: AnimatedBuilder(
                                      //       animation: _scrollController,
                                      //       builder: (context, child) {
                                      //         return GestureDetector(
                                      //           child: AnimatedContainer(
                                      //             width:  MediaQuery.of(context).size.width,
                                      //             height: 55.0,
                                      //             duration: const Duration(
                                      //               milliseconds: 150,
                                      //             ),
                                      //             padding:
                                      //                 const EdgeInsets.all(2.0),
                                      //             // margin: EdgeInsets.zero,
                                      //             decoration: BoxDecoration(
                                      //               borderRadius:
                                      //                   BorderRadius.circular(
                                      //                 10.0,
                                      //               ),
                                      //               color: Theme.of(context)
                                      //                   .cardColor,
                                      //               boxShadow: const [
                                      //                 BoxShadow(
                                      //                   color: Colors.black26,
                                      //                   blurRadius: 5.0,
                                      //                   offset:
                                      //                       Offset(1.5, 1.5),
                                      //                   // shadow direction: bottom right
                                      //                 )
                                      //               ],
                                      //             ),
                                      //             child: Row(
                                      //               children: [
                                      //                 const SizedBox(
                                      //                   width: 10.0,
                                      //                 ),
                                      //                 Icon(
                                      //                   CupertinoIcons.search,
                                      //                   color: Theme.of(context)
                                      //                       .colorScheme
                                      //                       .secondary,
                                      //                 ),
                                      //                 const SizedBox(
                                      //                   width: 10.0,
                                      //                 ),
                                      //                 Text(
                                      //                   AppLocalizations.of(
                                      //                     context,
                                      //                   )!
                                      //                       .searchText,
                                      //                   style: TextStyle(
                                      //                     fontSize: 16.0,
                                      //                     color:
                                      //                         Theme.of(context)
                                      //                             .textTheme
                                      //                             .bodySmall!
                                      //                             .color,
                                      //                     fontWeight:
                                      //                         FontWeight.normal,
                                      //                   ),
                                      //                 ),
                                      //               ],
                                      //             ),
                                      //           ),
                                      //           onTap: () => Navigator.push(
                                      //             context,
                                      //             MaterialPageRoute(
                                      //               builder: (context) =>
                                      //                   const SearchPage(
                                      //                 query: '',
                                      //                 fromHome: true,
                                      //                 autofocus: true,
                                      //               ),
                                      //             ),
                                      //           ),
                                      //         );
                                      //       },
                                      //     ),
                                      //   ),
                                      // ),
                                    ];
                                  },
                                  body: ValueListenableBuilder<bool>(
                                    valueListenable: homepageChanged,
                                    builder: (BuildContext context, bool value,
                                        Widget? child) {
                                      return CustomHomePage();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            // const YouTube(),
                            const YouTubeSearchPage(
                              query: '',
                            ),
                            PlaylistScreen(),
                            const LibraryPage(),
                            if (sectionsToShow.contains('Settings'))
                              SettingPage(callback: callback),
                          ],
                        ),
                      ),
                      MiniPlayer()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: rotated
            ? null
            : SafeArea(
                child: ValueListenableBuilder(
                  valueListenable: _selectedIndex,
                  builder:
                      (BuildContext context, int indexValue, Widget? child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      height: 60,
                      child: SalomonBottomBar(
                        currentIndex: indexValue,
                        onTap: (index) {
                          _onItemTapped(index);
                        },
                        items: [
                          SalomonBottomBarItem(
                            icon: const Icon(Icons.home_rounded),
                            title: Text(AppLocalizations.of(context)!.home),
                            selectedColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                          if (sectionsToShow.contains('YouTube'))
                            SalomonBottomBarItem(
                              icon: const Icon(MdiIcons.youtube),
                              title: Text(
                                AppLocalizations.of(context)!.youTube,
                              ),
                              selectedColor:
                                  Theme.of(context).colorScheme.secondary,
                            ),
                          SalomonBottomBarItem(
                            icon: const Icon(Icons.my_library_music_rounded),
                            title:
                                Text(AppLocalizations.of(context)!.playlists),
                            selectedColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                          SalomonBottomBarItem(
                            icon: const Icon(Icons.more_horiz_rounded),
                            title: Text(AppLocalizations.of(context)!.more),
                            selectedColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                          if (sectionsToShow.contains('Settings'))
                            SalomonBottomBarItem(
                              icon: const Icon(Icons.settings_rounded),
                              title:
                                  Text(AppLocalizations.of(context)!.settings),
                              selectedColor:
                                  Theme.of(context).colorScheme.secondary,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

import 'package:mystic/screens/home_page.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:mystic/screens/more_page.dart';
import 'package:mystic/screens/search_page.dart';
import 'package:mystic/screens/user_playlists_page.dart';
import 'package:flutter/material.dart';
import 'package:mystic/widgets/custom_physics.dart';
import 'package:mystic/widgets/snackbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class Mystic extends StatefulWidget {
  const Mystic({super.key});

  @override
  State<StatefulWidget> createState() {
    return AppState();
  }
}

class AppState extends State<Mystic> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  ValueNotifier<String> activeTab = ValueNotifier<String>('/');
  DateTime? backButtonPressTime;
  List sectionsToShow = ['Home', 'Search', 'Playlists', 'More'];
  final PageController _pageController = PageController();
  @override
  void initState() {
    super.initState();
    // checkAppUpdates().then(
    //       (value) => {
    //     if (value == true)
    //       {
    //         showToast(
    //           '${AppLocalizations.of(context)!.appUpdateIsAvailable}!',
    //         ),
    //       }
    //   },
    // );
    // checkNecessaryPermissions(context);
  }

  void _onItemTapped(int index) {
    _selectedIndex.value = index;
    _pageController.jumpToPage(
      index,
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () => handleWillPop(context),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                  child: PageView(
                      physics: const CustomPhysics(),
                      onPageChanged: (index) {
                        _selectedIndex.value = index;
                      },
                      controller: _pageController,
                      children: [
                    HomePage(),
                    SearchPage(
                      query: '',
                      fromHome: true,
                      autofocus: true,
                    ),
                    UserPlaylistsPage(),
                    MorePage(),
                  ])),
              const SizedBox()
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: _selectedIndex,
          builder: (BuildContext context, int indexValue, Widget? child) {
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
                    selectedColor: Theme.of(context).colorScheme.secondary,
                  ),
                  if (sectionsToShow.contains('Search'))
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.trending_up_rounded),
                      title: Text(
                        AppLocalizations.of(context)!.search,
                      ),
                      selectedColor: Theme.of(context).colorScheme.secondary,
                    ),
                  SalomonBottomBarItem(
                    icon: const Icon(Icons.my_library_music_rounded),
                    title: Text(AppLocalizations.of(context)!.userPlaylists),
                    selectedColor: Theme.of(context).colorScheme.secondary,
                  ),
                  SalomonBottomBarItem(
                    icon: const Icon(FluentIcons.more_horizontal_24_regular),
                    title: Text(AppLocalizations.of(context)!.more),
                    selectedColor: Theme.of(context).colorScheme.secondary,
                  ),
                  if (sectionsToShow.contains('Settings'))
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.settings_rounded),
                      title: Text(AppLocalizations.of(context)!.settings),
                      selectedColor: Theme.of(context).colorScheme.secondary,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

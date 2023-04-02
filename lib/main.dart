import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mystic/screens/more_page.dart';
import 'package:mystic/screens/player.dart';
import 'package:mystic/screens/root_page.dart';
import 'package:mystic/style/app_colors.dart';
import 'package:mystic/style/app_themes.dart';

import 'screens/local_music.dart';
import 'services/audio_service.dart';

import 'package:mystic/helpers/config.dart';

void main() async {
  await initialisation();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

Future<void> startService() async {
  final audioHandler = await AudioService.init(
    builder: AudioPlayerHandlerImpl.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.hynduf.mystic.channel.audio',
      androidNotificationChannelName: 'mystic',
    ),
  );
  GetIt.I.registerSingleton<AudioPlayerHandler>(audioHandler);
  GetIt.I.registerSingleton<MyTheme>(MyTheme());
}

Future<void> initialisation() async {
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('ytlinkcache');
  await Hive.openBox('downloads');
  await Hive.openBox('user');
  await Hive.openBox('cache');
  if (Platform.isAndroid) {
    setOptimalDisplayMode();
  }
  await startService();

  // await FlutterDisplayMode.setHighRefreshRate();

  // await JustAudioBackground.init(
  //   androidNotificationChannelId: 'com.hynduf.mystic',
  //   androidNotificationChannelName: 'Mystic',
  //   androidNotificationIcon: 'mipmap/launcher_icon',
  //   androidShowNotificationBadge: true,
  //   androidStopForegroundOnPause: !foregroundService.value,
  // );

  // final session = await AudioSession.instance;
  // await session.configure(const AudioSessionConfiguration.music());
  // session.interruptionEventStream.listen((event) {
  //   if (event.begin) {
  //     if (audioPlayer.playing) {
  //       audioPlayer.pause();
  //       _interrupted = true;
  //     }
  //   } else {
  //     switch (event.type) {
  //       case AudioInterruptionType.pause:
  //       case AudioInterruptionType.duck:
  //         if (!audioPlayer.playing && _interrupted) {
  //           audioPlayer.play();
  //         }
  //         break;
  //       case AudioInterruptionType.unknown:
  //         break;
  //     }
  //     _interrupted = false;
  //   }
  // });
  // activateListeners();
  // await enableBooster();
  //
  // try {
  //   await FlutterDownloader.initialize(
  //     debug: kDebugMode,
  //     ignoreSsl: true,
  //   );
  //
  //   await FlutterDownloader.registerCallback(downloadCallback);
  // } catch (e) {
  //   debugPrint('error while initializing Flutter Downloader plugin $e');
  // }
}

Future<void> setOptimalDisplayMode() async {
  await FlutterDisplayMode.setHighRefreshRate();
  // final List<DisplayMode> supported = await FlutterDisplayMode.supported;
  // final DisplayMode active = await FlutterDisplayMode.active;

  // final List<DisplayMode> sameResolution = supported
  //     .where(
  //       (DisplayMode m) => m.width == active.width && m.height == active.height,
  //     )
  //     .toList()
  //   ..sort(
  //     (DisplayMode a, DisplayMode b) => b.refreshRate.compareTo(a.refreshRate),
  //   );

  // final DisplayMode mostOptimalMode =
  //     sameResolution.isNotEmpty ? sameResolution.first : active;

  // await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
}

ThemeMode themeMode = ThemeMode.system;

final appLanguages = <String, String>{
  'English': 'en',
  'Vietnamese': 'vi',
};

final appSupportedLocales = appLanguages.values
    .map((languageCode) => Locale.fromSubtags(languageCode: languageCode))
    .toList();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static Future<void> setThemeMode(
    BuildContext context,
    ThemeMode newThemeMode,
  ) async {
    final state = context.findAncestorStateOfType<_MyAppState>()!;
    state.changeTheme(newThemeMode);
  }

  static Future<void> setLocale(
    BuildContext context,
    Locale newLocale,
  ) async {
    final state = context.findAncestorStateOfType<_MyAppState>()!;
    state.changeLanguage(newLocale);
  }

  static Future<void> setAccentColor(
    BuildContext context,
    Color newAccentColor,
    bool systemColorStatus,
  ) async {
    final state = context.findAncestorStateOfType<_MyAppState>()!;
    state.changeAccentColor(newAccentColor, systemColorStatus);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  Locale _locale = const Locale('en', '');

  void changeTheme(ThemeMode newThemeMode) {
    setState(() {
      themeMode = newThemeMode;
    });
  }

  void changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void changeAccentColor(Color newAccentColor, bool systemColorStatus) {
    setState(() {
      useSystemColor.value = systemColorStatus;
      primarySwatch = getPrimarySwatch(newAccentColor);

      colorScheme = ColorScheme.fromSwatch(primarySwatch: primarySwatch);
    });
  }

  @override
  void initState() {
    super.initState();
    final settingsBox = Hive.box('settings');
    final language =
        settingsBox.get('language', defaultValue: 'English') as String;
    _locale = Locale(appLanguages[language] ?? 'en');
    final themeModeSetting =
        settingsBox.get('themeMode', defaultValue: 'system') as String;
    themeMode = themeModeSetting == 'system'
        ? ThemeMode.system
        : themeModeSetting == 'light'
            ? ThemeMode.light
            : ThemeMode.dark;
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kBorderRadius = BorderRadius.circular(15.0);
    const kContentPadding =
        EdgeInsets.only(left: 18, right: 20, top: 14, bottom: 14);

    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        if (lightColorScheme != null &&
            darkColorScheme != null &&
            useSystemColor.value) {
          colorScheme =
              themeMode == ThemeMode.light ? lightColorScheme : darkColorScheme;
        }

        return MaterialApp(
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          darkTheme: darkColorScheme != null && useSystemColor.value
              ? getAppDarkTheme().copyWith(
                  scaffoldBackgroundColor: darkColorScheme.surface,
                  colorScheme: darkColorScheme.harmonized(),
                  canvasColor: darkColorScheme.surface,
                  bottomAppBarTheme: BottomAppBarTheme(
                    color: darkColorScheme.surface,
                  ),
                  appBarTheme: AppBarTheme(
                    backgroundColor: darkColorScheme.surface,
                    centerTitle: true,
                    titleTextStyle: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                    elevation: 0,
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: kBorderRadius,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: kBorderRadius,
                    ),
                    contentPadding: kContentPadding,
                  ),
                )
              : getAppDarkTheme(),
          theme: lightColorScheme != null && useSystemColor.value
              ? getAppLightTheme().copyWith(
                  scaffoldBackgroundColor: lightColorScheme.surface,
                  colorScheme: lightColorScheme.harmonized(),
                  canvasColor: lightColorScheme.surface,
                  bottomAppBarTheme: BottomAppBarTheme(
                    color: lightColorScheme.surface,
                  ),
                  appBarTheme: AppBarTheme(
                    backgroundColor: lightColorScheme.surface,
                    centerTitle: true,
                    titleTextStyle: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                    elevation: 0,
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: kBorderRadius,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: kBorderRadius,
                    ),
                    contentPadding: kContentPadding,
                  ),
                )
              : getAppLightTheme(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: appSupportedLocales,
          locale: _locale,
          routes: {
            '/about': (context) => const Placeholder(),
            '/downloads': (context) => const Placeholder(),
            '/favorites': (context) => const Placeholder(),
            '/local': (context) => const LocalMusic(),
            '/player': (context) => const AudioApp(),
            '/settings': (context) => const Placeholder(),
          },
          navigatorKey: _navigatorKey,
          home: const Mystic(),
        );
      },
    );
  }
}

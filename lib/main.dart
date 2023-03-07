import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:mystic/screens/more_page.dart';
import 'package:mystic/screens/root_page.dart';
import 'package:mystic/style/app_colors.dart';
import 'package:mystic/style/app_themes.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:just_audio_background/just_audio_background.dart';

void main() async {
  await initialisation();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

Future<void> initialisation() async {
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('user');
  await Hive.openBox('cache');

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
    const kContentPadding = EdgeInsets.only(left: 18, right: 20, top: 14, bottom: 14);

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
          home: Mystic(),
        );
      },
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

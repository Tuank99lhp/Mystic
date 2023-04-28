/*
 *  This file is part of Mystic (https://github.com/Sangwan5688/Mystic).
 * 
 * Mystic is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Mystic is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Mystic.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Copyright (c) 2021-2022, Ankit Sangwan
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blackhole/CustomWidgets/gradient_containers.dart';
import 'package:blackhole/Helpers/backup_restore.dart';
import 'package:blackhole/Helpers/config.dart';
import 'package:blackhole/Helpers/countrycodes.dart';
import 'package:blackhole/main.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingPage extends StatefulWidget {
  final Function? callback;
  const SettingPage({this.callback});
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage>
    with AutomaticKeepAliveClientMixin<SettingPage> {
  String? appVersion;
  final Box settingsBox = Hive.box('settings');
  final MyTheme currentTheme = GetIt.I<MyTheme>();
  String downloadPath = Hive.box('settings')
      .get('downloadPath', defaultValue: '/storage/emulated/0/Music') as String;
  String autoBackPath = Hive.box('settings').get(
    'autoBackPath',
    defaultValue: '/storage/emulated/0/Mystic/Backups',
  ) as String;
  final ValueNotifier<bool> includeOrExclude = ValueNotifier<bool>(
    Hive.box('settings').get('includeOrExclude', defaultValue: false) as bool,
  );
  List includedExcludedPaths = Hive.box('settings')
      .get('includedExcludedPaths', defaultValue: []) as List;
  List blacklistedHomeSections = Hive.box('settings')
      .get('blacklistedHomeSections', defaultValue: []) as List;
  String streamingQuality = Hive.box('settings')
      .get('streamingQuality', defaultValue: '96 kbps') as String;
  String ytQuality =
      Hive.box('settings').get('ytQuality', defaultValue: 'Low') as String;
  String downloadQuality = Hive.box('settings')
      .get('downloadQuality', defaultValue: '320 kbps') as String;
  String ytDownloadQuality = Hive.box('settings')
      .get('ytDownloadQuality', defaultValue: 'High') as String;
  String lang =
      Hive.box('settings').get('lang', defaultValue: 'English') as String;
  String canvasColor =
      Hive.box('settings').get('canvasColor', defaultValue: 'Grey') as String;
  String cardColor =
      Hive.box('settings').get('cardColor', defaultValue: 'Grey900') as String;
  String theme =
      Hive.box('settings').get('theme', defaultValue: 'Default') as String;
  Map userThemes =
      Hive.box('settings').get('userThemes', defaultValue: {}) as Map;
  String region =
      Hive.box('settings').get('region', defaultValue: 'India') as String;
  bool useProxy =
      Hive.box('settings').get('useProxy', defaultValue: false) as bool;
  String themeColor =
      Hive.box('settings').get('themeColor', defaultValue: 'Teal') as String;
  int colorHue = Hive.box('settings').get('colorHue', defaultValue: 400) as int;
  int downFilename =
      Hive.box('settings').get('downFilename', defaultValue: 0) as int;
  List<String> languages = [
    'Hindi',
    'English',
    'Punjabi',
    'Tamil',
    'Telugu',
    'Marathi',
    'Gujarati',
    'Bengali',
    'Kannada',
    'Bhojpuri',
    'Malayalam',
    'Urdu',
    'Haryanvi',
    'Rajasthani',
    'Odia',
    'Assamese'
  ];
  List miniButtonsOrder = Hive.box('settings').get(
    'miniButtonsOrder',
    defaultValue: ['Like', 'Previous', 'Play/Pause', 'Next', 'Download'],
  ) as List;
  List preferredLanguage = Hive.box('settings')
      .get('preferredLanguage', defaultValue: ['Hindi'])?.toList() as List;
  List preferredMiniButtons = Hive.box('settings').get(
    'preferredMiniButtons',
    defaultValue: ['Like', 'Play/Pause', 'Next'],
  )?.toList() as List;
  List<int> preferredCompactNotificationButtons = Hive.box('settings').get(
    'preferredCompactNotificationButtons',
    defaultValue: [1, 2, 3],
  ) as List<int>;
  final ValueNotifier<List> sectionsToShow = ValueNotifier<List>(
    Hive.box('settings').get(
      'sectionsToShow',
      defaultValue: ['Home', 'Top Charts', 'YouTube', 'Library'],
    ) as List,
  );

  @override
  void initState() {
    main();
    super.initState();
  }

  @override
  bool get wantKeepAlive => sectionsToShow.value.contains('Settings');

  Future<void> main() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    setState(
      () {},
    );
  }

  bool compareVersion(String latestVersion, String currentVersion) {
    bool update = false;
    final List<String> latestList = latestVersion.split('.');
    final List<String> currentList = currentVersion.split('.');

    for (int i = 0; i < latestList.length; i++) {
      try {
        if (int.parse(latestList[i]) > int.parse(currentList[i])) {
          update = true;
          break;
        }
      } catch (e) {
        break;
      }
    }

    return update;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: TextStyle(
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      // backgroundColor: Colors.transparent,
      body: ColoredBox(
        color: Theme.of(context).canvasColor,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  GradientCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BoxSwitchTile(
                          title: Text(
                            AppLocalizations.of(context)!.darkMode,
                            style: const TextStyle(fontSize: 18),
                          ),
                          keyName: 'darkMode',
                          defaultValue: true,
                          onChanged: (bool val, Box box) {
                            box.put(
                              'useSystemTheme',
                              false,
                            );
                            currentTheme.switchTheme(
                              isDark: val,
                              useSystemTheme: false,
                            );
                            switchToCustomTheme();
                          },
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .accent,
                            style: const TextStyle(fontSize: 18),
                          ),
                          trailing: Padding(
                            padding: const EdgeInsets.all(
                              10.0,
                            ),
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  100.0,
                                ),
                                color: Theme.of(context).colorScheme.secondary,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey[900]!,
                                    blurRadius: 5.0,
                                    offset: const Offset(
                                      0.0,
                                      3.0,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            showModalBottomSheet(
                              isDismissible: true,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (BuildContext context) {
                                final List<String> colors = [
                                  'Purple',
                                  'Deep Purple',
                                  'Indigo',
                                  'Blue',
                                  'Light Blue',
                                  'Cyan',
                                  'Teal',
                                  'Green',
                                  'Light Green',
                                  'Lime',
                                  'Yellow',
                                  'Amber',
                                  'Orange',
                                  'Deep Orange',
                                  'Red',
                                  'Pink',
                                  'White',
                                ];
                                return BottomGradientContainer(
                                  borderRadius: BorderRadius.circular(
                                    20.0,
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(
                                      0,
                                      10,
                                      0,
                                      10,
                                    ),
                                    itemCount: colors.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 15.0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            for (int hue in [
                                              100,
                                              200,
                                              400,
                                              700
                                            ])
                                              GestureDetector(
                                                onTap: () {
                                                  themeColor = colors[index];
                                                  colorHue = hue;
                                                  currentTheme.switchColor(
                                                    colors[index],
                                                    colorHue,
                                                  );
                                                  setState(
                                                    () {},
                                                  );
                                                  switchToCustomTheme();
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.125,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.125,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      100.0,
                                                    ),
                                                    color: MyTheme().getColor(
                                                      colors[index],
                                                      hue,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color:
                                                            Colors.grey[900]!,
                                                        blurRadius: 5.0,
                                                        offset: const Offset(
                                                          0.0,
                                                          3.0,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  child: (themeColor ==
                                                              colors[index] &&
                                                          colorHue == hue)
                                                      ? const Icon(
                                                          Icons.done_rounded,
                                                        )
                                                      : const SizedBox(),
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                          dense: true,
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .lang,
                            style: const TextStyle(fontSize: 18),
                          ),
                          onTap: () {},
                          trailing: DropdownButton(
                            value: lang,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                            underline: const SizedBox(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(
                                  () {
                                    lang = newValue;
                                    MyApp.of(context).setLocale(
                                      Locale.fromSubtags(
                                        languageCode: ConstantCodes
                                                .languageCodes[newValue] ??
                                            'en',
                                      ),
                                    );
                                    Hive.box('settings').put('lang', newValue);
                                  },
                                );
                              }
                            },
                            items: ConstantCodes.languageCodes.keys
                                .map<DropdownMenuItem<String>>((language) {
                              return DropdownMenuItem<String>(
                                value: language,
                                child: Text(
                                  language,
                                    style: const TextStyle(fontSize: 16),
                                ),
                              );
                            }).toList(),
                          ),
                          dense: true,
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .createBack,
                            style: const TextStyle(fontSize: 18),
                          ),
                          subtitle: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .createBackSub,
                            style: const TextStyle(fontSize: 14),

                          ),
                          dense: true,
                          onTap: () {
                            showModalBottomSheet(
                              isDismissible: true,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (BuildContext context) {
                                final List playlistNames =
                                    Hive.box('settings').get(
                                  'playlistNames',
                                  defaultValue: ['Favorite Songs'],
                                ) as List;
                                if (!playlistNames.contains('Favorite Songs')) {
                                  playlistNames.insert(0, 'Favorite Songs');
                                  settingsBox.put(
                                    'playlistNames',
                                    playlistNames,
                                  );
                                }

                                final List<String> persist = [
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .settings,
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .playlists,
                                ];

                                final List<String> checked = [
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .settings,
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .downs,
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .playlists,
                                ];

                                final List<String> items = [
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .settings,
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .playlists,
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .downs,
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .cache,
                                ];

                                final Map<String, List> boxNames = {
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .settings: ['settings'],
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .cache: ['cache'],
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .downs: ['downloads'],
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .playlists: playlistNames,
                                };
                                return StatefulBuilder(
                                  builder: (
                                    BuildContext context,
                                    StateSetter setStt,
                                  ) {
                                    return BottomGradientContainer(
                                      borderRadius: BorderRadius.circular(
                                        20.0,
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: ListView.builder(
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              shrinkWrap: true,
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                0,
                                                10,
                                                0,
                                                10,
                                              ),
                                              itemCount: items.length,
                                              itemBuilder: (context, idx) {
                                                return CheckboxListTile(
                                                  activeColor: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  checkColor: Theme.of(context)
                                                              .colorScheme
                                                              .secondary ==
                                                          Colors.white
                                                      ? Colors.black
                                                      : null,
                                                  value: checked.contains(
                                                    items[idx],
                                                  ),
                                                  title: Text(
                                                    items[idx],
                                                  ),
                                                  onChanged: persist
                                                          .contains(items[idx])
                                                      ? null
                                                      : (bool? value) {
                                                          value!
                                                              ? checked.add(
                                                                  items[idx],
                                                                )
                                                              : checked.remove(
                                                                  items[idx],
                                                                );
                                                          setStt(
                                                            () {},
                                                          );
                                                        },
                                                );
                                              },
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!
                                                      .cancel,
                                                ),
                                              ),
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                ),
                                                onPressed: () {
                                                  createBackup(
                                                    context,
                                                    checked,
                                                    boxNames,
                                                  );
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!
                                                      .ok,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .restore,
                            style: const TextStyle(fontSize: 18),
                          ),
                          subtitle: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .restoreSub,
                            style: const TextStyle(fontSize: 14),
                          ),
                          dense: true,
                          onTap: () async {
                            await restore(context);
                            currentTheme.refresh();
                          },
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .version,
                            style: const TextStyle(fontSize: 18),
                          ),
                          trailing: Text(
                            'v$appVersion',
                            style: const TextStyle(fontSize: 14),
                          ),
                          dense: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void switchToCustomTheme() {
    const custom = 'Custom';
    if (theme != custom) {
      currentTheme.setInitialTheme(custom);
      setState(
        () {
          theme = custom;
        },
      );
    }
  }
}

class BoxSwitchTile extends StatelessWidget {
  const BoxSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.keyName,
    required this.defaultValue,
    this.isThreeLine,
    this.onChanged,
  });

  final Text title;
  final Text? subtitle;
  final String keyName;
  final bool defaultValue;
  final bool? isThreeLine;
  final Function(bool, Box box)? onChanged;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (BuildContext context, Box box, Widget? widget) {
        return SwitchListTile(
          activeColor: Theme.of(context).colorScheme.secondary,
          title: title,
          subtitle: subtitle,
          isThreeLine: isThreeLine ?? false,
          dense: true,
          value: box.get(keyName, defaultValue: defaultValue) as bool? ??
              defaultValue,
          onChanged: (val) {
            box.put(keyName, val);
            onChanged?.call(val, box);
          },
        );
      },
    );
  }
}

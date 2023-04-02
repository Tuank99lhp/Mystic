import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mystic/API/mystic.dart';
import 'package:mystic/screens/more_page.dart';
import 'package:mystic/services/data_manager.dart';
import 'package:mystic/widgets/snackbar.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

String? downloadDirectory = Hive.box('settings').get('downloadPath');
Future<void> downloadSong(BuildContext context, dynamic song) async {
  try {
    if (!await checkDownloadDirectory(context)) {
      return;
    }

    final songName = path
        .basenameWithoutExtension(
          song['artist'] + ' ' + song['title'],
        )
        .replaceAll(
          RegExp(r'[^\w\s-]'),
          '',
        ) // remove non-alphanumeric characters except for hyphens and spaces
        .replaceAll(RegExp(r'(\s)+'), '-') // replace spaces with hyphens
        .toLowerCase();

    final filename = '$songName.${prefferedFileExtension.value}';

    final audio = await getSong(song['ytid'].toString());
    await FlutterDownloader.enqueue(
      url: audio,
      savedDir: downloadDirectory!,
      fileName: filename,
      showNotification: true,
      openFileFromNotification: true,
      headers: {
        'user-agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36',
        'cookie': 'CONSENT=YES+cb',
        'accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
        'accept-language': 'en-US,en;q=0.9',
        'sec-fetch-dest': 'document',
        'sec-fetch-mode': 'navigate',
        'sec-fetch-site': 'none',
        'sec-fetch-user': '?1',
        'sec-gpc': '1',
        'upgrade-insecure-requests': '1'
      },
    );
  } catch (e) {
    debugPrint('Error while downloading song: $e');
    ShowSnackBar().showSnackBar(
      context,
      '${AppLocalizations.of(context)!.downloadFailed}, $e',
      duration: const Duration(seconds: 2),
      noAction: true,
    );
  }
}

Future<void> checkNecessaryPermissions(BuildContext context) async {
  await Permission.audio.request();
  await Permission.notification.request();
  try {
    await Permission.storage.request();
  } catch (e) {
    ShowSnackBar().showSnackBar(
      context,
      '${AppLocalizations.of(context)!.errorWhileRequestingPerms} + $e',
      duration: const Duration(seconds: 2),
      noAction: true,
    );
  }
}

Future<bool> checkDownloadDirectory(BuildContext context) async {
  downloadDirectory ??= await FilePicker.platform.getDirectoryPath();

  if (downloadDirectory == null) {
    ShowSnackBar().showSnackBar(
      context,
      '${AppLocalizations.of(context)!.chooseDownloadDir}!',
      duration: const Duration(seconds: 2),
      noAction: true,
    );
    return false;
  }

  addOrUpdateData('settings', 'downloadPath', downloadDirectory);

  return true;
}

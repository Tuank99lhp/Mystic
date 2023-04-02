import 'package:flutter/material.dart';
import 'package:mystic/API/apis.dart';
import 'package:mystic/widgets/snackbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/download.dart';

class DownloadButton extends StatefulWidget {
  const DownloadButton({
    super.key,
    required this.data,
    this.icon,
    this.size,
  });
  final Map data;
  final String? icon;
  final double? size;

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

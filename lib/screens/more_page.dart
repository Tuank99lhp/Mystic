import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';

final useSystemColor = ValueNotifier<bool>(
  Hive.box('settings').get('useSystemColor', defaultValue: true),
);

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  @override
  Widget build(BuildContext context) {
    return ListView(physics: const BouncingScrollPhysics(), children: [
      AppBar(
        title: Text(
          AppLocalizations.of(context)!.more,
          style: TextStyle(
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      CustomTile(
        title: AppLocalizations.of(context)!.favorites,
        icon: Icons.favorite_rounded,
        onTap: () {
          Navigator.pushNamed(context, '/favorites');
        },
      ),
      CustomTile(
        title: AppLocalizations.of(context)!.localMusic,
        icon: FluentIcons.arrow_download_24_filled,
        onTap: () {
          Navigator.pushNamed(context, '/local');
        },
      ),
      CustomTile(
        title: AppLocalizations.of(context)!.download,
        icon: Icons.download_done_rounded,
        onTap: () {
          Navigator.pushNamed(context, '/downloads');
        },
      ),
      CustomTile(
        title: AppLocalizations.of(context)!.settings,
        icon: Icons.settings,
        onTap: () {
          Navigator.pushNamed(context, '/settings');
        },
      ),
    ]);
  }
}

class CustomTile extends StatelessWidget {
  const CustomTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).iconTheme.color,
        ),
      ),
      leading: Icon(
        icon,
        color: Theme.of(context).iconTheme.color,
      ),
      onTap: onTap,
    );
  }
}

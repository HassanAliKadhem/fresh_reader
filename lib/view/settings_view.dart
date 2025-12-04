import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api.dart';
import '../api/data_types.dart';
import '../widget/about_tile.dart';
import '../widget/settings_account_widgets.dart';
import '../widget/settings_widgets.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      insetPadding: EdgeInsets.symmetric(horizontal: 100.0, vertical: 50.0),
      child: SettingsPage(showClose: true),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, this.showClose = false});
  final bool showClose;
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        leading: widget.showClose
            ? IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close),
              )
            : null,
      ),
      body: SingleChildScrollView(child: SettingsContent()),
    );
  }
}

class SettingsContent extends StatefulWidget {
  const SettingsContent({super.key});

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.account_circle),
          title: Text("Add new account"),
          trailing: Icon(Icons.add),
          dense: true,
          onTap: () {
            showAdaptiveDialog(
              context: context,
              builder: (context) {
                return AddAccountDialog();
              },
            ).then((onValue) {
              if (onValue != null && onValue is Account) {
                if (context.mounted) {
                  try {
                    context.read<Api>().changeAccount(onValue);
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                } else {
                  debugPrint("Context not mounted");
                }
              }
              setState(() {});
            });
          },
        ),
        const AccountDetails(),
        const Divider(indent: 8.0, endIndent: 8.0),
        const ListTile(title: Text("Other settings"), dense: true),
        const ReadWhenOpenCheckTile(),
        const ShowLastSyncCheckTile(),
        const ListTile(title: Text("Theme"), dense: true),
        const ThemeSwitcherCard(),
        const ReadDurationTile(
          title: "Keep read articles",
          dbKey: "read_duration",
          values: durations,
        ),
        // const ReadDurationTile(
        //   title: "Keep starred articles",
        //   dbKey: "star_duration",
        //   values: amounts,
        // ),
        const Divider(indent: 8.0, endIndent: 8.0),
        AboutTile(),
      ],
    );
  }
}

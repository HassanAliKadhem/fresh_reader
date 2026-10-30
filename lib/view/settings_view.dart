import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/data.dart';
import '../api/data_types.dart';
import '../util/show_error.dart';
import '../widget/about_tile.dart';
import '../widget/settings_account_widgets.dart';
import '../widget/settings_widgets.dart';

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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        child: SettingsContent(),
      ),
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
        settingTile(
          "settings/accounts",
          "Manage accounts",
          "Add or modify accounts",
          Icons.account_circle,
        ),
        settingTile(
          "settings/behavior",
          "Behavior",
          "Modify application behaviors",
          Icons.tune,
        ),
        settingTile(
          "settings/theme",
          "Themes",
          "Change the app theme",
          Icons.design_services,
        ),
        const Divider(),
        AboutTile(),
        SizedBox(height: MediaQuery.viewPaddingOf(context).bottom),
      ],
    );
  }

  Widget settingTile(String key, String title, String subtitle, IconData icon) {
    return Card(
      clipBehavior: .hardEdge,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios),
        selected: context.select<DataProvider, bool>(
          (a) => a.settingsPage == key,
        ),
        onTap: () {
          context.read<DataProvider>().settingsPage = key;
        },
      ),
    );
  }
}

class ManageAccountPage extends StatefulWidget {
  const ManageAccountPage({super.key});

  @override
  State<ManageAccountPage> createState() => _ManageAccountPageState();
}

class _ManageAccountPageState extends State<ManageAccountPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text("Add new account"),
          trailing: const Icon(Icons.add),
          onTap: () {
            showAdaptiveDialog(
              context: context,
              builder: (context) {
                return AddAccountDialog();
              },
            ).then((newAccount) {
              if (newAccount != null && newAccount is Account) {
                if (context.mounted) {
                  try {
                    context.read<DataProvider>().changeAccount(newAccount);
                  } catch (e) {
                    showError(context, e.toString());
                  }
                } else {
                  debugPrint("Context not mounted");
                }
              }
              setState(() {});
            });
          },
        ),
        Divider(),
        const AccountDetails(),
      ],
    );
  }
}

class BehaviorSettingsPage extends StatelessWidget {
  const BehaviorSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ReadWhenOpenCheckTile(),
        const ShowLastSyncCheckTile(),
        const OpenInBrowserCheckTile(),
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
      ],
    );
  }
}

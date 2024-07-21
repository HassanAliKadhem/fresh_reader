import 'package:flutter/material.dart';

import '../api/api.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({
    super.key,
  });
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Server Url"),
            subtitle: Text(Api.of(context).server),
            onTap: () {
              showValueChangerDialog(
                context: context,
                title: "Server link",
                currentValue: Api.of(context).server,
              ).then((value) {
                if (value != null) {
                  Api.of(context).server = value;
                  Api.of(context).save();
                  setState(() {});
                }
              });
            },
          ),
          ListTile(
            title: const Text("Username"),
            subtitle: Text(Api.of(context).userName),
            onTap: () {
              showValueChangerDialog(
                context: context,
                title: "username",
                currentValue: Api.of(context).userName,
              ).then((value) {
                if (value != null) {
                  Api.of(context).userName = value;
                  Api.of(context).save();
                  setState(() {});
                }
              });
            },
          ),
          ListTile(
            title: const Text("Password"),
            subtitle: Text("*" * Api.of(context).password.length),
            onTap: () {
              showValueChangerDialog(
                context: context,
                title: "password",
                currentValue: Api.of(context).password,
                hide: true,
              ).then((value) {
                if (value != null) {
                  Api.of(context).password = value;
                  Api.of(context).save();
                  setState(() {});
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Future<dynamic> showValueChangerDialog({
    required BuildContext context,
    required String title,
    String currentValue = "",
    bool hide = false,
  }) {
    String newValue = currentValue;
    TextEditingController textEditingController =
        TextEditingController(text: newValue);
    return showDialog<String?>(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: textEditingController,
            obscureText: hide,
            onChanged: (value) => newValue = value,
          ),
          actions: [
            FilledButton(
                onPressed: () {
                  Navigator.pop(context, newValue);
                },
                child: const Text("Save")),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel")),
          ],
        );
      },
    );
  }
}

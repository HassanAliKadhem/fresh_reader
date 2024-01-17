import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'api.dart';

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
              showValueChangerDialog(context, Api.of(context).server)
                  .then((value) {
                if (value != null) {
                  Api.of(context).server = value;
                  Api.of(context).storageSave();
                  setState(() {});
                }
              });
            },
          ),
          ListTile(
            title: const Text("Username"),
            subtitle: Text(Api.of(context).userName),
            onTap: () {
              showValueChangerDialog(context, Api.of(context).userName)
                  .then((value) {
                if (value != null) {
                  Api.of(context).userName = value;
                  Api.of(context).storageSave();
                  setState(() {});
                }
              });
            },
          ),
          ListTile(
            title: const Text("Password"),
            subtitle: Text("*" * Api.of(context).password.length),
            onTap: () {
              showValueChangerDialog(context, Api.of(context).password)
                  .then((value) {
                if (value != null) {
                  Api.of(context).password = value;
                  Api.of(context).storageSave();
                  setState(() {});
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Future<dynamic> showValueChangerDialog(
      BuildContext context, String currentValue) {
    String newValue = currentValue;
    TextEditingController textEditingController =
        TextEditingController(text: newValue);
    return showDialog<String?>(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Change Server Url"),
          content: TextField(
            controller: textEditingController,
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

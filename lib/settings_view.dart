import 'package:flutter/material.dart';

import 'api.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({
    required this.api,
    super.key,
  });
  final Api api;
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
            subtitle: Text(widget.api.urlBase),
          ),
          ListTile(
            title: const Text("Username"),
            subtitle: Text(widget.api.userName),
          ),
          ListTile(
            title: const Text("Password"),
            subtitle: Text("*" * widget.api.password.length),
          ),
        ],
      ),
    );
  }
}

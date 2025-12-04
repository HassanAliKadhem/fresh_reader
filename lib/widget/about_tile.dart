import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutTile extends StatelessWidget {
  const AboutTile({super.key});

  @override
  Widget build(BuildContext context) {
    return AboutListTile(
      applicationVersion: "1.2.16",
      aboutBoxChildren: [
        const ListTile(
          title: Text("Made By"),
          subtitle: Text("Hasan Kadhem"),
          leading: Icon(Icons.person),
        ),
        const ListTile(
          title: Text("Made Using"),
          subtitle: Text("Flutter"),
          leading: FlutterLogo(),
        ),
        ListTile(
          title: const Text("Source Code"),
          subtitle: const Text(
            "https://github.com/HassanAliKadhem/fresh_reader",
          ),
          leading: const Icon(Icons.code),
          trailing: const Icon(Icons.open_in_browser),
          onTap: () => launchUrl(
            Uri.parse("https://github.com/HassanAliKadhem/fresh_reader"),
          ),
        ),
      ],
    );
  }
}

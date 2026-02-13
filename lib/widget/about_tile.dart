import 'package:flutter/material.dart';
import 'package:fresh_reader/util/open_link.dart';

const String gitHubUrl = "https://github.com/HassanAliKadhem/fresh_reader";
const String version = "v1.2.20";

class AboutTile extends StatelessWidget {
  const AboutTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("About Fresh Reader"),
      subtitle: Text(version),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationVersion: version,
          children: [
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
              subtitle: const Text(gitHubUrl),
              leading: const Icon(Icons.code),
              trailing: const Icon(Icons.open_in_browser),
              onTap: () => openLink(context, gitHubUrl),
            ),
          ],
        );
      },
    );
  }
}

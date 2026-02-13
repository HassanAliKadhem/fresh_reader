import 'package:flutter/widgets.dart';
import 'package:fresh_reader/api/preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

void openLink(BuildContext context, String link) async {
  launchUrl(
    Uri.parse(link),
    browserConfiguration: BrowserConfiguration(showTitle: true),
    mode: context.read<Preferences>().openInBrowser
        ? .externalApplication
        : .inAppBrowserView,
  );
}

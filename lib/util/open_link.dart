import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/preferences.dart';

void openLink(BuildContext context, String link) async {
  launchUrl(
    Uri.parse(link),
    browserConfiguration: BrowserConfiguration(showTitle: true),
    mode: context.read<Preferences>().openInBrowser
        ? .externalApplication
        : .inAppBrowserView,
  );
}

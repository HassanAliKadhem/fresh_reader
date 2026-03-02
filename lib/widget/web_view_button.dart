import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/preferences.dart';

class WebViewButton extends StatelessWidget {
  const WebViewButton({super.key});

  @override
  Widget build(BuildContext context) {
    bool showWebView = context.select<Preferences, bool>((p) => p.useWebView);
    return IconButton(
      onPressed: () {
        context.read<Preferences>().setUseWebView(!showWebView);
      },
      icon: showWebView
          ? Icon(Icons.article_outlined)
          : Icon(
              (Platform.isIOS || Platform.isMacOS)
                  ? CupertinoIcons.globe
                  : Icons.public,
            ),
      tooltip: showWebView ? "Article" : "Web",
    );
  }
}

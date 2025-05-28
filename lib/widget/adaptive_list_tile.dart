import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveListTile extends StatelessWidget {
  const AdaptiveListTile({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.onTap,
  });
  final String title;
  final Widget? leading;
  final Widget? trailing;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS || Platform.isMacOS) {
      return CupertinoListTile(
        title: Text(title),
        leading: leading,
        trailing: trailing,
        onTap: onTap,
      );
    } else {
      return ListTile(
        title: Text(title),
        leading: leading,
        trailing: trailing,
        onTap: onTap,
      );
    }
  }
}

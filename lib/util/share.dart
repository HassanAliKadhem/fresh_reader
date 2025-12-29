import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

void shareLink(BuildContext context, String link, String? subject) {
  try {
    final box = context.findRenderObject() as RenderBox?;
    SharePlus.instance.share(
      ShareParams(
        uri: Uri.parse(link),
        subject: subject,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      ),
    );
  } catch (e) {
    debugPrint(e.toString());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString(), maxLines: 3), showCloseIcon: true),
    );
  }
}

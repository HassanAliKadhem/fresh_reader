import 'package:flutter/material.dart';

Future<void> showError(BuildContext context, String error) async {
  debugPrint(error);
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Error"),
        scrollable: true,
        content: Text(error),
      );
    },
  );
}

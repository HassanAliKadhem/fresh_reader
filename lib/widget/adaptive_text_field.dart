import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveTextField extends StatelessWidget {
  const AdaptiveTextField({
    super.key,
    this.label = "",
    this.onChanged,
    this.initialValue,
    this.inputType,
    this.obscureText,
  });
  final String label;
  final Function(String)? onChanged;
  final String? initialValue;
  final TextInputType? inputType;
  final bool? obscureText;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: CupertinoColors.darkBackgroundGray),
    );
    return SizedBox(
      height: Platform.isIOS ? 36.0 : null,
      child: TextField(
        decoration: Platform.isIOS
            ? InputDecoration(
                border: border,
                enabledBorder: border,
                focusedBorder: border,
                filled: true,
                prefixIcon: Text(
                  "  $label ",
                  style: TextStyle(
                    color: CupertinoColors.inactiveGray,
                    height: 2.7,
                  ),
                ),
                // fillColor: CupertinoColors.black,
                // hoverColor: CupertinoColors.black,
                contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
              )
            : InputDecoration(
                label: Text(label),
              ),
        obscureText: obscureText ?? false,
        controller: TextEditingController(text: initialValue),
        onChanged: onChanged,
      ),
    );
  }
}

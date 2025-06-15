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
    if (Platform.isIOS || Platform.isMacOS) {
      return CupertinoTextField(
        placeholder: label,
        obscureText: obscureText ?? false,
        controller: TextEditingController(text: initialValue),
        onChanged: onChanged,
      );
    } else {
      return TextField(
        decoration: InputDecoration(label: Text(label)),
        obscureText: obscureText ?? false,
        controller: TextEditingController(text: initialValue),
        onChanged: onChanged,
      );
    }
  }
}

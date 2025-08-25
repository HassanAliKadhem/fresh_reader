import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:fresh_reader/api/database.dart';

class Formatting extends InheritedNotifier<FormattingSetting> {
  const Formatting({super.key, required super.child, required super.notifier});

  static FormattingSetting of(BuildContext context) {
    assert(
      context.dependOnInheritedWidgetOfExactType<Formatting>() != null,
      "Formatting not found in current context",
    );
    return context.dependOnInheritedWidgetOfExactType<Formatting>()!.notifier!;
  }

  @override
  bool updateShouldNotify(
    covariant InheritedNotifier<FormattingSetting> oldWidget,
  ) {
    return notifier != oldWidget.notifier;
  }
}

class FormattingSetting extends ChangeNotifier {
  double fontSize = 14.0;
  double wordSpacing = 0.0;
  double lineHeight = 1.5;
  String font = (Platform.isIOS || Platform.isMacOS) ? ".SF UI Text" : "Roboto";
  List<String> fonts = [
    (Platform.isIOS || Platform.isMacOS) ? ".SF UI Text" : "Roboto",
    if (Platform.isIOS || Platform.isMacOS) "Arial",
    "Courier",
    "Times New Roman",
  ];
  bool isLetterHighlight = false;

  FormattingSetting() {
    load();
  }

  void load() async {
    fontSize =
        double.tryParse(await getPreference("format_fontSize") ?? "") ??
        fontSize;
    wordSpacing =
        double.tryParse(await getPreference("format_wordSpacing") ?? "") ??
        wordSpacing;
    lineHeight =
        double.tryParse(await getPreference("format_lineHeight") ?? "") ??
        lineHeight;
    font = await getPreference("format_font") ?? font;
    isLetterHighlight = (await getPreference("format_bionic") == "true");
    notifyListeners();
  }

  void save() async {
    setPreference("format_fontSize", fontSize.toString());
    setPreference("format_wordSpacing", wordSpacing.toString());
    setPreference("format_lineHeight", lineHeight.toString());
    setPreference("format_font", font);
    setPreference(
      "format_letterHighlight",
      isLetterHighlight ? "true" : "false",
    );
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    save();
  }

  void setSize(double newSize) {
    fontSize = newSize;
    notifyListeners();
  }

  void setSpacing(double newSpacing) {
    wordSpacing = newSpacing;
    notifyListeners();
  }

  void setLineHeight(double newHeight) {
    lineHeight = newHeight;
    notifyListeners();
  }

  void setFontFamily(String newFont) {
    font = newFont;
    notifyListeners();
  }

  void setIsLetterHighlight(bool newIs) {
    isLetterHighlight = newIs;
    notifyListeners();
  }
}

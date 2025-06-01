import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormattingSetting extends ChangeNotifier {
  double fontSize = 14.0;
  double wordSpacing = 0.0;
  double lineHeight = 1.5;
  String font = "Arial";
  List<String> fonts = [
    Platform.isIOS || Platform.isMacOS ? "SF UI Text" : "Roboto",
    if (Platform.isIOS || Platform.isMacOS) "Arial",
    "Courier",
    "Times New Roman",
  ];
  bool isBionic = false;

  FormattingSetting() {
    load();
  }

  void load() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    fontSize = preferences.getDouble("format_fontSize") ?? fontSize;
    wordSpacing = preferences.getDouble("format_wordSpacing") ?? wordSpacing;
    lineHeight = preferences.getDouble("format_lineHeight") ?? lineHeight;
    String? newFont = preferences.getString("format_font");
    if (newFont != null) {
      font = newFont;
    }
    isBionic = preferences.getBool("format_bionic") ?? isBionic;
    notifyListeners();
  }

  void save() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setDouble("format_fontSize", fontSize);
    preferences.setDouble("format_wordSpacing", wordSpacing);
    preferences.setDouble("format_lineHeight", lineHeight);
    preferences.setString("format_font", font);
    preferences.setBool("format_bionic", isBionic);
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

  void setIsBionic(bool newIs) {
    isBionic = newIs;
    notifyListeners();
  }
}

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../api/database.dart';
import '../main.dart';

class FormattingSetting extends ChangeNotifier {
  double fontSize = 14.0;
  double wordSpacing = 0.0;
  double lineHeight = 1.5;
  String font = "Arial";
  List<String> fonts = [
    Platform.isAndroid ? "Roboto" : "SF UI",
    "Arial",
    "Courier",
    "Times New Roman",
  ];
  bool isBionic = false;

  FormattingSetting() {
    database.select(database.settings).getSingle().then(
      (settings) {
        fontSize = settings.fontSize;
        wordSpacing = settings.wordSpacing;
        lineHeight = settings.lineHeight;
        isBionic = settings.isBionic;
        font = settings.font;
      },
    );
    // notifyListeners();
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    (database.update(database.settings)
          ..where(
            (tbl) => tbl.id.equals(1),
          ))
        .write(SettingsCompanion.insert(
      fontSize: Value(fontSize),
      wordSpacing: Value(wordSpacing),
      lineHeight: Value(lineHeight),
      font: Value(font),
      isBionic: Value(isBionic),
    ));
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

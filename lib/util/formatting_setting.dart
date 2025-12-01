import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/widgets.dart';

import '../api/database.dart';

enum MyTheme { dark, amoled }

class Preferences extends ChangeNotifier {
  final DB database;

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
  int? readDuration;
  int? starDuration;
  bool markReadWhenOpen = true;
  bool showLastSync = false;
  int themeIndex = 0;

  Preferences(this.database) {
    load();
  }

  void load() async {
    fontSize =
        double.tryParse(
          await database.getPreference("format_fontSize") ?? "",
        ) ??
        fontSize;
    wordSpacing =
        double.tryParse(
          await database.getPreference("format_wordSpacing") ?? "",
        ) ??
        wordSpacing;
    lineHeight =
        double.tryParse(
          await database.getPreference("format_lineHeight") ?? "",
        ) ??
        lineHeight;
    font = await database.getPreference("format_font") ?? font;
    isLetterHighlight =
        (await database.getPreference("format_bionic") == "true");
    markReadWhenOpen =
        ((await database.getPreference("read_when_open") ?? "true") == "true");
    showLastSync =
        ((await database.getPreference("show_last_sync") ?? "false") == "true");
    themeIndex =
        int.tryParse(await database.getPreference("theme_index") ?? "") ?? 0;
    readDuration = int.tryParse(
      await database.getPreference("read_duration") ?? "",
    );
    starDuration = int.tryParse(
      await database.getPreference("star_duration") ?? "",
    );
    // debugPrint("readDuration: $readDuration");
    if (readDuration != null && readDuration != -1) {
      // delete old image caches
      debugPrint("Clear cache older than $readDuration days.");
      clearDiskCachedImages(duration: Duration(days: readDuration!)).then((
        done,
      ) {
        debugPrint("Clear cache successful: $done");
      });
    }
    notifyListeners();
  }

  void save() {
    database.setPreference("format_fontSize", fontSize.toString());
    database.setPreference("format_wordSpacing", wordSpacing.toString());
    database.setPreference("format_lineHeight", lineHeight.toString());
    database.setPreference("format_font", font);
    database.setPreference(
      "format_letterHighlight",
      isLetterHighlight ? "true" : "false",
    );
    database.setPreference(
      "read_when_open",
      markReadWhenOpen ? "true" : "false",
    );
    database.setPreference("show_last_sync", showLastSync ? "true" : "false");
    database.setPreference("theme_index", themeIndex.toString());
    database.setPreference("read_duration", readDuration.toString());
    database.setPreference("star_duration", starDuration.toString());
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    save();
  }

  void setMarkReadWhenOpen(bool val) {
    markReadWhenOpen = val;
    notifyListeners();
  }

  void setShowLastSync(bool val) {
    showLastSync = val;
    notifyListeners();
  }

  void setThemeIndex(int index) {
    themeIndex = index;
    notifyListeners();
  }

  void setReadDuration(int? duration) {
    readDuration = duration;
    notifyListeners();
  }

  void setStarDuration(int? duration) {
    starDuration = duration;
    notifyListeners();
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

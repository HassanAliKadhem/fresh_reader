import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/widgets.dart';

import 'database.dart';

class Preferences extends ChangeNotifier {
  final StorageBase database;

  double fontSize = 14.0;
  double wordSpacing = 0.0;
  double lineHeight = 1.5;
  late String font = fonts.first;
  List<String> fonts = [
    ...(Platform.isIOS || Platform.isMacOS)
        ? [".SF UI Text", "Arial"]
        : ["Roboto"],
    "Courier",
    "Times New Roman",
  ];
  bool isLetterHighlight = false;
  int? readDuration;
  int? starDuration;
  bool markReadWhenOpen = true;
  bool showLastSync = false;
  int themeIndex = 0;

  Preferences(this.database);

  Future<void> load() async {
    fontSize = (await _tryGetDouble("format_fontSize")) ?? fontSize;
    wordSpacing = (await _tryGetDouble("format_wordSpacing")) ?? wordSpacing;
    lineHeight = (await _tryGetDouble("format_lineHeight")) ?? lineHeight;
    font = await database.getPreference("format_font") ?? font;
    isLetterHighlight = (await _tryGetBool("format_bionic")) ?? false;
    markReadWhenOpen = (await _tryGetBool("read_when_open")) ?? true;
    showLastSync = (await _tryGetBool("show_last_sync")) ?? false;
    themeIndex = (await _tryGetInt("theme_index")) ?? 0;
    readDuration = (await _tryGetInt("read_duration"));
    starDuration = (await _tryGetInt("star_duration"));
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
  }

  void save() {
    database.setPreference("format_fontSize", fontSize.toString());
    database.setPreference("format_wordSpacing", wordSpacing.toString());
    database.setPreference("format_lineHeight", lineHeight.toString());
    database.setPreference("format_font", font);
    setBool("format_letterHighlight", isLetterHighlight);
    setBool("read_when_open", markReadWhenOpen);
    setBool("show_last_sync", showLastSync);
    database.setPreference("theme_index", themeIndex.toString());
    database.setPreference("read_duration", readDuration.toString());
    database.setPreference("star_duration", starDuration.toString());
  }

  Future<double?> _tryGetDouble(String key) async {
    return double.tryParse(await database.getPreference(key) ?? "");
  }

  Future<int?> _tryGetInt(String key) async {
    return int.tryParse(await database.getPreference(key) ?? "");
  }

  Future<bool?> _tryGetBool(String key) async {
    String? val = await database.getPreference(key);
    if (val == null) {
      return null;
    } else {
      return val == "true";
    }
  }

  Future<void> setBool(String key, bool value) async {
    await database.setPreference(key, value ? "true" : "false");
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

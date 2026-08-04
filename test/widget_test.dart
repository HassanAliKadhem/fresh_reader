// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_reader/api/data_types.dart';
import 'package:fresh_reader/widget/unread_count.dart';
import 'package:provider/provider.dart';

import 'package:fresh_reader/api/data.dart';
import 'package:fresh_reader/api/database.dart';
import 'package:fresh_reader/api/preferences.dart';
import 'package:fresh_reader/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> loadSampleData(StorageBase db) async {
  await db.addAccount(
    Account(
      1,
      "http://localhost:8080",
      getAccountString(AccountType.test),
      "test",
      "test",
      0,
      0,
    ),
  );
  await db.insertCategories([
    Category(catID: "catID/Gaming", accountID: 1, name: "Gaming"),
  ], 1);

  await db.insertSubscriptions([
    Subscription(
      subID: "subID/testFeed",
      catID: "catID/Gaming",
      accountID: 1,
      title: "test feed",
      url: "http://google.com",
      htmlUrl: "http://google.com",
      iconUrl: "http://google.com",
    ),
  ]);

  await db.insertArticles([
    Article(
      articleID: "articleID_1",
      subID: "subID/testFeed",
      accountID: 1,
      title: "First article",
      read: false,
      starred: false,
      published: 0,
      content: "Hello world",
      url: "http://google.com/first",
    ),
  ]);
}

Future<MultiProvider> prepare() async {
  sqfliteFfiInit();
  databaseFactoryOrNull = databaseFactoryFfiNoIsolate;
  var database = await databaseFactoryOrNull!.openDatabase(
    inMemoryDatabasePath,
  );
  for (var cmd in [
    subTable,
    catTable,
    artTable,
    delTable,
    accTable,
    prefTable,
    lastSyncTable,
  ]) {
    await database.execute(cmd);
  }
  var db = StorageSqlite(database);
  await loadSampleData(db);
  print("loaded sample data");

  var pref = Preferences(db);
  var provider = DataProvider(db);
  provider.changeAccount(await db.getAccount(1));
  await pref.load();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<DataProvider>(create: (context) => provider),
      ChangeNotifierProvider<Preferences>(create: (context) => pref),
    ],
    child: MyApp(),
  );
}

void main() {
  testWidgets('Test open database', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(await prepare());
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, "All Articles"),
        matching: find.widgetWithText(UnreadCount, "1"),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, "Today"),
        matching: find.widgetWithText(UnreadCount, "0"),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, "Starred"),
        matching: find.widgetWithText(UnreadCount, "0"),
      ),
      findsOneWidget,
    );
  });
}

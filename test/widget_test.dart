// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_reader/api/data_types.dart';
import 'package:fresh_reader/widget/article_tile.dart';
import 'package:fresh_reader/widget/unread_count.dart';
import 'package:provider/provider.dart';

import 'package:fresh_reader/api/data.dart';
import 'package:fresh_reader/api/database.dart';
import 'package:fresh_reader/api/preferences.dart';
import 'package:fresh_reader/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> loadSampleData(StorageSqlite db) async {
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

Future<StorageSqlite> getTestDatabase() async {
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
  return db;
}

Future<MultiProvider> prepare(StorageSqlite db) async {
  var pref = Preferences(db);
  await pref.load();
  var provider = DataProvider(db);
  await provider.changeAccount(await db.getAccount(1));
  await pref.load();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<DataProvider>(create: (context) => provider),
      ChangeNotifierProvider<Preferences>(create: (context) => pref),
    ],
    child: MyApp(),
  );
}

void main() async {
  var db = await getTestDatabase();
  testWidgets('Test open database', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(await prepare(db));
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
    print("opened database successfully");
  });

  testWidgets("Test Mark as read and unread", (WidgetTester tester) async {
    await tester.pumpWidget(await prepare(db));
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, "All Articles"),
        matching: find.widgetWithText(UnreadCount, "1"),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text("All Articles"));
    await tester.pump();
    expect(find.byKey(ValueKey("Dismissible_articleID_1")), findsOneWidget);
    await tester.tap(find.byKey(ValueKey("Dismissible_articleID_1")));
    await tester.pump();
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, "All Articles"),
        matching: find.widgetWithText(UnreadCount, "0"),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip("Read"));
    await tester.pump();
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, "All Articles"),
        matching: find.widgetWithText(UnreadCount, "1"),
      ),
      findsOneWidget,
    );
    print("marked as read successfully");
  });

  testWidgets("Test Mark as starred", (WidgetTester tester) async {
    await tester.pumpWidget(await prepare(db));
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, "Starred"),
        matching: find.widgetWithText(UnreadCount, "0"),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text("All Articles"));
    await tester.pump();
    expect(find.byKey(ValueKey("Dismissible_articleID_1")), findsOneWidget);
    await tester.tap(find.byKey(ValueKey("Dismissible_articleID_1")));
    await tester.pump();
    await tester.tap(find.byTooltip("Star"));
    await tester.tap(find.byTooltip("Read"));
    await tester.pump();
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, "Starred"),
        matching: find.widgetWithText(UnreadCount, "1"),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip("Star"));
    await tester.pump();
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, "Starred"),
        matching: find.widgetWithText(UnreadCount, "0"),
      ),
      findsOneWidget,
    );
    print("marked as starred successfully");
  });

  testWidgets("Test Search", (WidgetTester tester) async {
    await tester.pumpWidget(await prepare(db));
    await tester.tap(find.text("All Articles"));
    await tester.pump();
    expect(find.byKey(ValueKey("Dismissible_articleID_1")), findsOneWidget);
    await tester.enterText(find.byKey(ValueKey("searchBar")), 'nothing');
    await tester.pump();
    expect(find.byKey(ValueKey("Dismissible_articleID_1")), findsNothing);
    await tester.enterText(find.byKey(ValueKey("searchBar")), '');
    await tester.pump();
    expect(find.byKey(ValueKey("Dismissible_articleID_1")), findsOneWidget);
    await tester.enterText(find.byKey(ValueKey("searchBar")), 'random');
    await tester.pump();
    expect(find.byKey(ValueKey("Dismissible_articleID_1")), findsNothing);
    await tester.enterText(find.byKey(ValueKey("searchBar")), 'Hello world');
    await tester.pump();
    expect(find.byKey(ValueKey("Dismissible_articleID_1")), findsOneWidget);
    print("search test successful");
  });

  testWidgets("Test switch feed", (WidgetTester tester) async {
    await tester.pumpWidget(await prepare(db));
    await tester.tap(find.text("All Articles"));
    await tester.pump();
    expect(find.byType(ArticleTile), findsOneWidget);
    await tester.tap(find.byTooltip("Back"));
    await tester.pump();
    await tester.tap(find.text("Starred"));
    await tester.pump();
    expect(find.byType(ArticleTile), findsNothing);
    await tester.tap(find.byTooltip("Back"));
    await tester.pump();
    await tester.tap(find.text("test feed"));
    await tester.pump();
    expect(find.byType(ArticleTile), findsOneWidget);
    await tester.tap(find.byTooltip("Back"));
    await tester.pump();
    await tester.tap(find.text("Today"));
    await tester.pump();
    expect(find.byType(ArticleTile), findsNothing);
    print("switch feed test successful");
  });
}

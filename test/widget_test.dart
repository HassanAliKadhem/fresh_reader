// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_reader/api/data_types.dart';
import 'package:provider/provider.dart';

import 'package:fresh_reader/api/data.dart';
import 'package:fresh_reader/api/database.dart';
import 'package:fresh_reader/api/preferences.dart';
import 'package:fresh_reader/main.dart';

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

Future<MultiProvider> prepare() async {
  var db = StorageSqlite(await getDatabase());
  await loadSampleData(db);
  print("loaded sample data");

  var pref = Preferences(db);
  await pref.load();
  print("Load preferences");
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<DataProvider>(
        create: (context) => DataProvider(db),
      ),
      ChangeNotifierProvider<Preferences>(create: (context) => pref),
    ],
    child: MyApp(),
  );
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(await prepare());
    // Verify that our counter starts at 0.
    print("Hello");
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

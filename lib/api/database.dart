import 'package:drift/drift.dart';
import 'package:drift/internal/versioned_schema.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:fresh_reader/api/database.steps.dart';

part 'database.g.dart';

@DriftDatabase(
    tables: [Account, Category, Subscription, Article, Delayed, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'my_database');
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        // Following the advice from https://drift.simonbinder.eu/Migrations/api/#general-tips
        await customStatement('PRAGMA foreign_keys = OFF');

        await transaction(
          () => VersionedSchema.runMigrationSteps(
            migrator: m,
            from: from,
            to: to,
            steps: _upgrade,
          ),
        );

        if (kDebugMode) {
          final wrongForeignKeys =
              await customSelect('PRAGMA foreign_key_check').get();
          assert(wrongForeignKeys.isEmpty,
              '${wrongForeignKeys.map((e) => e.data)}');
        }

        await customStatement('PRAGMA foreign_keys = ON');
      },
      beforeOpen: (details) async {
        // For Flutter apps, this should be wrapped in an if (kDebugMode) as
        // suggested here: https://drift.simonbinder.eu/Migrations/tests/#verifying-a-database-schema-at-runtime
        await validateDatabaseSchema();
      },
    );
  }

  static final _upgrade = migrationSteps(
    from1To2: (m, schema) async {
      // Migration from 1 to 2: Add name column in users. Use "no name"
      // as a default value.
      await m.createTable(schema.settings);
      // await m.alterTable(
      //   TableMigration(
      //     schema.settings,
      //     newColumns: [
      //       schema.settings.accountId,
      //       schema.settings.font,
      //       schema.settings.lineHeight,
      //       schema.settings.fontSize,
      //       schema.settings.wordSpacing,
      //       schema.settings.isBionic,
      //     ],
      //   ),
      // );
    },
  );
}

class Settings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer().nullable()();
  RealColumn get fontSize => real().withDefault(const Constant(14.0))();
  RealColumn get lineHeight => real().withDefault(const Constant(1.5))();
  RealColumn get wordSpacing => real().withDefault(const Constant(0.0))();
  TextColumn get font => text().withDefault(const Constant("Arial"))();
  BoolColumn get isBionic => boolean().withDefault(const Constant(false))();
}

class Account extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get provider => text()();
  TextColumn get serverUrl => text()();
  TextColumn get userName => text()();
  TextColumn get password => text()();
  IntColumn get updatedArticleTime => integer()();
  IntColumn get updatedStarredTime => integer()();
}

class Category extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverID => text()();
  IntColumn get account => integer().references(Account, #id)();
  TextColumn get title => text()();
  TextColumn get catUrl => text()();
  // IntColumn get subscription => integer().references(Subscription, #id)();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
        {serverID, account}
      ];

  // Category.fromJson(
  //     Map<String, dynamic> json, this.persistentModelID, this.accountId)
  //     : serverID = json['id'] ?? "",
  //       title = tryDecode((json['title'] ?? "").toString()) ?? json['title'],
  //       catID = json["url"] ?? "",
  //       subID = json["htmlUrl"] ?? "";
}

class Subscription extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverID => text()();
  IntColumn get account => integer().references(Account, #id)();
  IntColumn get category => integer().nullable().references(Category, #id)();
  TextColumn get title => text()();
  TextColumn get url => text()();
  TextColumn get htmlUrl => text()();
  TextColumn get iconUrl => text()();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
        {serverID, account}
      ];

  // Subscription.fromJson(Map<String, dynamic> json, this.persistentModelID,
  //     this.categoryId, this.accountId)
  //     : id = json['id'] ?? "",
  //       title = tryDecode((json['title'] ?? "").toString()) ?? json['title'],
  //       url = json["url"] ?? "",
  //       htmlUrl = json["htmlUrl"] ?? "",
  //       iconUrl = json["iconUrl"] ?? "";
}

class Article extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverID => text()();
  IntColumn get subscription => integer().references(Subscription, #id)();
  IntColumn get account => integer().references(Account, #id)();
  TextColumn get title => text()();
  TextColumn get url => text()();
  TextColumn get content => text()();
  TextColumn get image => text().nullable()();
  IntColumn get published => integer()();
  BoolColumn get read => boolean()();
  BoolColumn get starred => boolean()();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
        {serverID, account, subscription}
      ];

  // Article.fromCloudJson(Map<String, dynamic> json, this.persistentModelID,
  //     this.accountId, this.subscriptionId)
  //     : id = json["id"],
  //       title = tryDecode(json["title"].toString()) ?? json["title"].toString(),
  //       read = json["read"] ?? false,
  //       starred = false,
  //       published = json["published"],
  //       content = tryDecode(json["summary"]["content"].toString()) ??
  //           json["summary"]["content"].toString(),
  //       url = (json["canonical"])[0]["href"] as String,
  //       image = getFirstImage(json["summary"]["content"].toString());
}

enum DelayedAction { unread, read, star, unStar }

// DelayedAction (id INTEGER PRIMARY KEY, articleID TEXT , action INTEGER)
class Delayed extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get account => integer().references(Account, #id)();
  IntColumn get article => integer().references(Article, #id)();
  IntColumn get action => integer()();
}

enum ScreenSize { big, medium, small }

String? getFirstImage(String content) {
  RegExpMatch? match = RegExp('(?<=src=")(.*?)(?=")').firstMatch(content);
  if (match?[0] == null) {
    for (RegExpMatch newMatch
        in RegExp('(?<=href=")(.*?)(?=")').allMatches(content)) {
      if (newMatch[0]!.endsWith(".jpg") ||
          newMatch[0]!.endsWith(".JPG") ||
          newMatch[0]!.endsWith(".JPEG") ||
          newMatch[0]!.endsWith(".jpeg") ||
          newMatch[0]!.endsWith(".png") ||
          newMatch[0]!.endsWith(".PNG") ||
          newMatch[0]!.endsWith(".webp") ||
          newMatch[0]!.endsWith(".gif")) {
        return newMatch[0]!;
      }
    }
  }
  return match?[0];
}

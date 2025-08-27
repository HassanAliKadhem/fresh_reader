import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'api.dart';
import 'data_types.dart';
import '../main.dart';

const subTable =
    "CREATE TABLE Subscriptions (id INTEGER PRIMARY KEY, accountID INTEGER, subID TEXT, catID TEXT, title TEXT, url TEXT, htmlUrl TEXT, iconUrl TEXT, UNIQUE(subID, accountID))";
const catTable =
    'CREATE TABLE Categories (id INTEGER PRIMARY KEY, accountID INTEGER, catID TEXT, name TEXT, UNIQUE(catID, accountID))';
const artTable =
    'CREATE TABLE Articles (id INTEGER PRIMARY KEY, accountID INTEGER, articleID TEXT, subID TEXT, title TEXT, isRead TEXT, isStarred TEXT, img TEXT, timeStampPublished INTEGER, content TEXT, url TEXT, UNIQUE(articleID, subID, accountID))';
const delTable =
    'CREATE TABLE DelayedActions (id INTEGER PRIMARY KEY, accountID INTEGER, articleID TEXT, action INTEGER, UNIQUE(articleID, accountID, action))';
const accTable =
    "CREATE TABLE Account (id INTEGER PRIMARY KEY, serverUrl TEXT, provider TEXT, username TEXT, password TEXT, updatedArticleTime INTEGER, updatedStarredTime INTEGER)";
const prefTable = "create table preferences (key TEXT primary key, value TEXT)";

const _indexes = [
  "CREATE INDEX if not exists idx_article_id ON articles (articleID)",
  "CREATE INDEX if not exists idx_article_subid ON articles (subID)",
  "CREATE INDEX if not exists idx_article_accid ON articles (accountID)",
];

Future<Database> getDatabase() async {
  return await openDatabase(
    'my_db.db',
    version: 8,
    onConfigure: (db) {
      db.execute("PRAGMA journal_mode = WAL;");
      db.execute("PRAGMA synchronous = NORMAL;");
    },
    onCreate: (db, version) async {
      await db.execute(accTable);
      await db.execute(subTable);
      await db.execute(catTable);
      await db.execute(artTable);
      await db.execute(delTable);
      await db.execute(prefTable);

      // create indexes for articles table
      for (var ind in _indexes) {
        await db.execute(ind);
      }
    },
    // onOpen: (db) async {
    //   if ((await db.getVersion()) < 8) {
    //     await db.execute(prefTable);
    //   }
    // },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion == 1 && newVersion == 2) {
        await db.execute('ALTER TABLE Article add column isStarred TEXT');
        await db.update("Article", {"isStarred": "false"});
      } else if (oldVersion == 2 && newVersion == 3) {
        await db.execute('ALTER TABLE Article add column img TEXT');
        List<Map<String, Object?>> articleContents = await db.query(
          "Article",
          columns: ["id", "content"],
        );
        for (var i = 0; i < articleContents.length; i++) {
          await db.update(
            "Article",
            {
              "img":
                  getFirstImage(articleContents[i]["content"] as String) ?? "",
            },
            where: "id = ?",
            whereArgs: [articleContents[i]["id"]],
          );
        }
      } else if (oldVersion == 3 && newVersion == 4) {
        await db.execute(accTable);
        final preferences = await SharedPreferences.getInstance();
        int? accountID;
        if (preferences.containsKey("server")) {
          accountID = await db.insert("Account", {
            "serverUrl": preferences.getString("server"),
            "username": preferences.getString("userName") ?? "",
            "password": preferences.getString("password") ?? "",
            "provider": "freshrss",
            "updatedArticleTime": preferences.getInt("updatedArticleTime") ?? 0,
            "updatedStarredTime": preferences.getInt("updatedStarredTime") ?? 0,
          });
          debugPrint("added account: $accountID");
        }
        if (accountID != null) {
          await db.execute(artTable);
          await db.execute(
            '''INSERT INTO Articles
             (accountID, articleID, subID, title, isRead, isStarred, img, timeStampPublished, content, url) 
             SELECT $accountID as accountID, articleID, subID, title, isRead, isStarred, img, timeStampPublished, content, url FROM Article;''',
          );
          await db.execute("DROP TABLE Article;");

          await db.execute(subTable);
          await db.execute(
            '''INSERT INTO Subscriptions
             (accountID, subID, title, url, htmlUrl, iconUrl) 
             SELECT $accountID as accountID, subID, title, url, htmlUrl, iconUrl FROM Subscription;''',
          );
          await db.execute("DROP TABLE Subscription");

          await db.execute(catTable);
          await db.execute(
            '''INSERT INTO Categories
             (accountID, catID, subID, name) 
             SELECT $accountID as accountID, catID, subID, name FROM Category;''',
          );
          await db.execute("DROP TABLE Category");

          await db.execute(delTable);
          await db.execute(
            '''INSERT INTO DelayedActions
             (accountID, articleID, action) 
             SELECT $accountID as accountID, articleID, action FROM DelayedAction;''',
          );
          await db.execute("DROP TABLE DelayedAction");
        }
        debugPrint("Finished upgrading db to: version 4");
      } else if (oldVersion == 4 && newVersion == 5) {
        await db.execute("ALTER TABLE Subscriptions add column catID TEXT");
        debugPrint("Finished upgrading db to: version 5");
      } else if (oldVersion == 6 && newVersion == 7) {
        try {
          await db.execute("drop table preferences");
        } catch (_) {}
        await db.execute(
          "create table preferences (key TEXT primary key, value TEXT)",
        );
        debugPrint("Finished upgrading db to: version 7");
      } else if (oldVersion == 7 && newVersion == 8) {
        // create indexes for articles table
        for (var ind in _indexes) {
          await db.execute(ind);
        }
        debugPrint("Finished upgrading db to: version 8");
      }
    },
    // singleInstance: true,
  );
}

Future<String?> getPreference(String key) async {
  var res = await database.query(
    "preferences",
    where: "key = ?",
    whereArgs: [key],
    limit: 1,
  );
  return res.isEmpty ? null : res.first["value"] as String;
}

void setPreference(String key, String value) async {
  await database.insert("preferences", {
    "key": key,
    "value": value,
  }, conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<Map<String, Subscription>> loadAllSubs(int accountID) async {
  return (await database.query(
    "Subscriptions",
    columns: [
      "subID",
      "accountID",
      "catID",
      "title",
      "url",
      "htmlUrl",
      "iconUrl",
    ],
    where: "accountID = ?",
    whereArgs: [accountID],
  )).asMap().map(
    (key, element) =>
        MapEntry(element["subID"] as String, Subscription.fromDB(element)),
  );
}

Future<Map<String, Category>> loadAllCategory(int accountID) async {
  return (await database.query(
    "Categories",
    where: "accountID = ?",
    whereArgs: [accountID],
  )).asMap().map(
    (key, element) =>
        MapEntry(element["catID"] as String, Category.fromMap(element)),
  );
}

void saveSubs(List<Subscription> subs) {
  final Batch batch = database.batch();
  for (var sub in subs) {
    batch.insert(
      "Subscriptions",
      sub.toDB(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  batch.commit(continueOnError: true);
}

Future<Article> loadArticle(String articleID, int accountID) async {
  return Article.fromDB(
    (await database.query(
      "Articles",
      where: "articleID = ? and accountID = ?",
      whereArgs: [articleID, accountID],
      limit: 1,
    )).first,
  );
}

Future<List<Article>> loadArticles(
  List<String> articleIDs,
  int accountID,
) async {
  return (await database.rawQuery(
    "select articleID ,subID, accountID, title, isRead, isStarred, timeStampPublished, url, img from Articles where accountID = $accountID and articleID in ('${articleIDs.join("','")}') order by timeStampPublished desc",
  )).map((article) => Article.fromDB(article)).toList();
}

Future<Article> loadArticleContent(Article article, int accountID) async {
  var res = await database.query(
    "Articles",
    columns: ["content"],
    where: "articleID = ? and accountID = ?",
    whereArgs: [article.articleID, accountID],
    limit: 1,
  );
  article.content =
      (res.first.values.first != null ? res.first.values.first as String : "");
  return article;
}

Future<String?> loadArticleSubID(String articleID, int accountID) async {
  List<Map<String, Object?>> result = await database.query(
    "Articles",
    columns: ["subID"],
    where: "articleID = ? and accountID = ?",
    whereArgs: [articleID, accountID],
    orderBy: "timeStampPublished DESC",
    limit: 1,
  );
  return result.isNotEmpty ? result.first.values.first as String : null;
}

Future<Map<String, String>> loadArticleSubIDs(
  List<String> articleIDs,
  int accountID,
) async {
  return (await database.query(
    "Articles",
    columns: ["articleID", "subID"],
    where: "articleID in ? and accountID = ?",
    whereArgs: [articleIDs, accountID],
  )).asMap().map(
    (i, entry) =>
        MapEntry(entry["articleID"] as String, entry["subID"] as String),
  );
}

Future<Map<String, int>> countAllArticles(bool showAll, int accountID) async {
  List<Map<String, Object?>> results = await database.query(
    "Articles",
    columns: ["subID, COUNT(id)"],
    groupBy: "subID",
    where: "accountID = ?${(!showAll ? " and isRead = ?" : "")}",
    whereArgs: [accountID, if (!showAll) "false"],
  );

  Map<String, int> counts = results.asMap().map(
    ((key, value) =>
        MapEntry(value["subID"] as String, value["COUNT(id)"] as int)),
  );

  List<Map<String, Object?>> categories = await database.query(
    "Categories",
    columns: ["catID"],
    distinct: true,
    where: "accountID = ?",
    whereArgs: [accountID],
  );
  for (var element in categories) {
    await database
        .rawQuery(
          "Select COUNT(id) from Articles where accountID = $accountID and subID in (select subID from Subscriptions where catID = '${element["catID"]}') ${showAll == false ? "and isRead = 'false'" : ""}",
        )
        .then((count) {
          // print(count.first.values);
          // print(element["catID"]);
          counts[element["catID"] as String] = count.first["COUNT(id)"] as int;
        });
  }

  await database
      .rawQuery(
        "select COUNT(id) from Articles where accountID = $accountID and isStarred = 'true' ${showAll == false ? "and isRead = 'false'" : ""}",
      )
      .then((value) {
        counts["Starred"] = value.first.values.first as int;
      });
  return counts;
}

Future<Map<String, String>> loadArticleIDs({
  bool? showAll,
  String? filterColumn,
  String? filterValue,
  required int accountID,
}) async {
  late List<Map<String, Object?>> articles;
  if (filterColumn == "tag") {
    articles = await database.rawQuery(
      "select articleID, subID from Articles where accountID = $accountID and subID in (select subID from Subscriptions where catID = '$filterValue') ${showAll == false ? "and isRead = 'false'" : ""} order by timeStampPublished DESC",
    );
  } else {
    String? where;
    List<dynamic> args = [];
    if (filterColumn != null) {
      where = "$filterColumn = ?";
      args.add(filterValue!);
    }

    if (showAll == false) {
      where = "${where == null ? "" : "$where and "}isRead = ?";
      args.add("false");
    }
    where = "${where == null ? "" : "$where and "}accountID = ?";
    args.add(accountID);

    articles = await database.query(
      "Articles",
      columns: ["articleID", "subID"],
      where: where,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: "timeStampPublished DESC",
    );
  }
  return articles.asMap().map(
    (key, element) =>
        MapEntry(element["articleID"] as String, element["subID"] as String),
  );
}

void insertArticles(List<Article> articles) {
  final Batch batch = database.batch();
  for (Article article in articles) {
    batch.insert(
      "Articles",
      article.toDB(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  batch.commit(continueOnError: true);
}

void updateArticleRead(String articleId, bool isRead, int accountID) {
  database.update(
    "Articles",
    {"isRead": isRead ? "true" : "false"},
    where: "articleID = ? and accountID = ?",
    whereArgs: [articleId, accountID],
  );
}

void updateArticleStar(String articleId, bool isStarred, int accountID) {
  database.update(
    "Articles",
    {"isStarred": isStarred ? "true" : "false"},
    where: "articleID = ? and accountID = ?",
    whereArgs: [articleId, accountID],
  );
}

Future<void> syncArticlesRead(Set<String> articleIDs, int accountID) async {
  await database.rawUpdate(
    "Update Articles set isRead = 'true' where articleID not in ('${articleIDs.join("','")}') and accountID = $accountID",
  );
}

Future<void> syncArticlesStar(Set<String> articleIDs, int accountID) async {
  //user/-/state/com.google/starred
  await database.rawUpdate(
    "Update Articles set isStarred = 'true' where articleID in ('${articleIDs.join("','")}')  and accountID = $accountID",
  );
  await database.rawUpdate(
    "Update Articles set isStarred = 'false' where articleID not in ('${articleIDs.join("','")}') and isRead = 'true' and accountID = $accountID",
  );
}

// Delayed Actions
Future<Map<String, DelayedAction>> loadDelayedActions(int accountID) async {
  List<Map<String, Object?>> actions = await database.query(
    "DelayedActions",
    where: "accountID = ?",
    whereArgs: [accountID],
  );
  return actions.asMap().map(
    (index, value) => MapEntry(
      value["articleID"] as String,
      DelayedAction.values[value["action"] as int],
    ),
  );
}

void saveDelayedActions(Map<String, DelayedAction> actions, int accountID) {
  final Batch batch = database.batch();

  for (var element in actions.entries) {
    batch.insert("DelayedActions", {
      "articleID": element.key,
      "action": element.value.index,
      "accountID": accountID,
    });
  }
  batch.commit(continueOnError: true);
}

void deleteDelayedActions(Map<String, DelayedAction> actions, int accountID) {
  final Batch batch = database.batch();

  for (var element in actions.entries) {
    batch.delete(
      "DelayedActions",
      where: "articleID = ? and action = ? and accountID = ?",
      whereArgs: [element.key, element.value.index, accountID],
    );
  }
  batch.commit(continueOnError: true);
}

Future<List<Account>> getAllAccounts({int? limit}) async {
  return (await database.query(
    "Account",
    limit: limit,
  )).map((elm) => Account.fromMap(elm)).toList();
}

Future<List<int>> getAccountIds() async {
  return (await database.query(
    "Account",
    columns: ["id"],
  )).map((elm) => elm["id"] as int).toList();
}

Future<Account> getAccount(int accountID) async {
  return Account.fromMap(
    (await database.query(
      "Account",
      where: "id = ?",
      whereArgs: [accountID],
      limit: 1,
    )).first,
  );
}

Future<int> addAccount(Account accountToAdd) async {
  return await database.insert("Account", accountToAdd.toMap()..remove("id"));
}

Future<void> updateAccount(Account accountToAdd) async {
  await database.update("Account", accountToAdd.toMap());
}

Future<void> deleteAccount(int accountID) async {
  await deleteAccountData(accountID);
  await database.delete("Account", where: "id = ?", whereArgs: [accountID]);
}

Future<void> deleteAccountData(int accountID) async {
  await database.delete(
    "Articles",
    where: "accountID = ?",
    whereArgs: [accountID],
  );
  await database.delete(
    "Categories",
    where: "accountID = ?",
    whereArgs: [accountID],
  );
  await database.delete(
    "Subscriptions",
    where: "accountID = ?",
    whereArgs: [accountID],
  );
  await database.delete(
    "DelayedActions",
    where: "accountID = ?",
    whereArgs: [accountID],
  );
  await database.update(
    "Account",
    {"updatedStarredTime": 0, "updatedArticleTime": 0},
    where: "id = ?",
    whereArgs: [accountID],
  );
}

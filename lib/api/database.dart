import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'data_types.dart';

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
const lastSyncTable =
    "create table lastSync (key TEXT primary key, articleID TEXT, accountID INTEGER)";

const _indexes = [
  "CREATE INDEX if not exists idx_article_id ON articles (articleID)",
  "CREATE INDEX if not exists idx_article_subid ON articles (subID)",
  "CREATE INDEX if not exists idx_article_accid ON articles (accountID)",
];

Future<Database> getDatabase() async {
  return await openDatabase(
    'my_db.db',
    version: 9,
    onConfigure: (db) {
      // db.execute("PRAGMA journal_mode = WAL;");
      db.execute("PRAGMA synchronous = NORMAL;");
    },
    onCreate: (db, version) async {
      await db.execute(accTable);
      await db.execute(subTable);
      await db.execute(catTable);
      await db.execute(artTable);
      await db.execute(delTable);
      await db.execute(prefTable);
      await db.execute(lastSyncTable);

      // create indexes for articles table
      for (var ind in _indexes) {
        await db.execute(ind);
      }
    },
    onOpen: (db) async {
      db.getVersion().then(
        (value) => debugPrint("load Database, version: $value"),
      );
    },
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
        debugPrint("Finished upgrading db to: version 4");
      } else if (oldVersion == 4 && newVersion == 5) {
        await db.execute("ALTER TABLE Subscriptions add column catID TEXT");
        debugPrint("Finished upgrading db to: version 5");
      } else if (oldVersion == 6 && newVersion == 7) {
        try {
          await db.execute("drop table preferences");
        } catch (_) {}
        await db.execute(prefTable);
        debugPrint("Finished upgrading db to: version 7");
      } else if (oldVersion == 7 && newVersion == 8) {
        // create indexes for articles table
        for (var ind in _indexes) {
          await db.execute(ind);
        }
        debugPrint("Finished upgrading db to: version 8");
      } else if (oldVersion == 8 && newVersion == 9) {
        // create last sync table
        await db.execute(lastSyncTable);
        debugPrint("Finished upgrading db to: version 9");
      }
    },
    // singleInstance: true,
  );
}

abstract class StorageBase {
  Future<String?> getPreference(String key);

  Future<void> setPreference(String key, String value);

  Future<void> clearOld(int accountID);

  Future<Map<String, Subscription>> loadAllSubs(int accountID);

  Future<Map<String, Category>> loadAllCategory(int accountID);

  Future<void> insertCategories(List<Category> categories, int accountID);

  Future<void> insertSubscriptions(List<Subscription> subs);

  Future<Map<String, (int, String, bool, bool)>> loadArticleMetaData(
    int accountID,
  );

  Future<Article> loadArticle(String articleID, int accountID);

  Future<List<Article>> loadArticles(List<String> articleIDs, int accountID);

  Future<Article> loadArticleContent(String articleID, int accountID);

  Future<String?> loadArticleSubID(String articleID, int accountID);

  Future<Map<String, String>> loadArticleSubIDs(
    List<String> articleIDs,
    int accountID,
  );

  Future<Map<String, String>> loadArticleIDs({
    bool? showAll,
    String? filterColumn,
    String? filterValue,
    required int accountID,
    required int todaySecondsSinceEpoch,
  });

  Future<List<String>?> searchArticles(
    String? searchTerm,
    Set<String>? filteredArticleIDs,
    int accountID,
  );

  Future<void> insertArticles(List<Article> articles);

  Future<void> clearLastSyncTable(int accountID);

  Future<List<String>> getLastSyncIDs(int accountID);

  Future<void> updateArticleRead(String articleId, bool isRead, int accountID);

  Future<void> updateArticleStar(
    String articleId,
    bool isStarred,
    int accountID,
  );

  Future<void> syncArticlesRead(Set<String> articleIDs, int accountID);

  Future<void> syncArticlesStar(Set<String> articleIDs, int accountID);

  // Delayed Actions
  Future<Map<String, DelayedAction>> loadDelayedActions(int accountID);

  void saveDelayedActions(Map<String, DelayedAction> actions, int accountID);

  void deleteDelayedActions(Map<String, DelayedAction> actions, int accountID);

  Future<List<Account>> getAllAccounts({int? limit});

  Future<List<int>> getAccountIds();

  Future<Account> getAccount(int accountID);

  Future<int> addAccount(Account accountToAdd);

  Future<void> updateAccount(Account accountToAdd);

  Future<void> deleteAccount(int accountID);

  Future<void> deleteAccountData(int accountID);
}

class StorageSqlite extends StorageBase {
  final Database _database;
  StorageSqlite(this._database);

  @override
  Future<String?> getPreference(String key) async {
    var res = await _database.query(
      "preferences",
      where: "key = ?",
      whereArgs: [key],
      limit: 1,
    );
    return res.isEmpty ? null : res.first["value"] as String;
  }

  @override
  Future<void> setPreference(String key, String value) async {
    await _database.insert("preferences", {
      "key": key,
      "value": value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> clearOld(int accountID) async {
    await getPreference("read_duration").then((duration) {
      debugPrint("read duration to keep: $duration");
      int? days = int.tryParse(duration ?? "");
      if (duration != null && duration != "-1" && days != null) {
        DateTime now = DateTime.now();
        double seconds = now.millisecondsSinceEpoch / 1000;
        _database
            .delete(
              "articles",
              where:
                  "accountID = ? and timeStampPublished < ? and isRead = ? and isStarred = ?",
              whereArgs: [accountID, seconds - (days * 86400), "true", "false"],
            )
            .then((count) {
              debugPrint("delete $count articles");
            });
      }
    });
  }

  @override
  Future<Map<String, Subscription>> loadAllSubs(int accountID) async {
    return (await _database.query(
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

  @override
  Future<Map<String, Category>> loadAllCategory(int accountID) async {
    return (await _database.query(
      "Categories",
      where: "accountID = ?",
      whereArgs: [accountID],
    )).asMap().map(
      (key, element) =>
          MapEntry(element["catID"] as String, Category.fromMap(element)),
    );
  }

  @override
  Future<void> insertCategories(
    List<Category> categories,
    int accountID,
  ) async {
    final batch = _database.batch();
    for (Category cat in categories) {
      batch.insert(
        "Categories",
        cat.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(continueOnError: true);
  }

  @override
  Future<void> insertSubscriptions(List<Subscription> subs) async {
    final Batch batch = _database.batch();
    for (Subscription sub in subs) {
      batch.insert(
        "Subscriptions",
        sub.toDB(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(continueOnError: true);
  }

  @override
  Future<Map<String, (int, String, bool, bool)>> loadArticleMetaData(
    int accountID,
  ) async {
    Map<String, (int, String, bool, bool)> res = {};
    for (var article in (await _database.rawQuery(
      "select articleID, subID, timeStampPublished, isRead, isStarred from Articles where accountID = $accountID order by timeStampPublished desc",
    ))) {
      res[article.values.first.toString()] = (
        article["timeStampPublished"] as int,
        article["subID"].toString(),
        article["isRead"] == "true",
        article["isStarred"] == "true",
      );
    }
    return res;
  }

  @override
  Future<Article> loadArticle(String articleID, int accountID) async {
    return Article.fromDB(
      (await _database.query(
        "Articles",
        where: "articleID = ? and accountID = ?",
        whereArgs: [articleID, accountID],
        limit: 1,
      )).first,
    );
  }

  @override
  Future<List<Article>> loadArticles(
    List<String> articleIDs,
    int accountID,
  ) async {
    return (await _database.rawQuery(
      "select articleID ,subID, accountID, title, isRead, isStarred, timeStampPublished, url, img from Articles where accountID = $accountID and articleID in ('${articleIDs.join("','")}') order by timeStampPublished desc",
    )).map((article) => Article.fromDB(article)).toList();
  }

  @override
  Future<Article> loadArticleContent(String articleID, int accountID) async {
    var res = await _database.query(
      "Articles",
      where: "articleID = ? and accountID = ?",
      whereArgs: [articleID, accountID],
      limit: 1,
    );
    return Article.fromDB(res.first);
  }

  @override
  Future<String?> loadArticleSubID(String articleID, int accountID) async {
    List<Map<String, Object?>> result = await _database.query(
      "Articles",
      columns: ["subID"],
      where: "articleID = ? and accountID = ?",
      whereArgs: [articleID, accountID],
      orderBy: "timeStampPublished DESC",
      limit: 1,
    );
    return result.isNotEmpty ? result.first.values.first as String : null;
  }

  @override
  Future<Map<String, String>> loadArticleSubIDs(
    List<String> articleIDs,
    int accountID,
  ) async {
    return (await _database.query(
      "Articles",
      columns: ["articleID", "subID"],
      where: "articleID in ? and accountID = ?",
      whereArgs: [articleIDs, accountID],
    )).asMap().map(
      (i, entry) =>
          MapEntry(entry["articleID"] as String, entry["subID"] as String),
    );
  }

  @override
  Future<Map<String, String>> loadArticleIDs({
    bool? showAll,
    String? filterColumn,
    String? filterValue,
    required int accountID,
    required int todaySecondsSinceEpoch,
  }) async {
    late List<Map<String, Object?>> articles;
    if (filterColumn == "tag") {
      articles = await _database.rawQuery(
        "select articleID, subID from Articles where accountID = $accountID and subID in (select subID from Subscriptions where catID = '$filterValue') ${showAll == false ? "and isRead = 'false'" : ""} order by timeStampPublished DESC",
      );
    } else if (filterColumn == "timeStampPublished") {
      articles = await _database.rawQuery(
        "select articleID, subID from Articles where accountID = $accountID and timeStampPublished > $todaySecondsSinceEpoch ${showAll == false ? "and isRead = 'false'" : ""} order by timeStampPublished DESC",
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

      articles = await _database.query(
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

  @override
  Future<List<String>?> searchArticles(
    String? searchTerm,
    Set<String>? filteredArticleIDs,
    int accountID,
  ) async {
    if (searchTerm == null ||
        searchTerm.isEmpty ||
        filteredArticleIDs == null) {
      return filteredArticleIDs?.toList();
    }
    return (await _database.rawQuery(
      "select articleID from Articles where articleID in ('${filteredArticleIDs.join("','")}') and accountID = $accountID and (LOWER(title) like '%' || '${searchTerm.toLowerCase()}' || '%' or LOWER(content) like '%' || '${searchTerm.toLowerCase()}' || '%') order by timeStampPublished desc",
    )).map((res) => res.values.first.toString()).toList();
  }

  @override
  Future<void> insertArticles(List<Article> articles) async {
    final Batch batch = _database.batch();
    for (Article article in articles) {
      batch.insert(
        "Articles",
        article.toDB(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (!article.read) {
        batch.insert("lastSync", {
          "articleID": article.articleID,
          "accountID": article.accountID,
        }, conflictAlgorithm: ConflictAlgorithm.fail);
      }
    }
    await batch.commit(continueOnError: true);
  }

  @override
  Future<void> clearLastSyncTable(int accountID) async {
    await _database.delete(
      "lastSync",
      where: "accountID = ?",
      whereArgs: [accountID],
    );
  }

  @override
  Future<List<String>> getLastSyncIDs(int accountID) async {
    return (await _database.query(
      "lastSync",
      columns: ["articleID"],
      where: "accountID = ?",
      whereArgs: [accountID],
    )).map((elm) => elm.values.first.toString()).toList();
  }

  @override
  Future<void> updateArticleRead(
    String articleId,
    bool isRead,
    int accountID,
  ) async {
    await _database.update(
      "Articles",
      {"isRead": isRead ? "true" : "false"},
      where: "articleID = ? and accountID = ?",
      whereArgs: [articleId, accountID],
    );
  }

  @override
  Future<void> updateArticleStar(
    String articleId,
    bool isStarred,
    int accountID,
  ) async {
    _database.update(
      "Articles",
      {"isStarred": isStarred ? "true" : "false"},
      where: "articleID = ? and accountID = ?",
      whereArgs: [articleId, accountID],
    );
  }

  @override
  Future<void> syncArticlesRead(Set<String> articleIDs, int accountID) async {
    await _database.rawUpdate(
      "Update Articles set isRead = 'true' where articleID not in ('${articleIDs.join("','")}') and accountID = $accountID",
    );
  }

  @override
  Future<void> syncArticlesStar(Set<String> articleIDs, int accountID) async {
    //user/-/state/com.google/starred
    await _database
        .rawUpdate(
          "Update Articles set isStarred = 'true' where articleID in ('${articleIDs.join("','")}') and accountID = $accountID",
        )
        .then((val) {
          debugPrint("Set starred: $val");
        });
    await _database
        .rawUpdate(
          "Update Articles set isStarred = 'false' where articleID not in ('${articleIDs.join("','")}') and accountID = $accountID",
        )
        .then((val) {
          debugPrint("Set unStarred: $val");
        });
  }

  @override
  Future<Map<String, DelayedAction>> loadDelayedActions(int accountID) async {
    List<Map<String, Object?>> actions = await _database.query(
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

  @override
  void saveDelayedActions(Map<String, DelayedAction> actions, int accountID) {
    final Batch batch = _database.batch();

    for (var element in actions.entries) {
      batch.insert("DelayedActions", {
        "articleID": element.key,
        "action": element.value.index,
        "accountID": accountID,
      });
    }
    batch.commit(continueOnError: true);
  }

  @override
  void deleteDelayedActions(Map<String, DelayedAction> actions, int accountID) {
    final Batch batch = _database.batch();

    for (var element in actions.entries) {
      batch.delete(
        "DelayedActions",
        where: "articleID = ? and action = ? and accountID = ?",
        whereArgs: [element.key, element.value.index, accountID],
      );
    }
    batch.commit(continueOnError: true);
  }

  @override
  Future<List<Account>> getAllAccounts({int? limit}) async {
    return (await _database.query(
      "Account",
      limit: limit,
    )).map((elm) => Account.fromMap(elm)).toList();
  }

  @override
  Future<List<int>> getAccountIds() async {
    return (await _database.query(
      "Account",
      columns: ["id"],
    )).map((elm) => elm["id"] as int).toList();
  }

  @override
  Future<Account> getAccount(int accountID) async {
    return Account.fromMap(
      (await _database.query(
        "Account",
        where: "id = ?",
        whereArgs: [accountID],
        limit: 1,
      )).first,
    );
  }

  @override
  Future<int> addAccount(Account accountToAdd) async {
    return await _database.insert(
      "Account",
      accountToAdd.toMap()..remove("id"),
    );
  }

  @override
  Future<void> updateAccount(Account accountToAdd) async {
    await _database.update(
      "Account",
      accountToAdd.toMap(),
      where: "id = ?",
      whereArgs: [accountToAdd.id],
    );
  }

  @override
  Future<void> deleteAccount(int accountID) async {
    await deleteAccountData(accountID);
    await _database.delete("Account", where: "id = ?", whereArgs: [accountID]);
  }

  @override
  Future<void> deleteAccountData(int accountID) async {
    await _database.delete(
      "Articles",
      where: "accountID = ?",
      whereArgs: [accountID],
    );
    await _database.delete(
      "Categories",
      where: "accountID = ?",
      whereArgs: [accountID],
    );
    await _database.delete(
      "Subscriptions",
      where: "accountID = ?",
      whereArgs: [accountID],
    );
    await _database.delete(
      "DelayedActions",
      where: "accountID = ?",
      whereArgs: [accountID],
    );
    await _database.update(
      "Account",
      {"updatedStarredTime": 0, "updatedArticleTime": 0},
      where: "id = ?",
      whereArgs: [accountID],
    );
  }
}

class StorageMemory extends StorageBase {
  final Map<String, String> _preferences = {};
  final Map<int, Account> _accounts = {};
  final Map<String, Subscription> _subscriptions = {};
  final Map<String, Category> _categories = {};
  final Map<String, Article> _articles = {};
  final Map<String, int> _lastSync = {};

  @override
  Future<String?> getPreference(String key) async {
    return _preferences[key];
  }

  @override
  Future<void> setPreference(String key, String value) async {
    _preferences[key] = value;
  }

  @override
  Future<void> clearOld(int accountID) async {
    await getPreference("read_duration").then((duration) {
      debugPrint("read duration to keep: $duration");
      int? days = int.tryParse(duration ?? "");
      if (duration != null && duration != "-1" && days != null) {
        DateTime now = DateTime.now();
        double seconds = now.millisecondsSinceEpoch / 1000;
        _articles.removeWhere((_, a) => a.published < seconds - (days * 86400));
      }
    });
  }

  @override
  Future<Map<String, Subscription>> loadAllSubs(int accountID) async {
    Map<String, Subscription> forAccount = {};
    for (var sub in _subscriptions.entries) {
      if (sub.value.accountID == accountID) {
        forAccount[sub.key] = sub.value;
      }
    }
    return forAccount;
  }

  @override
  Future<Map<String, Category>> loadAllCategory(int accountID) async {
    Map<String, Category> forAccount = {};
    for (var cat in _categories.entries) {
      if (cat.value.accountID == accountID) {
        forAccount[cat.key] = cat.value;
      }
    }
    return forAccount;
  }

  @override
  Future<void> insertCategories(
    List<Category> categories,
    int accountID,
  ) async {
    for (var cat in categories) {
      _categories[cat.catID] = cat;
    }
  }

  @override
  Future<void> insertSubscriptions(List<Subscription> subs) async {
    for (var sub in subs) {
      _subscriptions[sub.subID] = sub;
    }
  }

  @override
  Future<Map<String, (int, String, bool, bool)>> loadArticleMetaData(
    int accountID,
  ) async {
    Map<String, (int, String, bool, bool)> res = {};
    for (var a in _articles.values.where((a) => a.accountID == accountID)) {
      res[a.articleID] = (a.published, a.subID, a.read, a.starred);
    }

    return res;
  }

  @override
  Future<Article> loadArticle(String articleID, int accountID) async {
    return _articles[articleID]!;
  }

  @override
  Future<List<Article>> loadArticles(
    List<String> articleIDs,
    int accountID,
  ) async {
    return _articles.values
        .where(
          (a) => a.accountID == accountID && articleIDs.contains(a.articleID),
        )
        .toList();
  }

  @override
  Future<Article> loadArticleContent(String articleID, int accountID) async {
    return loadArticle(articleID, accountID);
  }

  @override
  Future<String?> loadArticleSubID(String articleID, int accountID) async {
    return _articles[articleID]!.subID;
  }

  @override
  Future<Map<String, String>> loadArticleSubIDs(
    List<String> articleIDs,
    int accountID,
  ) async {
    return _articles.values
        .where(
          (a) => a.accountID == accountID && articleIDs.contains(a.articleID),
        )
        .toList()
        .asMap()
        .map((_, a) => MapEntry(a.articleID, a.subID));
  }

  @override
  Future<Map<String, String>> loadArticleIDs({
    bool? showAll,
    String? filterColumn,
    String? filterValue,
    required int accountID,
    required int todaySecondsSinceEpoch,
  }) async {
    Map<String, String> artSubIDs = {};
    if (filterColumn == "tag") {
      List<String> subIDs = _subscriptions.values
          .where((s) => s.accountID == accountID && s.catID == filterValue)
          .map((s) => s.subID)
          .toList();
      for (var a in _articles.values.where(
        (a) =>
            a.accountID == accountID &&
            subIDs.contains(a.subID) &&
            (showAll == false ? !a.read : true),
      )) {
        artSubIDs[a.articleID] = a.subID;
      }
    } else if (filterColumn == "timeStampPublished") {
      for (var a in _articles.values.where(
        (a) =>
            a.accountID == accountID &&
            a.published > todaySecondsSinceEpoch &&
            (showAll == false ? !a.read : true),
      )) {
        artSubIDs[a.articleID] = a.subID;
      }
    } else {
      // filter by subscription
      for (var a in _articles.values.where(
        (a) =>
            a.accountID == accountID &&
            a.published > todaySecondsSinceEpoch &&
            (showAll == false ? !a.read : true),
      )) {
        artSubIDs[a.articleID] = a.subID;
      }
    }
    return artSubIDs;
  }

  @override
  Future<List<String>?> searchArticles(
    String? searchTerm,
    Set<String>? filteredArticleIDs,
    int accountID,
  ) async {
    if (searchTerm == null ||
        searchTerm.isEmpty ||
        filteredArticleIDs == null) {
      return filteredArticleIDs?.toList();
    }
    return _articles.values
        .where(
          (a) =>
              a.accountID == accountID &&
              filteredArticleIDs.contains(a.articleID) &&
              (a.content.toLowerCase().contains(searchTerm.toLowerCase()) ||
                  a.title.toLowerCase().contains(searchTerm.toLowerCase())),
        )
        .map((a) => a.articleID)
        .toList();
  }

  @override
  Future<void> insertArticles(List<Article> articles) async {
    for (var art in articles) {
      _articles[art.articleID] = art;
      if (!art.read) {
        _lastSync[art.articleID] = art.accountID;
      }
    }
  }

  @override
  Future<void> clearLastSyncTable(int accountID) async {
    _lastSync.removeWhere((_, id) => id == accountID);
  }

  @override
  Future<List<String>> getLastSyncIDs(int accountID) async {
    return _lastSync.entries
        .where((l) => l.value == accountID)
        .map((l) => l.key)
        .toList();
  }

  @override
  Future<void> updateArticleRead(
    String articleId,
    bool isRead,
    int accountID,
  ) async {
    for (var a in _articles.entries) {
      if (a.key == articleId && a.value.accountID == accountID) {
        _articles[a.key]!.read = isRead;
        return;
      }
    }
  }

  @override
  Future<void> updateArticleStar(
    String articleId,
    bool isStarred,
    int accountID,
  ) async {
    for (var a in _articles.entries) {
      if (a.key == articleId && a.value.accountID == accountID) {
        _articles[a.key]!.starred = isStarred;
        return;
      }
    }
  }

  @override
  Future<void> syncArticlesRead(Set<String> articleIDs, int accountID) async {
    for (var a in _articles.entries) {
      if (!articleIDs.contains(a.key) && a.value.accountID == accountID) {
        _articles[a.key]!.read = true;
      }
    }
  }

  @override
  Future<void> syncArticlesStar(Set<String> articleIDs, int accountID) async {
    for (var a in _articles.entries) {
      if (articleIDs.contains(a.key) && a.value.accountID == accountID) {
        _articles[a.key]!.starred = true;
      } else if (!articleIDs.contains(a.key) &&
          a.value.accountID == accountID) {
        _articles[a.key]!.starred = false;
      }
    }
  }

  @override
  Future<Map<String, DelayedAction>> loadDelayedActions(int accountID) async {
    return {};
  }

  @override
  void saveDelayedActions(Map<String, DelayedAction> actions, int accountID) {}

  @override
  void deleteDelayedActions(
    Map<String, DelayedAction> actions,
    int accountID,
  ) {}

  @override
  Future<List<Account>> getAllAccounts({int? limit}) async {
    if (limit == null) {
      return _accounts.values.toList();
    }
    return _accounts.values.take(limit).toList();
  }

  @override
  Future<List<int>> getAccountIds() async {
    return _accounts.keys.toList();
  }

  @override
  Future<Account> getAccount(int accountID) async {
    return _accounts[accountID]!;
  }

  @override
  Future<int> addAccount(Account accountToAdd) async {
    _accounts[_accounts.length + 1] = accountToAdd;
    return _accounts.length;
  }

  @override
  Future<void> updateAccount(Account accountToAdd) async {
    _accounts[accountToAdd.id] = accountToAdd;
  }

  @override
  Future<void> deleteAccount(int accountID) async {
    await deleteAccountData(accountID);
    _accounts.remove(accountID);
  }

  @override
  Future<void> deleteAccountData(int accountID) async {
    _articles.removeWhere((id, a) => a.accountID == accountID);
    _categories.removeWhere((id, c) => c.accountID == accountID);
    _subscriptions.removeWhere((id, s) => s.accountID == accountID);
    _accounts[accountID]!.updatedArticleTime = 0;
    _accounts[accountID]!.updatedStarredTime = 0;
  }
}

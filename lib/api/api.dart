import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fresh_reader/main.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'data_types.dart';

ScreenSize screenSizeOf(BuildContext context) {
  if (MediaQuery.sizeOf(context).width > 840) {
    return ScreenSize.big;
  } else if (MediaQuery.sizeOf(context).width > 640) {
    return ScreenSize.medium;
  } else {
    return ScreenSize.small;
  }
}

class Api extends InheritedNotifier<ApiData> {
  const Api({
    super.key,
    required super.child,
    required super.notifier,
  });

  static ApiData of(BuildContext context) {
    assert(
      context.dependOnInheritedWidgetOfExactType<Api>() != null,
      "Api not found in current context",
    );
    return context.dependOnInheritedWidgetOfExactType<Api>()!.notifier!;
  }

  @override
  bool updateShouldNotify(covariant InheritedNotifier<ApiData> oldWidget) {
    return notifier != oldWidget.notifier;
  }
}

class DatabaseManager {
  late Database db;

  Future<bool> getDatabase() async {
    await openDatabase(
      'my_db.db',
      version: 2,
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE Subscription (id INTEGER PRIMARY KEY, subID TEXT UNIQUE, title TEXT, url TEXT, htmlUrl TEXT, iconUrl TEXT)');
        await db.execute(
            'CREATE TABLE Category (id INTEGER PRIMARY KEY, catID TEXT, subID TEXT, name TEXT)');
        await db.execute(
            'CREATE TABLE Article (id INTEGER PRIMARY KEY, articleID TEXT UNIQUE, subID TEXT, title TEXT, isRead TEXT, isStarred TEXT, timeStampPublished INTEGER, content TEXT, url TEXT)');
        await db.execute(
            'CREATE TABLE DelayedAction (id INTEGER PRIMARY KEY, articleID TEXT , action INTEGER)');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion == 1 && newVersion == 2) {
          await db.execute('ALTER TABLE Article add column isStarred TEXT');
          await db.update("Article", {"isStarred": "false"});
        }
      },
      // singleInstance: true,
    ).then((value) {
      db = value;
    });
    return true;
  }

  void closeDatabase() {
    db.close();
  }

  // Subs
  Future<Map<String, Subscription>> loadAllSubs() async {
    List<Map<String, Object?>> subs = await db.query(
      "Subscription",
      columns: ["subID", "title", "url", "htmlUrl", "iconUrl"],
    );
    List<Map<String, Object?>> cats = await db.query(
      "Category",
      columns: ["catID", "subID", "name"],
    );
    return subs.asMap().map((key, element) => MapEntry(
        element["subID"] as String, Subscription.fromDB(element, cats)));
  }

  void saveSubs(List<Subscription> subs) {
    final Batch batch = db.batch();
    for (var sub in subs) {
      batch.insert("Subscription", sub.toDB());
      batch.delete("Category", where: "subID = ?", whereArgs: [sub.id]);
      for (var cat in sub.categories) {
        batch.insert("Category", {"subID": sub.id, "name": cat});
      }
    }
    batch.commit(continueOnError: true);
  }

  // Articles
  // Future<Map<String, Article>> loadArticles(
  //     {String? filterColumn, String? filterValue}) async {
  //   List<Map<String, Object?>> articles = await db.query(
  //     "Article",
  //     columns: [
  //       "articleID",
  //       "subID",
  //       "title",
  //       "isRead",
  //       "timeStampPublished",
  //       "content",
  //       "url"
  //     ],
  //     where: filterColumn == null ? null : "$filterColumn = ?",
  //     whereArgs: filterValue == null ? null : [filterValue],
  //   );
  //   return articles.asMap().map((key, element) =>
  //       MapEntry(element["articleID"] as String, Article.fromDB(element)));
  // }

  Future<Article> loadArticle(String articleID, bool loadContent) async {
    List<Map<String, Object?>> articles = await db.query(
      "Article",
      columns: [
        "articleID",
        "subID",
        "title",
        "isRead",
        "isStarred",
        "timeStampPublished",
        "content",
        "url",
      ],
      where: "articleID = ?",
      whereArgs: [articleID],
    );
    return Article.fromDB(articles.first, loadContent);
  }

  Future<List<Article>> loadArticles(
      List<String> articleIDs, bool loadContent) async {
    List<Map<String, Object?>> articles = await db.rawQuery(
        "select articleID ,subID, title, isRead, isStarred, timeStampPublished, content, url from Article where articleID in ('${articleIDs.join("','")}') order by timeStampPublished desc");
    return articles
        .map((article) => Article.fromDB(article, loadContent))
        .toList();
  }

  Future<String?> loadArticleSubID(String articleID) async {
    List<Map<String, Object?>> result = await db.query("Article",
        columns: [
          "subID",
        ],
        where: "articleID = ?",
        whereArgs: [articleID],
        orderBy: "timeStampPublished DESC");
    return result.isNotEmpty ? result.first.values.first as String : null;
  }

  Future<int> countArticles(
      {bool? showAll, String? filterColumn, String? filterValue}) async {
    late String queryText;
    if (filterColumn == "tag") {
      queryText =
          "select COUNT(id) from Article where subID in (select subID from category where name = '$filterValue')";
    } else {
      queryText =
          "select COUNT(id) from Article ${(filterColumn != null && filterValue != null) ? "where $filterColumn = '$filterValue'" : ""}";
    }
    if (showAll == false) {
      queryText += " and isRead = 'false'";
    }

    List<Map<String, Object?>> result = await db.rawQuery(queryText);
    return result.first.values.first as int;
  }

  Future<Map<String, int>> countAllArticles(bool? showAll) async {
    List<Map<String, Object?>> results = await db.query(
      "Article",
      columns: ["subID, COUNT(id)"],
      groupBy: "subID",
      where: showAll == false ? "isRead = ?" : null,
      whereArgs: showAll == false ? ["false"] : null,
    );

    Map<String, int> counts = results.asMap().map(((key, value) =>
        MapEntry(value["subID"] as String, value["COUNT(id)"] as int)));

    List<Map<String, Object?>> categories =
        await db.query("Category", columns: ["name"], distinct: true);
    for (var element in categories) {
      await db
          .rawQuery(
              "Select COUNT(id) from Article where subID in (select subID from Category where name = '${element["name"]}') ${showAll == false ? "and isRead = 'false'" : ""}")
          .then((count) {
        counts[element["name"] as String] = count.first["COUNT(id)"] as int;
      });
    }

    await db
        .rawQuery(
            "select COUNT(id) from Article where isStarred = 'true' ${showAll == false ? "and isRead = 'false'" : ""}")
        .then((value) {
      counts["Starred"] = value.first.values.first as int;
    });
    return counts;
  }

  Future<Map<String, String>> loadArticleIDs(
      {bool? showAll, String? filterColumn, String? filterValue}) async {
    late List<Map<String, Object?>> articles;
    if (filterColumn == "tag") {
      articles = await db.rawQuery(
          "select articleID, subID from Article where subID in (select subID from category where name = '$filterValue') ${showAll == false ? "and isRead = 'false'" : ""} order by timeStampPublished DESC");
    } else {
      String? where;
      List<String> args = [];
      if (filterColumn != null) {
        where = "$filterColumn = ?";
        args.add(filterValue!);
      }

      if (showAll == false) {
        where = "${where == null ? "" : "$where and "}isRead = ?";
        args.add("false");
      }

      articles = await db.query(
        "Article",
        columns: [
          "articleID",
          "subID",
        ],
        where: where,
        whereArgs: args.isNotEmpty ? args : null,
        orderBy: "timeStampPublished DESC",
      );
    }
    return articles.asMap().map((key, element) =>
        MapEntry(element["articleID"] as String, element["subID"] as String));
  }

  void saveArticles(
      List<Article> articles, Map<String, DelayedAction> delayedActions) {
    final Batch batch = db.batch();
    for (Article article in articles) {
      if (delayedActions[article.id] != DelayedAction.unread) {
        batch.insert("Article", article.toDB());
        batch.update("Article", {"isRead": "false"},
            where: "articleID = ?", whereArgs: [article.id]);
      }
    }
    batch.commit(continueOnError: true);
  }

  void saveReadArticles(List<Article> articles) {
    final Batch batch = db.batch();
    for (Article article in articles) {
      batch.insert("Article", article.toDB());
    }
    batch.commit(continueOnError: true);
  }

  void updateArticleRead(String articleId, bool isRead) {
    db.update("Article", {"isRead": isRead ? "true" : "false"},
        where: "articleID = ?", whereArgs: [articleId]);
  }

  void updateArticleStar(String articleId, bool isStarred) {
    db.update("Article", {"isStarred": isStarred ? "true" : "false"},
        where: "articleID = ?", whereArgs: [articleId]);
  }

  Future<void> syncArticlesRead(Set<String> articleIDs) async {
    await db.rawUpdate(
        "Update Article set isRead = 'true' where articleID not in ('${articleIDs.join("','")}')");
  }

  Future<void> syncArticlesStar(Set<String> articleIDs) async {
    //user/-/state/com.google/starred
    await db.rawUpdate(
        "Update Article set isStarred = 'true' where articleID in ('${articleIDs.join("','")}')");
    await db.rawUpdate(
        "Update Article set isStarred = 'false' where articleID not in ('${articleIDs.join("','")}') and isRead = 'true'");
  }

  // Delayed Actions
  Future<Map<String, DelayedAction>> loadDelayedActions() async {
    List<Map<String, Object?>> actions = await db.query("DelayedAction");

    return actions.asMap().map(
          (index, value) => MapEntry(
            value["articleID"] as String,
            DelayedAction.values[value["action"] as int],
          ),
        );
  }

  void saveDelayedActions(Map<String, DelayedAction> actions) {
    final Batch batch = db.batch();

    for (var element in actions.entries) {
      batch.insert("DelayedAction", {
        "articleID": element.key,
        "action": element.value.index,
      });
    }
    batch.commit(continueOnError: true);
  }
}

class ApiData extends ChangeNotifier {
  DatabaseManager? db;
  SharedPreferences? preferences;

  bool justBooted = true;
  String server = "";
  String userName = "";
  String password = "";
  String auth = "";
  String modifyAuth = "";
  Map<String, Subscription> subs = {};
  Set<String> tags = <String>{};
  Set<String> articleIDs = <String>{};
  Map<String, DelayedAction> delayedActions = {};

  bool _showAll = false;
  int updatedArticleTime = 0;
  int updatedStarredTime = 0;

  Set<String>? filteredArticleIDs;
  Map<String, Article>? filteredArticles;
  String? filteredTitle;
  int? filteredIndex;

  @override
  void dispose() {
    db?.closeDatabase();
    super.dispose();
  }

  Future<bool> load() async {
    try {
      preferences = await SharedPreferences.getInstance();
      updatedArticleTime =
          preferences!.getInt("updatedArticleTime") ?? updatedArticleTime;
      updatedStarredTime =
          preferences!.getInt("updatedStarredTime") ?? updatedStarredTime;

      server = preferences!.getString("server") ?? server;
      userName = preferences!.getString("userName") ?? userName;
      password = preferences!.getString("password") ?? password;
      auth = preferences!.getString("auth") ?? auth;
      modifyAuth = preferences!.getString("modifyAuth") ?? modifyAuth;

      if (db == null) {
        db = DatabaseManager();
        await db!.getDatabase();
      }

      // tags.add("user/-/state/com.google/starred");
      subs = await db!.loadAllSubs();
      for (var element in subs.entries) {
        for (var tag in element.value.categories) {
          tags.add(tag);
        }
      }
      delayedActions = await db!.loadDelayedActions();
      articleIDs.addAll((await db!.loadArticleIDs()).keys);
    } catch (e) {
      mainLoadError = e;
    }
    // return (preferences!.getString("server") ?? "") != "";
    return true;
  }

  Future<bool> save() async {
    await preferences!.setInt("updatedArticleTime", updatedArticleTime);
    await preferences!.setInt("updatedStarredTime", updatedStarredTime);
    await preferences!.setString("server", server);
    await preferences!.setString("userName", userName);
    await preferences!.setString("password", password);
    await preferences!.setString("auth", auth);
    await preferences!.setString("modifyAuth", modifyAuth);

    if (db == null) {
      db = DatabaseManager();
      await db!.getDatabase();
    }

    // List<String> newUnread = [];
    // List<String> newRead = [];
    // for (var entry in delayedActions.entries) {
    //   if (entry.value == DelayedAction.read) {
    //     newRead.add(entry.key);
    //   } else if (entry.value == DelayedAction.unread) {
    //     newUnread.add(entry.key);
    //   }
    // }

    db!.saveDelayedActions(delayedActions);

    return true;
  }

  Future<bool> serverSync() async {
    // if (auth == "") {
    await _getAuth(Uri.parse(
            "$server/accounts/ClientLogin?Email=$userName&Passwd=$password"))
        .then((value) {
      auth = value;
    });
    // }

    if (delayedActions.isNotEmpty) {
      // debugPrint(delayedActions.toString());
      Map<String, String> articleSub = {};
      for (var element in delayedActions.keys) {
        await db!.loadArticleSubID(element).then((value) {
          if (value != null) {
            articleSub[element] = value;
          }
        });
      }
      Map<String, String> readIds = {};
      Map<String, String> unReadIds = {};
      Map<String, String> starIds = {};
      Map<String, String> unstarIds = {};

      for (var element in delayedActions.entries) {
        if (articleSub[element.key] != null) {
          if (element.value == DelayedAction.read) {
            readIds[element.key] = articleSub[element.key]!;
          } else if (element.value == DelayedAction.unread) {
            unReadIds[element.key] = articleSub[element.key]!;
          } else if (element.value == DelayedAction.star) {
            starIds[element.key] = articleSub[element.key]!;
          } else if (element.value == DelayedAction.unstar) {
            unstarIds[element.key] = articleSub[element.key]!;
          }
        }
      }
      // debugPrint(readIds.toString());
      // debugPrint(unReadIds.toString());
      await _setServerRead(
        readIds.keys.toList(),
        readIds.values.toList(),
        true,
      );
      await _setServerRead(
        unReadIds.keys.toList(),
        unReadIds.values.toList(),
        false,
      );
      await _setServerStar(
        starIds.keys.toList(),
        starIds.values.toList(),
        true,
      );
      await _setServerStar(
        unstarIds.keys.toList(),
        unstarIds.values.toList(),
        false,
      );
    }

    // _getModifyAuth(auth)
    //     .then((value) => modifyAuth = value.body.replaceAll("\n", "")),
    await _getTags(auth);
    await _getSubscriptions(auth);
    await _getAllArticles(auth, "reading-list");
    await _getReadIds(auth);
    await _getStarredIds(auth);
    await _getStarredArticles(auth);
    //https://github.com/FreshRSS/FreshRSS/issues/2566
    await save();
    return true;
  }

  Future<String> _getAuth(Uri uriWithAuth) async {
    http.Response res = await http.post(uriWithAuth);
    if (res.statusCode != 200) {
      throw Exception("${res.statusCode}: ${res.body}");
    }
    return res.body.split("Auth=").last.replaceAll("\n", "");
  }

  Future<http.Response> _getModifyAuth(String auth) {
    return http.post(
      Uri.parse("$server/reader/api/0/token"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'GoogleLogin auth=$auth',
      },
    );
  }

  Future<void> _getSubscriptions(String auth) async {
    http.get(
      Uri.parse("$server/reader/api/0/subscription/list?output=json"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'GoogleLogin auth=$auth',
      },
    ).then((value) {
      jsonDecode(value.body)["subscriptions"].forEach((element) {
        List<String> categories = [];
        element["categories"].forEach((cat) {
          categories.add(cat["id"]);
        });
        subs[element["id"]] = Subscription.fromJson(element);
        subs[element["id"]]!.categories = categories;
      });
      db!.saveSubs(subs.values.toList());
    }).catchError((onError) {
      if (kDebugMode) {
        throw onError;
      }
      debugPrint(onError.toString());
    });
  }

  Future<void> _getTags(String auth) async {
    http.get(
      Uri.parse("$server/reader/api/0/tag/list?output=json"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'GoogleLogin auth=$auth',
      },
    ).then((value) {
      jsonDecode(value.body)["tags"].forEach((element) {
        tags.add(element["id"] ?? "");
      });
      List<String> list = tags.toList()..sort(); // sort the set
      tags = list.toSet();
    }).catchError((onError) {
      if (kDebugMode) {
        throw onError;
      }
      debugPrint(onError.toString());
    });
  }

  Future<void> _getAllArticles(String auth, String feed) async {
    bool updateTime = true;
    String url =
        "$server/reader/api/0/stream/contents/$feed?xt=user/-/state/com.google/read&n=1000&ot=$updatedArticleTime";
    String con = "";
    dynamic res;
    do {
      await http.get(
        Uri.parse("$url${con == "" ? "" : "&c=$con"}"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'GoogleLogin auth=$auth',
        },
      ).then((value) {
        res = jsonDecode(String.fromCharCodes(value.bodyBytes));
        List<Article> articles = [];
        res["items"].forEach((json) {
          Article article = Article.fromCloudJson(json);
          articleIDs.add(article.id);
          articles.add(article);
        });
        db!.saveArticles(articles, delayedActions);
        con = res["continuation"]?.toString() ?? "";
      }).catchError((onError) {
        if (kDebugMode) {
          throw onError;
        }
        updateTime = false;
        debugPrint(onError.toString());
      });
    } while (con != "");
    if (updateTime) {
      updatedArticleTime =
          (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    }
  }

  Future<void> _getReadIds(String auth) async {
    Set<String> syncedArticleIDs = <String>{};
    String con = "";
    do {
      http.Response response = await http.get(
        Uri.parse(
            "$server/reader/api/0/stream/items/ids?s=user/-/state/com.google/reading-list&xt=user/-/state/com.google/read&merge=true&ot=0&output=json&n=10000${con == "" ? "" : "&c=$con"}"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'GoogleLogin auth=$auth',
        },
      );
      if (response.statusCode == 200 && (response.contentLength ?? 0) > 0) {
        dynamic res = jsonDecode(String.fromCharCodes(response.bodyBytes));
        if (res["itemRefs"] != null) {
          res["itemRefs"].forEach((json) {
            if (json["id"] != null) {
              syncedArticleIDs.add(
                  "tag:google.com,2005:reader/item/${int.parse(json["id"]).toRadixString(16).padLeft(16, "0")}");
            }
          });
        }
        con = res["continuation"]?.toString() ?? "";
      } else {
        debugPrint(response.body);
      }
    } while (con != "");
    await db!.syncArticlesRead(syncedArticleIDs);
  }

  Future<void> _getStarredIds(String auth) async {
    bool updateTime = true;
    Set<String> syncedArticleIDs = <String>{};
    String con = "";
    do {
      http.Response response = await http.get(
        Uri.parse(
            "$server/reader/api/0/stream/items/ids?s=user/-/state/com.google/starred&merge=true&xt=user/-/state/com.google/read&ot=$updatedStarredTime&output=json&n=10000${con == "" ? "" : "&c=$con"}"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'GoogleLogin auth=$auth',
        },
      );
      if (response.statusCode == 200 && (response.contentLength ?? 0) > 0) {
        dynamic res = jsonDecode(String.fromCharCodes(response.bodyBytes));
        if (res["itemRefs"] != null) {
          res["itemRefs"].forEach((json) {
            if (json["id"] != null) {
              syncedArticleIDs.add(
                  "tag:google.com,2005:reader/item/${int.parse(json["id"]).toRadixString(16).padLeft(16, "0")}");
            }
          });
        }
        con = res["continuation"]?.toString() ?? "";
      } else {
        debugPrint(response.body);
        updateTime = false;
      }
    } while (con != "");
    await db!.syncArticlesStar(syncedArticleIDs);

    if (updateTime) {
      updatedStarredTime =
          (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    }
  }

  Future<void> _getStarredArticles(String auth) async {
    String con = "";
    do {
      http.Response response = await http.get(
        Uri.parse(
            "$server/reader/api/0/stream/contents/user/-/state/com.google/starred?it=user/-/state/com.google/read&xt=user/-/state/com.google/reading-list&ot=0&output=json&n=1000${con == "" ? "" : "&c=$con"}"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'GoogleLogin auth=$auth',
        },
      );
      if (response.statusCode == 200 && (response.contentLength ?? 0) > 0) {
        dynamic res = jsonDecode(String.fromCharCodes(response.bodyBytes));
        List<Article> articles = [];
        res["items"].forEach((json) {
          Article article = Article.fromCloudJson(json);
          article.read = true;
          article.starred = true;
          articleIDs.add(article.id);
          articles.add(article);
        });
        db!.saveReadArticles(articles);
        con = res["continuation"]?.toString() ?? "";
      } else {
        debugPrint(response.body);
      }
    } while (con != "");
  }

  Future<bool> _setServerRead(
    List<String> ids,
    List<String> subIDs,
    bool isRead,
  ) async {
    String idString = "?";
    for (int i = 0; i < ids.length; i++) {
      delayedActions[ids[i]] =
          isRead ? DelayedAction.read : DelayedAction.unread;
      idString += "s=${subIDs[i]}&i=${ids[i]}&";
    }
    idString = "$idString${isRead ? "a" : "r"}=user/-/state/com.google/read";
    await http
        .post(Uri.parse("$server/reader/api/0/edit-tag"),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Authorization': 'GoogleLogin auth=$auth',
            },
            body: idString)
        .then((value) {
      if (value.body == "OK") {
        delayedActions.removeWhere((key, _) => ids.contains(key));
        // } else {
        //   for (var id in ids) {
        //     delayedActions[id] =
        //         isRead ? DelayedAction.read : DelayedAction.unread;
        //   }
      }
    }).catchError((onError) {
      //   for (var id in ids) {
      //     delayedActions[id] = isRead ? DelayedAction.read : DelayedAction.unread;
      //   }
      // if (kDebugMode) {
      //   throw onError;
      // }
      debugPrint(onError.toString());
    });
    save();
    return true;
  }

  Future<bool> _setServerStar(
    List<String> ids,
    List<String> subIDs,
    bool isStar,
  ) async {
    String idString = "?";
    for (int i = 0; i < ids.length; i++) {
      delayedActions[ids[i]] =
          isStar ? DelayedAction.star : DelayedAction.unstar;
      idString += "s=${subIDs[i]}&i=${ids[i]}&";
    }
    idString = "$idString${isStar ? "a" : "r"}=user/-/state/com.google/starred";
    await http
        .post(Uri.parse("$server/reader/api/0/edit-tag"),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Authorization': 'GoogleLogin auth=$auth',
            },
            body: idString)
        .then((value) {
      if (value.body == "OK") {
        delayedActions.removeWhere((key, _) => ids.contains(key));
      }
    }).catchError((onError) {
      debugPrint(onError.toString());
    });
    save();
    return true;
  }

  void setRead(String id, String subID, bool isRead) {
    filteredArticles?[id]?.read = isRead;
    _setServerRead([id], [subID], isRead);
    db!.updateArticleRead(id, isRead);
    notifyListeners();
  }

  void setStarred(String id, String subID, bool isStarred) {
    filteredArticles?[id]?.starred = isStarred;
    _setServerStar([id], [subID], isStarred);
    db!.updateArticleStar(id, isStarred);
    notifyListeners();
  }

  Future<void> getFilteredArticles(
      bool? showAll, String? filterColumn, String? filterValue) async {
    filteredArticleIDs = null;
    filteredArticles = null;
    filteredIndex = null;
    filteredTitle = null;
    await db!
        .loadArticleIDs(
            showAll: showAll,
            filterColumn: filterColumn,
            filterValue: filterValue)
        .then((value) {
      filteredArticleIDs = value.keys.toSet();
    });
    db!
        .loadArticles(filteredArticleIDs!.toList(), false)
        .then((List<Article> arts) {
      filteredArticles = {};
      for (var article in arts) {
        filteredArticles![article.id] = article;
      }
      notifyListeners();
    });
    if (filterValue != null && filterValue.startsWith("feed/")) {
      filteredTitle = subs[filterValue]?.title;
    } else if (filterColumn == "isStarred" && filterValue == "true") {
      filteredTitle = "Starred";
    } else {
      filteredTitle = filterValue ?? "All Articles";
    }
    // notifyListeners();
  }

  bool getShowAll() {
    return _showAll;
  }

  void setShowAll(bool newValue) {
    _showAll = newValue;
    notifyListeners();
  }

  String? getIconUrl(String feedId) {
    if (subs.containsKey(feedId)) {
      String url = subs[feedId]!.iconUrl;
      url = url.replaceFirst("http://localhost/FreshRss/p/", server);
      url = url.replaceFirst("api/greader.php", "");
      return url;
    } else {
      return null;
    }
  }
}

// end of class
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

String getRelativeDate(int secondsSinceEpoch) {
  DateTime articleTime =
      DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch * 1000);
  DateTime now = DateTime.now();
  Duration difference = now.difference(articleTime);
  if (difference.inDays > 0) {
    if (difference.inDays < 30) {
      return "${difference.inDays} ${difference.inDays == 1 ? "Day" : "Days"}";
    } else if (difference.inDays < 365) {
      int months = (difference.inDays / 30).floor();
      return "$months ${months == 1 ? "Month" : "Months"}";
    } else {
      int years = (difference.inDays / 365).floor();
      return "$years ${years == 1 ? "Year" : "Years"}";
    }
  } else if (difference.inHours > 0) {
    return "${difference.inHours} ${difference.inHours == 1 ? "Hour" : "Hours"}";
  } else if (difference.inMinutes > 0) {
    return "${difference.inMinutes} ${difference.inMinutes == 1 ? "Minute" : "Minutes"}";
  }
  return "Just Now";
}

int getDifferenceInDays(int secondsSinceEpoch) {
  DateTime articleTime =
      DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch * 1000);
  DateTime now = DateTime.now();
  Duration difference = now.difference(articleTime);
  return difference.inDays;
}

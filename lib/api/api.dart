import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'data_types.dart';

ScreenSize screenSizeOf(BuildContext context) {
  if (MediaQuery.sizeOf(context).shortestSide > 840) {
    return ScreenSize.big;
  } else if (MediaQuery.sizeOf(context).shortestSide > 640) {
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
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE Subscription (id INTEGER PRIMARY KEY, subID TEXT UNIQUE, title TEXT, url TEXT, htmlUrl TEXT, iconUrl TEXT)');
        await db.execute(
            'CREATE TABLE Category (id INTEGER PRIMARY KEY, catID TEXT, subID TEXT, name TEXT)');
        await db.execute(
            'CREATE TABLE Article (id INTEGER PRIMARY KEY, articleID TEXT UNIQUE, subID TEXT, title TEXT, isRead TEXT, timeStampPublished INTEGER, content TEXT, url TEXT)');
        await db.execute(
            'CREATE TABLE DelayedAction (id INTEGER PRIMARY KEY, articleID TEXT , action INTEGER)');
      },
      // singleInstance: true,
    ).then((value) {
      db = value;
    });
    return true;
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

  Future<Article> loadArticle(String articleID) async {
    List<Map<String, Object?>> articles = await db.query(
      "Article",
      columns: [
        "articleID",
        "subID",
        "title",
        "isRead",
        "timeStampPublished",
        "content",
        "url"
      ],
      where: "articleID = ?",
      whereArgs: [articleID],
    );
    // print("hello; " + (articles.first["articleID"] as String));
    return Article.fromDB(articles.first);
  }

  Future<String> loadArticleSubID(String articleID) async {
    List<Map<String, Object?>> result = await db.query(
      "Article",
      columns: [
        "subID",
      ],
      where: "articleID = ?",
      whereArgs: [articleID],
    );
    return result.first.values.first as String;
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
              "Select COUNT(id) from Article where subID in (select subID from Category where name = '${element["name"]}')")
          .then((count) {
        counts[element["name"] as String] = count.first["COUNT(id)"] as int;
      });
    }
  
    return counts;
  }

  Future<Map<String, String>> loadArticleIDs(
      {bool? showAll, String? filterColumn, String? filterValue}) async {
    late List<Map<String, Object?>> articles;
    if (filterColumn == "tag") {
      articles = await db.rawQuery(
          "select articleID, subID from Article where subID in (select subID from category where name = '$filterValue') " +
              (showAll == false ? "and isRead = 'false'" : ""));
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
      );
    }
    return articles.asMap().map((key, element) =>
        MapEntry(element["articleID"] as String, element["subID"] as String));
  }

  void saveArticles(List<Article> articles) {
    final Batch batch = db.batch();
    for (Article article in articles) {
      batch.insert("Article", article.toDB());
      batch.update("Article", {"isRead": "false"},
          where: "articleID = ?", whereArgs: [article.id]);
    }
    batch.commit(continueOnError: true);
  }

  void updateArticleRead(String articleId, bool isRead) {
    db.update("Article", {"isRead": isRead ? "true" : "false"},
        where: "articleID = ?", whereArgs: [articleId]);
  }

  void syncArticlesRead(Set<String> articleIDs) {
    db.rawUpdate(
        "Update Article set isRead = 'true' where articleID not in ('${articleIDs.join("','")}')");
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

  String server = "";
  String userName = "";
  String password = "";
  String auth = "";
  // String modifyAuth = "";
  Map<String, Subscription> subs = {};
  Set<String> tags = <String>{};
  Set<String> articleIDs = <String>{};
  Map<String, DelayedAction> delayedActions = {};

  bool _showAll = false;
  int updatedTime = 0;
  int unreadTotal = 0;

  Set<String>? filteredArticleIDs;
  String? filteredTitle;
  int? filteredIndex;

  Future<bool> load() async {
    preferences = await SharedPreferences.getInstance();
    updatedTime = preferences!.getInt("updatedTime") ?? updatedTime;
    unreadTotal = preferences!.getInt("unreadTotal") ?? unreadTotal;

    server = preferences!.getString("server") ?? "";
    userName = preferences!.getString("userName") ?? "";
    password = preferences!.getString("password") ?? "";
    auth = preferences!.getString("auth") ?? "";

    if (db == null) {
      db = DatabaseManager();
      await db!.getDatabase();
    }

    subs = await db!.loadAllSubs();
    for (var element in subs.entries) {
      for (var tag in element.value.categories) {
        tags.add(tag);
      }
    }
    delayedActions = await db!.loadDelayedActions();
    articleIDs.addAll((await db!.loadArticleIDs()).keys);
    return true;
  }

  Future<bool> save() async {
    await preferences!.setInt("updatedTime", updatedTime);
    await preferences!.setInt("unreadTotal", unreadTotal);
    await preferences!.setString("server", server);
    await preferences!.setString("userName", userName);
    await preferences!.setString("password", password);
    await preferences!.setString("auth", auth);

    if (db == null) {
      db = DatabaseManager();
      await db!.getDatabase();
    }

    List<String> newUnread = [];
    List<String> newRead = [];
    for (var entry in delayedActions.entries) {
      if (entry.value == DelayedAction.read) {
        newRead.add(entry.key);
      } else if (entry.value == DelayedAction.unread) {
        newUnread.add(entry.key);
      }
    }

    db!.saveDelayedActions(delayedActions);
    // db!.saveArticles(articles.values.toList());

    return true;
  }

  Future<bool> serverSync() async {
    if (auth == "") {
      await _getAuth(Uri.parse(
              "$server/accounts/ClientLogin?Email=$userName&Passwd=$password"))
          .then((value) {
        auth = value;
      });
    }

    // if (delayedActions.isNotEmpty) {
    //   debugPrint(delayedActions.toString());
    //   List<String> ids = delayedActions.entries
    //       .where((entry) => entry.value == DelayedAction.read)
    //       .map((entry) => entry.key)
    //       .toList();
    //   _setServerUnread(
    //     ids,
    //     ids.map((id) async {
    //       return await db!.loadArticleSubID(id);
    //     }).toList(),
    //     true,
    //   );
    //   List<String> unreadIDs = delayedActions.entries
    //       .where((entry) => entry.value == DelayedAction.unread)
    //       .map((entry) => entry.key)
    //       .toList();
    //   _setServerUnread(
    //     unreadIDs,
    //     [],
    //     false,
    //   );
    // }

    await Future.wait([
      // _getModifyAuth(auth)
      //     .then((value) => modifyAuth = value.body.replaceAll("\n", "")),
      _getTags(auth),
      _getSubscriptions(auth),
      // _getUnreadCounts(auth).then((value) {
      //   Map<String, dynamic> json = jsonDecode(value.body);
      //   unreadTotal = json["max"] ?? 0; // get total unread count

      //   // get unread counts for each subscription
      //   json["unreadcounts"].forEach((element) {
      //     if (subs[element["id"]] == null) {
      //       subs[element["id"]] = {};
      //     }
      //     subs[element["id"]]["count"] = element["count"] ?? 0;
      //   });
      // }),
      _getAllArticles(auth, "reading-list"),
    ]);
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

  // Future<http.Response> _getModifyAuth(String auth) {
  //   return http.post(
  //     Uri.parse("$server/reader/api/0/token"),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Accept': 'application/json',
  //       'Authorization': 'GoogleLogin auth=$auth',
  //     },
  //   );
  // }

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
    String url =
        "$server/reader/api/0/stream/contents/$feed?xt=user/-/state/com.google/read&n=500";
    String con = "";
    Set<String> syncedArticleIDs = <String>{};
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
        updatedTime = res["updated"] ?? 0;
        List<Article> articles = [];
        res["items"].forEach((json) {
          Article article = Article.fromCloudJson(json);
          // if (article.content.length > 5000) {
          //   article.content = article.content.substring(0, 4000);
          // }
          articleIDs.add(article.id);
          syncedArticleIDs.add(article.id);
          articles.add(article);
        });

        db!.saveArticles(articles);
        con = res["continuation"]?.toString() ?? "";
      }).catchError((onError) {
        if (kDebugMode) {
          throw onError;
        }
        debugPrint(onError.toString());
      });
    } while (con != "");
    db!.syncArticlesRead(syncedArticleIDs);
  }

  Future<bool> _setServerUnread(
      List<String> ids, List<String> subIDs, bool isRead) async {
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

  void setRead(String id, String subID, bool isRead) {
    _setServerUnread([id], [subID], isRead);
    db!.updateArticleRead(id, isRead);
  }

  Future<void> getFilteredArticles(bool? showAll,
      String? filterColumn, String? filterValue) async {
    await db!
        .loadArticleIDs(showAll: showAll,filterColumn: filterColumn, filterValue: filterValue)
        .then((value) {
      filteredArticleIDs = value.keys.toSet();
    });
    if (filterValue != null && filterValue.startsWith("feed/")) {
      filteredTitle = subs[filterValue]?.title;
    } else {
    filteredTitle = filterValue?? "All Articles";
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
          newMatch[0]!.endsWith(".jpeg") ||
          newMatch[0]!.endsWith(".png") ||
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

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

class ApiData extends ChangeNotifier {
  String server = "";
  String userName = "";
  String password = "";
  String auth = "";
  // String modifyAuth = "";
  Map<String, Subscription> subs = {};
  Set<String> tags = <String>{};
  Map<String, Article> articles = {};
  bool _showAll = false;
  int updatedTime = 0;
  int unreadTotal = 0;
  Map<String, DelayedAction> delayedActions = {};

  String filter = "";
  String title = "";
  Map<String, Article>? filteredArticles;
  int? filteredIndex;

  Future<bool> load() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    for (var element in (jsonDecode(preferences.getString("subs") ?? "{}")
            as Map<String, dynamic>)
        .entries) {
      subs[element.key] = Subscription.fromJson(element.value);
    }
    tags = preferences.getStringList("tags")?.toSet() ?? tags;
    preferences.getStringList("articles")?.forEach((element) {
      Map<String, dynamic> json = jsonDecode(element);
      articles[json["id"]] = Article.fromJson(json);
    });
    updatedTime = preferences.getInt("updatedTime") ?? updatedTime;
    unreadTotal = preferences.getInt("unreadTotal") ?? unreadTotal;

    server = preferences.getString("server") ?? "";
    userName = preferences.getString("userName") ?? "";
    password = preferences.getString("password") ?? "";
    auth = preferences.getString("auth") ?? "";

    preferences.getStringList("newRead")?.forEach((id) {
      delayedActions[id] = DelayedAction.read;
    });
    preferences.getStringList("newUnread")?.forEach((id) {
      delayedActions[id] = DelayedAction.unread;
    });

    notifyListeners();
    return true;
  }

  Future<bool> save() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> newUnread = [];
    List<String> newRead = [];
    for (var entry in delayedActions.entries) {
      if (entry.value == DelayedAction.read) {
        newRead.add(entry.key);
      } else if (entry.value == DelayedAction.unread) {
        newUnread.add(entry.key);
      }
    }
    await Future.wait([
      preferences.setString("subs", jsonEncode(subs)),
      preferences.setStringList("tags", tags.toList()),
      preferences.setStringList("articles",
          articles.values.map<String>((e) => jsonEncode(e.toJson())).toList()),
      preferences.setInt("updatedTime", updatedTime),
      preferences.setInt("unreadTotal", unreadTotal),
      preferences.setString("server", server),
      preferences.setString("userName", userName),
      preferences.setString("password", password),
      preferences.setString("auth", auth),
      preferences.setStringList("newUnread", newUnread.toList()),
      preferences.setStringList("newRead", newRead.toList()),
    ]);
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

    if (delayedActions.isNotEmpty) {
      _setUnread(
          delayedActions.entries
              .where((entry) => entry.value == DelayedAction.read)
              .map((entry) => entry.key)
              .toList(),
          true);
      _setUnread(
          delayedActions.entries
              .where((entry) => entry.value == DelayedAction.unread)
              .map((entry) => entry.key)
              .toList(),
          false);
    }

    await Future.wait([
      // _getModifyAuth(auth)
      //     .then((value) => modifyAuth = value.body.replaceAll("\n", "")),
      _getTags(auth).then((value) {
        jsonDecode(value.body)["tags"].forEach((element) {
          tags.add(element["id"]?.split("/").last ?? "");
        });
        List<String> list = tags.toList()..sort(); // sort the set
        tags = list.toSet();
      }).catchError((onError) {
        if (kDebugMode) {
          throw onError;
        }
        debugPrint(onError.toString());
      }),
      _getSubscriptions(auth).then((value) {
        jsonDecode(value.body)["subscriptions"].forEach((element) {
          List<String> categories = [];
          element["categories"].forEach((cat) {
            categories.add(cat["label"]);
          });
          if (subs[element["id"]] == null) {
            subs[element["id"]] = Subscription.fromJson(element);
          } else {
            subs[element["id"]]!.title =
                element["title"] ?? subs[element["id"]]!.title;
            subs[element["id"]]!.url =
                element["url"] ?? subs[element["id"]]!.url;
            subs[element["id"]]!.htmlUrl =
                element["htmlUrl"] ?? subs[element["id"]]!.htmlUrl;
            subs[element["id"]]!.iconUrl =
                element["iconUrl"] ?? subs[element["id"]]!.iconUrl;
            subs[element["id"]]!.categories = categories;
          }
        });
      }).catchError((onError) {
        if (kDebugMode) {
          throw onError;
        }
        debugPrint(onError.toString());
      }),
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
      _getAllArticles(auth, "reading-list").then((value) {
        for (Article article in value) {
          if (articles.containsKey(article.id)) {
            articles[article.id]!.read = false;
            delayedActions.remove(article.id);
          } else {
            articles[article.id] = article;
          }
        }
        articles = Map.fromEntries(articles.entries.toList()
          ..sort((a, b) => b.value.published - a.value.published));
        //change read article
        articles.forEach((id, article) {
          if (value.where((test) => test.id == id).isEmpty) {
            articles[id]!.read = true;
          }
        });
      }).catchError((onError) {
        if (kDebugMode) {
          throw onError;
        }
        debugPrint(onError.toString());
      }),
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

  Future<http.Response> _getSubscriptions(String auth) {
    return http.get(
      Uri.parse("$server/reader/api/0/subscription/list?output=json"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'GoogleLogin auth=$auth',
      },
    );
  }

  Future<http.Response> _getTags(String auth) {
    return http.get(
      Uri.parse("$server/reader/api/0/tag/list?output=json"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'GoogleLogin auth=$auth',
      },
    );
  }

  // Future<http.Response> _getUnreadCounts(String auth) {
  //   return http.post(
  //     Uri.parse("$urlBase/reader/api/0/unread-count?output=json"),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Accept': 'application/json',
  //       'Authorization': 'GoogleLogin auth=$auth',
  //     },
  //   );
  // }

  Future<List<Article>> _getAllArticles(String auth, String feed) async {
    String url =
        "$server/reader/api/0/stream/contents/$feed?xt=user/-/state/com.google/read&n=1000";
    String con = "";
    List<Article> newArticles = [];
    do {
      await http.get(
        Uri.parse("$url${con == "" ? "" : "&c=$con"}"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'GoogleLogin auth=$auth',
        },
      ).then((value) {
        dynamic res = jsonDecode(String.fromCharCodes(value.bodyBytes));
        updatedTime = res["updated"] ?? 0;
        res["items"].forEach((json) {
          newArticles.add(Article.fromCloudJson(json));
        });
        con = res["continuation"]?.toString() ?? "";
      }).catchError((onError) {
        if (kDebugMode) {
          throw onError;
        }
        debugPrint(onError.toString());
      });
    } while (con != "");
    return newArticles;
  }

  Future<bool> _setUnread(List<String> ids, bool isRead) async {
    String idString = "?";
    for (String id in ids) {
      if (articles.containsKey(id) && subs.containsKey(articles[id]!.feedId)) {
        idString += "s=feed/${subs[articles[id]!.feedId]!.url}&i=$id&";
      }
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
      } else {
        for (var id in ids) {
          delayedActions[id] =
              isRead ? DelayedAction.read : DelayedAction.unread;
        }
      }
    }).catchError((onError) {
      for (var id in ids) {
        delayedActions[id] = isRead ? DelayedAction.read : DelayedAction.unread;
      }
      if (kDebugMode) {
        throw onError;
      }
      debugPrint(onError.toString());
    });
    save();
    return true;
  }

  bool isRead(String id) {
    return articles[id]?.read ?? false;
  }

  void setRead(String id, bool isRead) {
    if (articles.containsKey(id)) {
      articles[id]!.read = isRead;
      delayedActions[id] = isRead ? DelayedAction.read : DelayedAction.unread;
      _setUnread([id], isRead);
    }
  }

  void getFilteredArticles(String filter) {
    Map<String, Article> newList = {};
    articles.forEach((key, value) {
      newList[key] = value;
    });
    if (!_showAll) {
      newList.removeWhere((key, value) => value.read);
    }
    if (filter == "") {
      filteredArticles = newList;
    } else if (filter.startsWith("feed/")) {
      newList.removeWhere((key, value) => value.feedId != filter);
      filteredArticles = newList;
    } else {
      Set<String> feedIds = <String>{};
      for (var key in subs.keys) {
        if (subs[key]!.categories.contains(filter)) {
          feedIds.add(key);
        }
      }
      newList.removeWhere((key, value) => !feedIds.contains(value.feedId));
      filteredArticles = newList;
    }
    notifyListeners();
  }

  bool getShowAll() {
    return _showAll;
  }

  void setShowAll(bool newValue) {
    _showAll = newValue;
    // notifyListeners();
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

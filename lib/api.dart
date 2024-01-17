import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'data_types.dart';

class Api extends InheritedNotifier<ApiData> {
  const Api({super.key, required super.child, required super.notifier});

  static ApiData of(BuildContext context) {
    assert(context.dependOnInheritedWidgetOfExactType<Api>() != null,
        "Api not found in current context");
    return context.dependOnInheritedWidgetOfExactType<Api>()!.notifier!;
  }

  @override
  bool updateShouldNotify(covariant InheritedNotifier<ApiData> oldWidget) {
    return notifier != oldWidget.notifier;
  }
}

class ApiData extends ChangeNotifier {
  String urlBase = "http://192.168.100.20/freshrss/p/api/greader.php";
  String userName = "hassanali92";
  String password = "PfHdPfH123";
  String auth = "";
  String modifyAuth = "";
  Map<String, Subscription> subs = {};
  Set<String> tags = <String>{};
  Map<String, Article> articles = {};
  bool _showAll = false;
  int updatedTime = 0;
  int unreadTotal = 0;
  Map<String, dynamic> unread = {};

  ApiData();

  Future<bool> storageLoad() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    (jsonDecode(prefs.getString("subs") ?? "{}") as Map<String, dynamic>)
        .entries
        .forEach((element) {
      subs[element.key] = Subscription.fromJson(element.value);
    });
    tags = prefs.getStringList("tags")?.toSet() ?? tags;
    prefs.getStringList("articles")?.forEach((element) {
      Map<String, dynamic> json = jsonDecode(element);
      articles[json["id"]] = Article.fromJson(json);
    });
    updatedTime = prefs.getInt("updatedTime") ?? updatedTime;
    unreadTotal = prefs.getInt("unreadTotal") ?? unreadTotal;
    return true;
  }

  Future<bool> storageSave() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString("subs", jsonEncode(subs)),
      prefs.setStringList("tags", tags.toList()),
      prefs.setStringList("articles",
          articles.values.map<String>((e) => jsonEncode(e.toJson())).toList()),
      prefs.setInt("updatedTime", updatedTime),
      prefs.setInt("unreadTotal", unreadTotal),
    ]);
    return true;
  }

  Future<bool> networkLoad() async {
    if (auth == "") {
      await _getAuth(Uri.parse(
              "$urlBase/accounts/ClientLogin?Email=$userName&Passwd=$password"))
          .then((value) {
        auth = value;
      });
    }
    await Future.wait([
      _getModifyAuth(auth).then((value) => modifyAuth = value.body),
      _getTags(auth).then((value) {
        jsonDecode(value.body)["tags"].forEach((element) {
          tags.add(element["id"]?.split("/").last ?? "");
        });
        List<String> list = tags.toList()..sort(); // sort the set
        tags = list.toSet();
      }),
      _getSubscriptions(auth).then((value) {
        jsonDecode(value.body)["subscriptions"].forEach((element) {
          List<String> categories = [];
          element["categories"].forEach((cat) {
            categories.add(cat["label"]);
          });
          if (subs[element["id"]] == null) {
            subs[element["id"]] = Subscription(
              id: element["id"],
              title: element["title"] ?? "",
              url: element["url"] ?? "",
              htmlUrl: element["htmlUrl"] ?? "",
              iconUrl: element["iconUrl"] ?? "",
              categories: categories,
            );
          } else {
            subs[element["id"]]!.title = element["title"] ?? "";
            subs[element["id"]]!.url = element["url"] ?? "";
            subs[element["id"]]!.htmlUrl = element["htmlUrl"] ?? "";
            subs[element["id"]]!.iconUrl = element["iconUrl"] ?? "";
            subs[element["id"]]!.categories = categories;
          }
        });
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
          } else {
            articles[article.id] = article;
          }
        }
        articles = Map.fromEntries(articles.entries.toList()
          ..sort((a, b) => b.value.published - a.value.published));
      }),
    ]);
    await storageSave();
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
      Uri.parse("$urlBase/reader/api/0/token"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'GoogleLogin auth=$auth',
      },
    );
  }

  Future<http.Response> _getSubscriptions(String auth) {
    return http.post(
      Uri.parse("$urlBase/reader/api/0/subscription/list?output=json"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'GoogleLogin auth=$auth',
      },
    );
  }

  Future<http.Response> _getTags(String auth) {
    return http.post(
      Uri.parse("$urlBase/reader/api/0/tag/list?output=json"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'GoogleLogin auth=$auth',
      },
    );
  }

  Future<http.Response> _getUnreadCounts(String auth) {
    return http.post(
      Uri.parse("$urlBase/reader/api/0/unread-count?output=json"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'GoogleLogin auth=$auth',
      },
    );
  }

  Future<List<Article>> _getAllArticles(String auth, String feed) async {
    String url =
        "$urlBase/reader/api/0/stream/contents/$feed?xt=user/-/state/com.google/read";
    String con = "";
    List<Article> newArticles = [];
    do {
      http.Response response = await http.post(
        Uri.parse("$url${con == "" ? "" : "&c=$con"}"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'GoogleLogin auth=$auth',
        },
      );
      dynamic res = jsonDecode(String.fromCharCodes(response.bodyBytes));
      updatedTime = res["updated"] ?? 0;
      res["items"].forEach((element) {
        newArticles.add(Article(
          id: element["id"] ?? "",
          feedId: element["origin"]["streamId"] ?? "",
          title: element["title"] ?? "",
          read: false,
          published: element["published"] ?? 0,
          content: element["summary"]["content"] ?? "",
          url: element["origin"]["htmlUrl"] ?? "",
          urls: (element["canonical"] ??
                  [
                    {"href": ""}
                  ])
              .map<String>((element) => element["href"] as String)
              .toList(),
          altUrls: (element["alternate"] ??
                  [
                    {"href": ""}
                  ])
              .map<String>((element) => element["href"] as String)
              .toList(),
        ));
      });
      con = res["continuation"]?.toString() ?? "";
    } while (con != "");
    return newArticles;
  }

  bool isRead(String id) {
    return articles[id]?.read ?? false;
  }

  void setRead(String id, bool isRead) {
    if (articles.containsKey(id)) {
      articles[id]!.read = isRead;
      storageSave();
      // notifyListeners();
    }
  }

  Map<String, Article> getFilteredArticles(String filter) {
    Map<String, Article> newList = {};
    articles.forEach((key, value) {
      newList[key] = value;
    });
    if (!_showAll) {
      newList.removeWhere((key, value) => value.read);
    }
    if (filter == "") {
      return newList;
    } else if (filter.startsWith("feed/")) {
      newList.removeWhere((key, value) => value.feedId != filter);
      return newList;
    } else {
      Set<String> feedIds = <String>{};
      for (var key in subs.keys) {
        if (subs[key]!.categories.contains(filter)) {
          feedIds.add(key);
        }
      }
      newList.removeWhere((key, value) => !feedIds.contains(value.feedId));
      return newList;
    }
  }

  bool getShowAll() {
    return _showAll;
  }

  void setShowAll(bool newValue) {
    _showAll = newValue;
    notifyListeners();
  }
}

String getFirstImage(String content) {
  RegExpMatch? match = RegExp('(?<=src=")(.*?)(?=")').firstMatch(content);
  return match?[0] ?? "";
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

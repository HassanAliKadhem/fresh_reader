import 'dart:convert';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:fresh_reader/main.dart';

import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import 'data_types.dart';
import 'database.dart';

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
  const Api({super.key, required super.child, required super.notifier});

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
  bool justBooted = true;
  Account? account;
  String auth = "";
  bool showAll = false;

  Map<String, Subscription> subscriptions = <String, Subscription>{};
  Set<String>? filteredArticleIDs;
  Map<String, Article>? filteredArticles;
  String? filteredTitle;
  int? filteredIndex;

  ApiData(this.account) {
    if (account != null) {
      loadAllSubs(account!.id).then((subs) {
        subscriptions = subs;
      });
      _getAuth().then((value) {
        auth = value;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    database.close();
  }

  void changeAccount(Account acc) {
    account = acc;
    justBooted = false;
    loadAllSubs(account!.id).then((subs) {
      notifyListeners();
      subscriptions = subs;
    });
    _getAuth().then((value) {
      auth = value;
    });
  }

  void setShowAll(bool newValue) {
    showAll = newValue;
    notifyListeners();
  }

  Future<bool> serverSync() async {
    if (auth == "") {
      await _getAuth().then((value) {
        auth = value;
      });
    }
    if (auth == "") {
      debugPrint("Couldn't find auth key");
      return false;
    }
    if (account == null) {
      debugPrint("No account selected");
      return false;
    }

    final delayedActions = await loadDelayedActions(account!.id);
    if (delayedActions.isNotEmpty) {
      Map<String, String> articleSub = {};
      for (var element in delayedActions.keys) {
        await loadArticleSubID(element, account!.id).then((value) {
          if (value != null) {
            articleSub[element] = value;
          }
        });
      }
      Map<String, String> readIds = {};
      Map<String, String> unReadIds = {};
      Map<String, String> starIds = {};
      Map<String, String> unStarIds = {};

      for (var element in delayedActions.entries) {
        if (articleSub[element.key] != null) {
          if (element.value == DelayedAction.read) {
            readIds[element.key] = articleSub[element.key]!;
          } else if (element.value == DelayedAction.unread) {
            unReadIds[element.key] = articleSub[element.key]!;
          } else if (element.value == DelayedAction.star) {
            starIds[element.key] = articleSub[element.key]!;
          } else if (element.value == DelayedAction.unStar) {
            unStarIds[element.key] = articleSub[element.key]!;
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
        unStarIds.keys.toList(),
        unStarIds.values.toList(),
        false,
      );
      debugPrint("synced delayed actions: ${delayedActions.length}");
    } else {
      debugPrint("no delayed actions");
    }
    // _getModifyAuth(auth)
    //     .then((value) => modifyAuth = value.body.replaceAll("\n", "")),
    await _getCategories(auth);
    await _getSubscriptions(auth);
    await _getAllArticles(auth, "reading-list");
    await Future.wait([
      _getReadIds(auth),
      _getStarredIds(auth),
      _getStarredArticles(auth),
    ]);
    //https://github.com/FreshRSS/FreshRSS/issues/2566
    return true;
  }

  Future<String> _getAuth() async {
    http.Response res = await http.post(
      Uri.parse(
        "${account?.serverUrl}/accounts/ClientLogin?Email=${account?.username}&Passwd=${account?.password}",
      ),
    );
    if (res.statusCode != 200) {
      throw Exception("${res.statusCode}: ${res.body}");
    }
    return res.body.split("Auth=").last.replaceAll("\n", "");
  }

  Future<http.Response> _getModifyAuth(String auth) {
    return http.post(
      Uri.parse("${account?.serverUrl}/reader/api/0/token"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'GoogleLogin auth=$auth',
      },
    );
  }

  Future<void> _getSubscriptions(String auth) async {
    int count = 0;
    http
        .get(
          Uri.parse(
            "${account?.serverUrl}/reader/api/0/subscription/list?output=json",
          ),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'GoogleLogin auth=$auth',
          },
        )
        .then((value) {
          final subs = <Subscription>[];
          jsonDecode(value.body)["subscriptions"].forEach((element) {
            subs.add(Subscription.fromJson(element, account!.id));
            count++;
          });
          saveSubs(subs);
          debugPrint("Fetched subscriptions: $count");
          loadAllSubs(account!.id).then((subs) {
            subscriptions = subs;
          });
        })
        .catchError((onError) {
          if (foundation.kDebugMode) {
            throw onError;
          }
          debugPrint(onError.toString());
        });
  }

  Future<void> _getCategories(String auth) async {
    int count = 0;
    await http
        .get(
          Uri.parse("${account?.serverUrl}/reader/api/0/tag/list?output=json"),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'GoogleLogin auth=$auth',
          },
        )
        .then((value) async {
          final batch = database.batch();
          jsonDecode(value.body)["tags"].forEach((element) {
            batch.insert(
              "Categories",
              Category.fromJson(element, account!.id).toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            count++;
          });
          await batch.commit(continueOnError: true);
          debugPrint("Fetched categories: $count");
        })
        .catchError((onError) {
          if (foundation.kDebugMode) {
            throw onError;
          }
          debugPrint(onError.toString());
        });
  }

  Future<void> _getAllArticles(String auth, String feed) async {
    int count = 0;
    bool updateTime = true;
    String url =
        "${account!.serverUrl}/reader/api/0/stream/contents/$feed?xt=user/-/state/com.google/read&n=1000&ot=${account!.updatedArticleTime}";
    String con = "";
    dynamic res;
    do {
      await http
          .get(
            Uri.parse("$url${con == "" ? "" : "&c=$con"}"),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
              'Authorization': 'GoogleLogin auth=$auth',
            },
          )
          .then((value) {
            res = jsonDecode(String.fromCharCodes(value.bodyBytes));
            List<Article> articles = [];
            res["items"].forEach((json) {
              Article article = Article.fromCloudJson(json, account!.id);
              articles.add(article);
              count++;
            });
            insertArticles(articles);
            con = res["continuation"]?.toString() ?? "";
          })
          .catchError((onError) {
            if (foundation.kDebugMode) {
              throw onError;
            }
            updateTime = false;
            debugPrint(onError.toString());
          });
    } while (con != "");
    if (updateTime) {
      account?.updatedArticleTime =
          (DateTime.now().millisecondsSinceEpoch / 1000).floor();
      database.update(
        "Account",
        {"updatedArticleTime": account!.updatedArticleTime},
        where: "id = ?",
        whereArgs: [account!.id],
      );
    }
    debugPrint("Fetched new articles: $count");
  }

  Future<void> _getReadIds(String auth) async {
    int count = 0;
    Set<String> syncedArticleIDs = <String>{};
    String con = "";
    do {
      http.Response response = await http.get(
        Uri.parse(
          "${account?.serverUrl}/reader/api/0/stream/items/ids?s=user/-/state/com.google/reading-list&xt=user/-/state/com.google/read&merge=true&ot=0&output=json&n=10000${con == "" ? "" : "&c=$con"}",
        ),
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
                "tag:google.com,2005:reader/item/${int.parse(json["id"]).toRadixString(16).padLeft(16, "0")}",
              );
              count++;
            }
          });
        }
        con = res["continuation"]?.toString() ?? "";
      } else {
        debugPrint(response.body);
      }
    } while (con != "");
    await syncArticlesRead(syncedArticleIDs, account!.id);
    debugPrint("Fetched readIds: $count");
  }

  Future<void> _getStarredIds(String auth) async {
    int count = 0;
    bool updateTime = true;
    Set<String> syncedArticleIDs = <String>{};
    String con = "";
    do {
      http.Response response = await http.get(
        Uri.parse(
          "${account?.serverUrl}/reader/api/0/stream/items/ids?s=user/-/state/com.google/starred&merge=true&xt=user/-/state/com.google/read&ot=${account?.updatedStarredTime}&output=json&n=10000${con == "" ? "" : "&c=$con"}",
        ),
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
                "tag:google.com,2005:reader/item/${int.parse(json["id"]).toRadixString(16).padLeft(16, "0")}",
              );
              count++;
            }
          });
        }
        con = res["continuation"]?.toString() ?? "";
      } else {
        debugPrint(response.body);
        updateTime = false;
      }
    } while (con != "");
    await syncArticlesStar(syncedArticleIDs, account!.id);

    if (updateTime) {
      account?.updatedStarredTime =
          (DateTime.now().millisecondsSinceEpoch / 1000).floor();
      database.update(
        "Account",
        {"updatedStarredTime": account!.updatedStarredTime},
        where: "id = ?",
        whereArgs: [account!.id],
      );
    }
    debugPrint("Fetched starredIDs: $count");
  }

  Future<void> _getStarredArticles(String auth) async {
    int count = 0;
    String con = "";
    do {
      http.Response response = await http.get(
        Uri.parse(
          "${account?.serverUrl}/reader/api/0/stream/contents/user/-/state/com.google/starred?it=user/-/state/com.google/read&xt=user/-/state/com.google/reading-list&ot=0&output=json&n=1000${con == "" ? "" : "&c=$con"}",
        ),
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
          Article article = Article.fromCloudJson(json, account!.id);
          article.read = true;
          article.starred = true;
          articles.add(article);
          count++;
        });
        insertArticles(articles);
        con = res["continuation"]?.toString() ?? "";
      } else {
        debugPrint(response.body);
      }
    } while (con != "");
    debugPrint("Fetched starred articles: $count");
  }

  Future<bool> _setServerRead(
    List<String> ids,
    List<String> subIDs,
    bool isRead,
  ) async {
    String idString = "?";
    bool done = false;
    for (int i = 0; i < ids.length; i++) {
      idString += "s=${subIDs[i]}&i=${ids[i]}&";
    }
    idString = "$idString${isRead ? "a" : "r"}=user/-/state/com.google/read";
    await http
        .post(
          Uri.parse("${account?.serverUrl}/reader/api/0/edit-tag"),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'GoogleLogin auth=$auth',
          },
          body: idString,
        )
        .then((value) {
          if (value.body == "OK") {
            debugPrint("Set server read: $ids");
            done = true;
          } else {
            debugPrint(value.body);
          }
        })
        .catchError((onError) {
          debugPrint(onError.toString());
        });
    if (!done) {
      Map<String, DelayedAction> actions = {};
      for (int i = 0; i < ids.length; i++) {
        actions[ids[i]] = isRead ? DelayedAction.read : DelayedAction.unread;
      }
      saveDelayedActions(actions, account!.id);
    }
    return done;
  }

  Future<bool> _setServerStar(
    List<String> ids,
    List<String> subIDs,
    bool isStar,
  ) async {
    String idString = "?";
    bool done = false;
    for (int i = 0; i < ids.length; i++) {
      idString += "s=${subIDs[i]}&i=${ids[i]}&";
    }
    idString = "$idString${isStar ? "a" : "r"}=user/-/state/com.google/starred";
    await http
        .post(
          Uri.parse("${account?.serverUrl}/reader/api/0/edit-tag"),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'GoogleLogin auth=$auth',
          },
          body: idString,
        )
        .then((value) {
          if (value.body == "OK") {
            done = true;
            debugPrint("Set server star: $ids");
          } else {
            debugPrint(value.body);
          }
        })
        .catchError((onError) {
          debugPrint(onError.toString());
        });
    if (!done) {
      Map<String, DelayedAction> actions = {};
      for (int i = 0; i < ids.length; i++) {
        actions[ids[i]] = isStar ? DelayedAction.star : DelayedAction.unStar;
      }
      saveDelayedActions(actions, account!.id);
    }
    return done;
  }

  Article? setRead(String id, String subID, bool isRead) {
    filteredArticles?[id]?.read = isRead;
    _setServerRead([id], [subID], isRead);
    updateArticleRead(id, isRead, account!.id);
    notifyListeners();
    return filteredArticles?[id];
  }

  void setStarred(String id, String subID, bool isStarred) {
    filteredArticles?[id]?.starred = isStarred;
    _setServerStar([id], [subID], isStarred);
    updateArticleStar(id, isStarred, account!.id);
    notifyListeners();
  }

  Future<void> getFilteredArticles(
    bool? showAll,
    String? filterColumn,
    String? filterValue,
    String title,
  ) async {
    if (account == null) {
      debugPrint("No Account selected");
      return;
    }
    filteredArticleIDs = null;
    filteredArticles = null;
    filteredIndex = null;
    filteredTitle = null;
    await loadArticleIDs(
      showAll: showAll,
      filterColumn: filterColumn,
      filterValue: filterValue,
      accountID: account!.id,
    ).then((value) {
      filteredArticleIDs = value.keys.toSet();
    });
    filteredTitle = title;
    await loadArticles(filteredArticleIDs!.toList(), account!.id).then((
      List<Article> arts,
    ) {
      filteredArticles = {};
      final Set<String> subIDs = <String>{};
      for (var article in arts) {
        filteredArticles![article.articleID] = article;
        subIDs.add(article.subID);
      }
      notifyListeners();
    });
  }

  String getIconUrl(String url) {
    url = url.replaceFirst(
      "http://localhost/FreshRss/p/",
      account?.serverUrl ?? "",
    );
    url = url.replaceFirst("api/greader.php", "");
    return url;
  }
}

// end of class
String? getFirstImage(String content) {
  RegExpMatch? match = RegExp('(?<=src=")(.*?)(?=")').firstMatch(content);
  if (match?[0] == null) {
    for (RegExpMatch newMatch in RegExp(
      '(?<=href=")(.*?)(?=")',
    ).allMatches(content)) {
      if (newMatch[0]!.endsWith(".jpg") ||
          newMatch[0]!.endsWith(".JPG") ||
          newMatch[0]!.endsWith(".JPEG") ||
          newMatch[0]!.endsWith(".jpeg") ||
          newMatch[0]!.endsWith(".png") ||
          newMatch[0]!.endsWith(".PNG") ||
          newMatch[0]!.endsWith(".webp") ||
          newMatch[0]!.endsWith(".tiff") ||
          newMatch[0]!.endsWith(".tif") ||
          newMatch[0]!.endsWith(".gif")) {
        return newMatch[0]!;
      }
    }
  }
  return match?[0];
}

String getRelativeDate(int secondsSinceEpoch) {
  DateTime articleTime = DateTime.fromMillisecondsSinceEpoch(
    secondsSinceEpoch * 1000,
  );
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
  DateTime articleTime = DateTime.fromMillisecondsSinceEpoch(
    secondsSinceEpoch * 1000,
  );
  DateTime now = DateTime.now();
  Duration difference = now.difference(articleTime);
  return difference.inDays;
}

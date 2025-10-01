import 'dart:convert';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import 'data_types.dart';
import 'database.dart';
import '../main.dart';

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
  Map<String, Category> categories = <String, Category>{};
  Map<String, int> counts = <String, int>{};
  Set<String>? filteredArticleIDs;
  Map<String, Article>? filteredArticles;
  List<String>? searchResults;
  String? filteredTitle;
  int? selectedIndex;
  ValueNotifier<double> progress = ValueNotifier<double>(1.0);

  ApiData(this.account) {
    if (account != null) {
      loadAllSubs(account!.id).then((subs) {
        subscriptions = subs;
        loadAllCategory(account!.id).then((cats) {
          categories = cats;
          countAllArticles(showAll, account!.id).then((con) {
            counts = con;
            notifyListeners();
          });
        });
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

  void clear() {
    filteredArticleIDs?.clear();
    selectedIndex = null;
    filteredArticles = {};
    searchResults = [];
  }

  void changeAccount(Account acc) {
    account = acc;
    justBooted = false;
    clear();
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
    clear();
    countAllArticles(showAll, account!.id).then((con) {
      counts = con;
      notifyListeners();
    });
  }

  Future<bool> serverSync() async {
    progress.value = 0.0;
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
    progress.value = 0.2;
    debugPrint("delayed actions: ${delayedActions.length}");
    debugPrint(delayedActions.toString());
    if (delayedActions.isNotEmpty) {
      Map<String, String> articleSub = {};
      for (var element in delayedActions.keys) {
        await loadArticleSubID(element, account!.id).then((value) {
          if (value != null) {
            articleSub[element] = value;
          }
          progress.value = 0.4;
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
      if (readIds.isNotEmpty) {
        await _setServerRead(
          readIds.keys.toList(),
          readIds.values.toList(),
          true,
        ).then((done) {
          if (done) {
            deleteDelayedActions(
              readIds.map((key, value) => MapEntry(key, DelayedAction.read)),
              account!.id,
            );
          }
        });
      }
      if (unReadIds.isNotEmpty) {
        await _setServerRead(
          unReadIds.keys.toList(),
          unReadIds.values.toList(),
          false,
        ).then((done) {
          if (done) {
            deleteDelayedActions(
              unReadIds.map(
                (key, value) => MapEntry(key, DelayedAction.unread),
              ),
              account!.id,
            );
          }
        });
      }
      if (starIds.isNotEmpty) {
        await _setServerStar(
          starIds.keys.toList(),
          starIds.values.toList(),
          true,
        ).then((done) {
          if (done) {
            deleteDelayedActions(
              starIds.map((key, value) => MapEntry(key, DelayedAction.star)),
              account!.id,
            );
          }
        });
      }
      if (unStarIds.isNotEmpty) {
        await _setServerStar(
          unStarIds.keys.toList(),
          unStarIds.values.toList(),
          false,
        ).then((done) {
          if (done) {
            deleteDelayedActions(
              unStarIds.map(
                (key, value) => MapEntry(key, DelayedAction.unStar),
              ),
              account!.id,
            );
          }
        });
      }
      debugPrint("synced delayed actions: ${delayedActions.length}");
    } else {
      debugPrint("no delayed actions");
    }
    await getPreference("read_duration").then((duration) {
      debugPrint("read duration to keep: $duration");
      int? days = int.tryParse(duration ?? "");
      if (duration != null && duration != "-1" && days != null) {
        DateTime now = DateTime.now();
        double seconds = now.millisecondsSinceEpoch / 1000;
        database
            .delete(
              "articles",
              where:
                  "accountID = ? and timeStampPublished < ? and isRead = ? and isStarred = ?",
              whereArgs: [
                account!.id,
                seconds - (days * 86400),
                "true",
                "false",
              ],
            )
            .then((count) {
              debugPrint("delete $count articles");
            });
      }
    });
    // await getPreference("star_duration").then((count) {
    //   // get number of starred articles to keep
    //   debugPrint("starred count to keep: $count");
    //   if (count != null && count != "-1") {
    //     // TODO: add code to delete starred articles
    //     int num = int.parse(count);
    //     database
    //         .query(
    //           "articles",
    //           columns: ["id"],
    //           where: "accountID = ? and isRead = ? and isStarred = ?",
    //           whereArgs: [account!.id, "true", "true"],
    //         )
    //         .then((value) {
    //           if (num > value.length) {
    //             // database.execute("Delete from articles where rowid IN (?)");
    //             // database.delete("articles",
    //             //   where: "id in (?)",
    //             //   whereArgs: [
    //             //     value.map((elm) => elm.values.first).join(",")
    //             //   ],
    //             // );
    //             print("to delete: ${value.length - num}");
    //             print("starred: count {${value.length}}, $value");
    //             print("starred ids: ${value.map((elm) => elm.values.first).join(",")}");
    //           }
    //         });
    //   }
    // });
    progress.value = 0.6;
    // _getModifyAuth(auth)
    //     .then((value) => modifyAuth = value.body.replaceAll("\n", "")),
    await _getServerCategories(auth);
    await _getServerSubscriptions(auth);
    await _getAllServerArticles(auth, "reading-list");
    await countAllArticles(showAll, account!.id).then((con) {
      counts = con;
    });
    progress.value = 0.8;
    await Future.wait([
      _getServerReadIds(auth),
      _getServerStarredIds(auth),
      _getServerStarredArticles(auth),
    ]);
    //https://github.com/FreshRSS/FreshRSS/issues/2566
    progress.value = 1.0;
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

  Future<void> _getServerSubscriptions(String auth) async {
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
            Subscription sub = Subscription.fromJson(element, account!.id);
            subs.add(sub);
            subscriptions[sub.subID] = sub;
            count++;
          });
          saveSubs(subs);
          debugPrint("Fetched subscriptions: $count");
          // loadAllSubs(account!.id).then((subs) {
          //   subscriptions = subs;
          // });
        })
        .catchError((onError) {
          if (foundation.kDebugMode) {
            throw onError;
          }
          debugPrint(onError.toString());
        });
  }

  Future<void> _getServerCategories(String auth) async {
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
            Category cat = Category.fromJson(element, account!.id);
            batch.insert(
              "Categories",
              cat.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            categories[cat.catID] = cat;
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

  Future<void> _getAllServerArticles(String auth, String feed) async {
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

  Future<void> _getServerReadIds(String auth) async {
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

  Future<void> _getServerStarredIds(String auth) async {
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

  Future<void> _getServerStarredArticles(String auth) async {
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
    if (filteredArticles != null && filteredArticles!.containsKey(id)) {
      int count() {
        return filteredArticles!.values
            .where((a) => a.subID == subID && !a.read)
            .length;
      }

      int subCountOld = count();
      filteredArticles![id]!.read = isRead;
      if (!showAll) {
        int subCount = count();
        counts.update(subID, (val) => subCount);
        // debugPrint(counts[subID].toString());
        if (subscriptions.containsKey(subID)) {
          counts.update(
            subscriptions[subID]!.catID,
            (val) => val - (subCountOld - subCount),
          );
          // debugPrint("Change: ${(subCountOld - subCount).toString()}");
          // debugPrint("Subscription: $subCount");
          // debugPrint("Category: ${counts[subscriptions[subID]!.catID]}");
        }
      }
    }
    _setServerRead([id], [subID], isRead);
    updateArticleRead(id, isRead, account!.id).then((_) {
      notifyListeners();
    });
    return filteredArticles?[id];
  }

  void setStarred(String id, String subID, bool isStarred) {
    filteredArticles?[id]?.starred = isStarred;
    if (showAll || filteredArticles?[id]?.read == false) {
      counts.update("Starred", (val) => val + (isStarred ? 1 : -1));
    }
    // debugPrint(counts["Starred"].toString());
    _setServerStar([id], [subID], isStarred);
    updateArticleStar(id, isStarred, account!.id).then((_) {
      notifyListeners();
    });
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
    selectedIndex = null;
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
      searchResults = [];
      // final Set<String> subIDs = <String>{};
      for (var article in arts) {
        filteredArticles![article.articleID] = article;
        // subIDs.add(article.subID);
        searchResults!.add(article.articleID);
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

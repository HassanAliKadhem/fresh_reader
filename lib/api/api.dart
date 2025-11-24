import 'dart:convert';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'data_types.dart';
import 'database.dart';

class ApiData extends ChangeNotifier {
  bool justBooted = true;
  Account? account;
  DB database;
  String auth = "";
  bool showAll = false;

  Map<String, Subscription> subscriptions = <String, Subscription>{};
  Map<String, Category> categories = <String, Category>{};
  // Map<String, int> counts = <String, int>{};
  Set<String>? filteredArticleIDs;
  Map<String, Article>? filteredArticles;
  Map<String, (int, String, bool, bool)> articlesMetaData = {};
  List<String>? searchResults;
  String? filteredTitle;
  int? _selectedIndex;
  int? get selectedIndex => _selectedIndex;
  set selectedIndex(int? i) {
    _selectedIndex = i;
    notifyListeners();
  }

  ApiData(this.database) {
    database.getAllAccounts().then((accounts) {
      if (accounts.isNotEmpty) {
        try {
          account = accounts.first;
        } catch (e, stack) {
          debugPrint(e.toString());
          debugPrintStack(stackTrace: stack);
        }
      } else {
        debugPrint("No accounts found");
      }

      if (account != null) {
        database.loadAllSubs(account!.id).then((subs) {
          subscriptions = subs;
          database.loadAllCategory(account!.id).then((cats) {
            categories = cats;
            database.loadArticleMetaData(account!.id).then((meta) {
              articlesMetaData = meta;
              notifyListeners();
            });
          });
        });
        _getAuth().then((value) {
          auth = value;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    database.database.close();
  }

  void clear([bool clearMeta = true]) {
    filteredArticleIDs?.clear();
    selectedIndex = null;
    filteredArticles = {};
    searchResults = [];
    if (clearMeta) {
      articlesMetaData = {};
    }
  }

  Future<List<Account>> getAccounts() async {
    return (await database.getAllAccounts());
  }

  Future<void> changeAccount(Account? acc) async {
    account = acc;
    justBooted = false;
    clear();
    subscriptions = {};
    categories = {};
    _getAuth().then((value) {
      auth = value;
    });
    if (acc != null) {
      await Future.wait([
        database.loadAllSubs(account!.id).then((subs) {
          subscriptions = subs;
        }),
        database.loadArticleMetaData(acc.id).then((meta) {
          articlesMetaData = meta;
        }),
        database.loadAllCategory(acc.id).then((cats) {
          categories = cats;
        }),
      ]).then((_) {
        notifyListeners();
      });
    }
  }

  void setShowAll(bool newValue) {
    showAll = newValue;
    clear(false);
    notifyListeners();
  }

  Stream<double> serverSync() async* {
    yield 0.0;
    if (auth == "") {
      await _getAuth().then((value) {
        auth = value;
      });
    }
    if (auth == "") {
      debugPrint("Couldn't find auth key");
      throw "No auth key";
    }
    if (account == null) {
      debugPrint("No account selected");
      throw "No account selected";
    }

    final delayedActions = await database.loadDelayedActions(account!.id);
    yield 0.1;
    debugPrint("delayed actions: ${delayedActions.length}");
    debugPrint(delayedActions.toString());
    if (delayedActions.isNotEmpty) {
      Map<String, String> articleSub = {};
      for (var element in delayedActions.keys) {
        await database.loadArticleSubID(element, account!.id).then((value) {
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
      if (readIds.isNotEmpty) {
        await _setServerRead(
          readIds.keys.toList(),
          readIds.values.toList(),
          true,
        ).then((done) {
          if (done) {
            database.deleteDelayedActions(
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
            database.deleteDelayedActions(
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
            database.deleteDelayedActions(
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
            database.deleteDelayedActions(
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
    yield 0.3;
    await database.getPreference("read_duration").then((duration) {
      debugPrint("read duration to keep: $duration");
      int? days = int.tryParse(duration ?? "");
      if (duration != null && duration != "-1" && days != null) {
        DateTime now = DateTime.now();
        double seconds = now.millisecondsSinceEpoch / 1000;
        database.database
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
    yield 0.4;
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

    // _getModifyAuth(auth)
    //     .then((value) => modifyAuth = value.body.replaceAll("\n", "")),
    await _getServerCategories(auth);
    await _getServerSubscriptions(auth);
    yield 0.5;
    await _getAllServerArticles(auth, "reading-list");
    yield 0.8;
    await _getServerReadIds(auth);
    await _getServerStarredIds(auth);
    await _getServerStarredArticles(auth);
    yield 0.9;
    articlesMetaData.clear();
    await database.loadArticleMetaData(account!.id).then((meta) {
      articlesMetaData = meta;
    });
    //https://github.com/FreshRSS/FreshRSS/issues/2566
    notifyListeners();
    yield 1.0;
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
          database.saveSubs(subs);
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
          List<dynamic> tags = jsonDecode(value.body)["tags"];
          database.insertNewCategories(tags, account!.id);
          for (var element in tags) {
            Category cat = Category.fromJson(element, account!.id);
            categories[cat.catID] = cat;
            count++;
          }
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
    database.clearLastSyncTable(account!.id);
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
            database.insertArticles(articles);
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
      database.database.update(
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
    await database.syncArticlesRead(syncedArticleIDs, account!.id);
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
    await database.syncArticlesStar(syncedArticleIDs, account!.id);

    if (updateTime) {
      account?.updatedStarredTime =
          (DateTime.now().millisecondsSinceEpoch / 1000).floor();
      database.database.update(
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
        database.insertArticles(articles);
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
      database.saveDelayedActions(actions, account!.id);
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
      database.saveDelayedActions(actions, account!.id);
    }
    return done;
  }

  Article? setRead(String id, String subID, bool isRead) {
    debugPrint("Set article: $id as ${isRead ? "Read" : "Unread"}");
    articlesMetaData.update(id, (val) => (val.$1, val.$2, isRead, val.$4));
    if (filteredArticles != null && filteredArticles!.containsKey(id)) {
      filteredArticles![id]!.read = isRead;
    }
    _setServerRead([id], [subID], isRead);
    database.updateArticleRead(id, isRead, account!.id).then((_) {
      notifyListeners();
    });
    return filteredArticles?[id];
  }

  void setStarred(String id, String subID, bool isStarred) {
    articlesMetaData.update(id, (val) => (val.$1, val.$2, val.$3, isStarred));
    filteredArticles?[id]?.starred = isStarred;
    // debugPrint(counts["Starred"].toString());
    _setServerStar([id], [subID], isStarred);
    database.updateArticleStar(id, isStarred, account!.id).then((_) {
      notifyListeners();
    });
  }

  Future<void> getFilteredArticles(
    bool? showAll,
    String? filterColumn,
    String? filterValue,
    String title,
    int todaySecondsSinceEpoch,
  ) async {
    if (account == null) {
      debugPrint("No Account selected");
      return;
    }
    filteredArticleIDs = null;
    filteredArticles = null;
    selectedIndex = null;
    filteredTitle = null;
    if (title == "lastSync") {
      await database.getLastSyncIDs(account!.id).then((value) {
        if (showAll == true) {
          filteredArticleIDs = value.toSet();
        } else {
          filteredArticleIDs = {};
          for (var id in value) {
            if (articlesMetaData[id]?.$3 == false) {
              filteredArticleIDs!.add(id);
            }
          }
        }
      });
    } else {
      await database
          .loadArticleIDs(
            showAll: showAll,
            filterColumn: filterColumn,
            filterValue: filterValue,
            accountID: account!.id,
            todaySecondsSinceEpoch: todaySecondsSinceEpoch,
          )
          .then((value) {
            filteredArticleIDs = value.keys.toSet();
          });
    }
    filteredTitle = title;
    await database.loadArticles(filteredArticleIDs!.toList(), account!.id).then(
      (List<Article> arts) {
        filteredArticles = {};
        searchResults = [];
        // final Set<String> subIDs = <String>{};
        for (var article in arts) {
          filteredArticles![article.articleID] = article;
          // subIDs.add(article.subID);
          searchResults!.add(article.articleID);
        }
        notifyListeners();
      },
    );
  }

  Future<Article> getArticleWithContent(Article article, int accountID) {
    return database.loadArticleContent(article, accountID);
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

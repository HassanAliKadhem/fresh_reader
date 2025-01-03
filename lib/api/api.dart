import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:fresh_reader/main.dart';
import 'package:http/http.dart' as http;

import 'database.dart';

const Utf8Decoder decoder = Utf8Decoder();

String? tryDecode(String original) {
  try {
    return decoder.convert(original.codeUnits);
  } catch (e) {
    return null;
  }
}

class ApiData {
  final AccountData account;
  String? auth;

  ApiData(this.account) {
    _getAuth(null).then((value) {
      auth = value;
    });
  }

  Future<bool> serverSync() async {
    // if (delayedActions.isNotEmpty) {
    //   // debugPrint(delayedActions.toString());
    //   Map<String, String> articleSub = {};
    //   for (var element in delayedActions.keys) {
    //     await db!.loadArticleSubID(element).then((value) {
    //       if (value != null) {
    //         articleSub[element] = value;
    //       }
    //     });
    //   }
    //   Map<String, String> readIds = {};
    //   Map<String, String> unReadIds = {};
    //   Map<String, String> starIds = {};
    //   Map<String, String> unstarIds = {};

    //   for (var element in delayedActions.entries) {
    //     if (articleSub[element.key] != null) {
    //       if (element.value == DelayedAction.read) {
    //         readIds[element.key] = articleSub[element.key]!;
    //       } else if (element.value == DelayedAction.unread) {
    //         unReadIds[element.key] = articleSub[element.key]!;
    //       } else if (element.value == DelayedAction.star) {
    //         starIds[element.key] = articleSub[element.key]!;
    //       } else if (element.value == DelayedAction.unStar) {
    //         unstarIds[element.key] = articleSub[element.key]!;
    //       }
    //     }
    //   }
    // await _setServerRead(
    //   readIds.keys.toList(),
    //   readIds.values.toList(),
    //   true,
    // );
    // await _setServerRead(
    //   unReadIds.keys.toList(),
    //   unReadIds.values.toList(),
    //   false,
    // );
    // await _setServerStar(
    //   starIds.keys.toList(),
    //   starIds.values.toList(),
    //   true,
    // );
    // await _setServerStar(
    //   unstarIds.keys.toList(),
    //   unstarIds.values.toList(),
    //   false,
    // );
    // }

    // _getModifyAuth(auth)
    //     .then((value) => modifyAuth = value.body.replaceAll("\n", "")),

    if (auth == null) {
      await _getAuth(null).then((value) {
        auth = value;
      });
    }
    if (auth != null) {
      int count = 0;
      await _getTags(auth!).then((response) async {
        jsonDecode(response.body)["tags"].forEach((element) {
          final data = CategoryCompanion.insert(
              serverID: element["id"],
              account: account.id,
              title: element["id"].toString().split("/").last,
              catUrl: element["url"] ?? "");
          database.into(database.category).insert(data,
              onConflict: DoUpdate((old) => data, target: [
                database.category.account,
                database.category.serverID,
              ]));
          count++;
        });
        debugPrint("fetched categories: $count");
        count = 0;
        List<CategoryData> categories =
            await (database.select(database.category)
                  ..where((tbl) => tbl.account.equals(account.id)))
                .get();

        await _getSubscriptions(auth!).then((response) async {
          jsonDecode(response.body)["subscriptions"].forEach((element) {
            String? categoryId = element["categories"].length == 0
                ? null
                : [...element["categories"]]
                    .map((cat) => cat["id"].toString())
                    .first;
            List<CategoryData> curCats = categories
                .where((cat) =>
                    cat.account == account.id && categoryId == cat.serverID)
                .toList();
            final data = SubscriptionCompanion.insert(
              serverID: element["id"],
              account: account.id,
              category: Value(categoryId != null ? curCats.first.id : null),
              url: element["url"],
              htmlUrl: element["htmlUrl"],
              iconUrl: getIconUrl(element["iconUrl"].toString()) ??
                  element["iconUrl"],
              title: tryDecode((element['title'] ?? "").toString()) ??
                  element['title'],
            );
            database.into(database.subscription).insert(data,
                onConflict: DoUpdate((old) => data, target: [
                  database.subscription.account,
                  database.subscription.serverID,
                ]));
            count++;
          });
        });
        debugPrint("fetched subscriptions: $count");
        List<SubscriptionData> subscriptions =
            await (database.select(database.subscription)
                  ..where((tbl) => tbl.account.equals(account.id)))
                .get();
        await _getAllArticles(auth!, "reading-list", categories, subscriptions);
      });

      await Future.wait([
        _getReadIds(auth!),
        _getStarredIds(auth!),
        _getStarredArticles(auth!),
      ]);
      //https://github.com/FreshRSS/FreshRSS/issues/2566
    } else {
      debugPrint("No auth key found");
    }
    return true;
  }

  Future<String> _getAuth(Uri? uriWithAuth) async {
    http.Response res = await http
        .post(uriWithAuth ??
            Uri.parse(
                "${account.serverUrl}/accounts/ClientLogin?Email=${account.userName}&Passwd=${account.password}"))
        .catchError((error, stackTrace) {
      debugPrint("$error\n$stackTrace");
      throw "$error\n$stackTrace";
    });
    if (res.statusCode != 200) {
      debugPrint("${res.statusCode}: ${res.body}");
    }
    return res.body.split("Auth=").last.replaceAll("\n", "");
  }

  // Future<http.Response> _getModifyAuth(String auth) {
  //   return http.post(
  //     Uri.parse("${account.serverUrl}/reader/api/0/token"),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Accept': 'application/json',
  //       'Authorization': 'GoogleLogin auth=$auth',
  //     },
  //   );
  // }

  Future<http.Response> _getTags(String auth) async {
    return await http.get(
      Uri.parse("${account.serverUrl}/reader/api/0/tag/list?output=json"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'GoogleLogin auth=$auth',
      },
    );
  }

  Future<http.Response> _getSubscriptions(String auth) async {
    return await http.get(
      Uri.parse(
          "${account.serverUrl}/reader/api/0/subscription/list?output=json"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'GoogleLogin auth=$auth',
      },
    );
  }

  Future<void> _getAllArticles(
      String auth,
      String feed,
      List<CategoryData> categories,
      List<SubscriptionData> subscriptions) async {
    bool updateTime = true;
    String url =
        "${account.serverUrl}/reader/api/0/stream/contents/$feed?xt=user/-/state/com.google/read&n=1000&ot=${account.updatedArticleTime}";
    String con = "";
    dynamic res;
    int count = 0;
    do {
      await http.get(
        Uri.parse("$url${con == "" ? "" : "&c=$con"}"),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'Authorization': 'GoogleLogin auth=$auth',
        },
      ).then((value) {
        res = jsonDecode(String.fromCharCodes(value.bodyBytes));
        res["items"].forEach((json) {
          int subindex = subscriptions.indexWhere((sub) =>
              sub.account == account.id &&
              sub.serverID == json["origin"]["streamId"]);
          final data = ArticleCompanion.insert(
            serverID: json["id"],
            account: account.id,
            subscription: subscriptions[subindex].id,
            title: tryDecode((json['title'] ?? "").toString()) ??
                json['title'] ??
                "",
            content: tryDecode(json["summary"]["content"].toString()) ??
                json["summary"]["content"].toString(),
            url: (json["canonical"])[0]["href"] as String,
            image: Value(getFirstImage(json["summary"]["content"].toString())),
            read: json["read"] ?? false,
            starred: false,
            published: json["published"],
          );
          database.into(database.article).insert(data,
              onConflict: DoUpdate((old) => data, target: [
                database.article.account,
                database.article.serverID,
                database.article.subscription,
              ]));
          count++;
        });
        con = res["continuation"]?.toString() ?? "";
      }).catchError((onError) {
        updateTime = false;
        debugPrint(onError.toString());
      });
    } while (con != "");
    if (updateTime) {
      await database.update(database.account).replace(account.copyWith(
          updatedArticleTime:
              (DateTime.now().millisecondsSinceEpoch / 1000).floor()));
    }
    debugPrint("fetched articles: $count");
  }

  Future<void> _getReadIds(String auth) async {
    Set<String> syncedArticleIDs = <String>{};
    String con = "";
    do {
      http.Response response = await http.get(
        Uri.parse(
            "${account.serverUrl}/reader/api/0/stream/items/ids?s=user/-/state/com.google/reading-list&xt=user/-/state/com.google/read&merge=true&ot=0&output=json&n=10000${con == "" ? "" : "&c=$con"}"),
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
    final count = await (database.update(database.article)
          ..where((tbl) => tbl.account.equals(account.id))
          ..where((tbl) => tbl.serverID.isIn(syncedArticleIDs)))
        .write(ArticleCompanion(read: Value(true)));
    debugPrint("fetched read id: $count");
  }

  Future<void> _getStarredIds(String auth) async {
    bool updateTime = true;
    Set<String> syncedArticleIDs = <String>{};
    String con = "";
    do {
      http.Response response = await http.get(
        Uri.parse(
            "${account.serverUrl}/reader/api/0/stream/items/ids?s=user/-/state/com.google/starred&merge=true&xt=user/-/state/com.google/read&ot=${account.updatedStarredTime}&output=json&n=10000${con == "" ? "" : "&c=$con"}"),
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
    final count = await (database.update(database.article)
          ..where((tbl) => tbl.account.equals(account.id))
          ..where((tbl) => tbl.serverID.isIn(syncedArticleIDs)))
        .write(ArticleCompanion(starred: Value(true)));
    debugPrint("fetched starred ids: $count");
    if (updateTime) {
      await database.update(database.account).replace(account.copyWith(
          updatedStarredTime:
              (DateTime.now().millisecondsSinceEpoch / 1000).floor()));
    }
  }

  Future<void> _getStarredArticles(String auth) async {
    List<SubscriptionData> subscriptions =
        await (database.select(database.subscription)
              ..where((tbl) => tbl.account.equals(account.id)))
            .get();
    String con = "";
    int count = 0;
    do {
      http.Response response = await http.get(
        Uri.parse(
            "${account.serverUrl}/reader/api/0/stream/contents/user/-/state/com.google/starred?it=user/-/state/com.google/read&xt=user/-/state/com.google/reading-list&ot=0&output=json&n=1000${con == "" ? "" : "&c=$con"}"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'GoogleLogin auth=$auth',
        },
      );
      if (response.statusCode == 200 && (response.contentLength ?? 0) > 0) {
        dynamic res = jsonDecode(String.fromCharCodes(response.bodyBytes));
        res["items"].forEach((json) {
          int subindex = subscriptions.indexWhere((sub) =>
              sub.account == account.id &&
              sub.serverID == json["origin"]["streamId"]);
          final data = ArticleCompanion.insert(
            serverID: json["id"],
            account: account.id,
            subscription: subscriptions[subindex].id,
            title: tryDecode((json['title'] ?? "").toString()) ??
                json['title'] ??
                "",
            content: tryDecode(json["summary"]["content"].toString()) ??
                json["summary"]["content"].toString(),
            url: (json["canonical"])[0]["href"] as String,
            image: Value(getFirstImage(json["summary"]["content"].toString())),
            read: true,
            starred: true,
            published: json["published"],
          );
          database.into(database.article).insert(data,
              onConflict: DoUpdate((old) => data, target: [
                database.article.account,
                database.article.serverID,
                database.article.subscription,
              ]));
          count++;
        });

        con = res["continuation"]?.toString() ?? "";
      } else {
        debugPrint(response.body);
      }
    } while (con != "");
    debugPrint("fetched starred articles: $count");
  }

  void _setServerRead(List<String> ids, List<String> subIDs, bool isRead) {
    String idString = "?";
    for (int i = 0; i < ids.length; i++) {
      idString += "s=${subIDs[i]}&i=${ids[i]}&";
    }
    idString = "$idString${isRead ? "a" : "r"}=user/-/state/com.google/read";
    http
        .post(Uri.parse("${account.serverUrl}}/reader/api/0/edit-tag"),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Authorization': 'GoogleLogin auth=$auth',
            },
            body: idString)
        .then((value) {
      if (value.body == "OK") {
        debugPrint("Items read status changed: ${ids.length}");
      }
    }).catchError((onError) {
      debugPrint(onError.toString());
    });
  }

  Future<bool> _setServerStar(
      List<String> ids, List<String> subIDs, bool isStar) async {
    String idString = "?";
    for (int i = 0; i < ids.length; i++) {
      idString += "s=${subIDs[i]}&i=${ids[i]}&";
    }
    idString = "$idString${isStar ? "a" : "r"}=user/-/state/com.google/starred";
    return await http
        .post(Uri.parse("${account.serverUrl}/reader/api/0/edit-tag"),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Authorization': 'GoogleLogin auth=$auth',
            },
            body: idString)
        .then((value) {
      if (value.body == "OK") {
        debugPrint("Items star status changed: ${ids.length}");
        return true;
      } else {
        debugPrint(value.body);
        return false;
      }
    }).catchError((onError) {
      debugPrint(onError.toString());
      return false;
    });
  }

  void setRead(ArticleData article, String subServerID, bool isRead) {
    (database.update(database.article)
          ..where(
            (tbl) => tbl.id.equals(article.id),
          ))
        .write(ArticleCompanion(read: Value(isRead)));
    _setServerRead([article.serverID], [subServerID], isRead);
  }

  void setStarred(ArticleData article, String subServerID, bool isStarred) {
    (database.update(database.article)
          ..where(
            (tbl) => tbl.id.equals(article.id),
          ))
        .write(ArticleCompanion(starred: Value(isStarred)));
    _setServerStar([article.serverID], [subServerID], isStarred);
  }

  String? getIconUrl(String originalIconUrl) {
    return originalIconUrl
        .replaceFirst("http://localhost/FreshRss/p/", account.serverUrl)
        .replaceFirst("api/greader.php", "");
  }
}

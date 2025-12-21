import 'dart:convert';

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'data_types.dart';

ApiBase getApi(Account account) {
  if (account.provider == "test") {
    return ApiTest(account);
  } else {
    return ApiFreshRss(account);
  }
}

abstract class ApiBase {
  Account account;
  ApiBase(this.account);

  Future<List<Subscription>> getServerSubscriptions();

  Future<List<Category>> getServerCategories();

  Stream<(int?, List<Article>)> getAllServerArticles();

  Future<Set<String>> getServerReadIds();

  Future<(int?, Set<String>)> getServerStarredIds();

  Future<List<Article>> getServerStarredArticles();

  Future<Map<String, DelayedAction>> setServerRead(
    List<String> ids,
    List<String> subIDs,
    bool isRead,
  );

  Future<Map<String, DelayedAction>> setServerStar(
    List<String> ids,
    List<String> subIDs,
    bool isStar,
  );
}

class ApiFreshRss extends ApiBase {
  String auth = "";
  String modifyAuth = "";

  ApiFreshRss(super.account) {
    _getAuth().then((a) {
      auth = a;
    });
    // _getModifyAuth(auth).then((a) {
    //   modifyAuth = a;
    // });
  }

  Future<String> _getAuth() async {
    http.Response res = await http.post(
      Uri.parse(
        "${account.serverUrl}/accounts/ClientLogin?Email=${account.username}&Passwd=${account.password}",
      ),
    );
    if (res.statusCode != 200) {
      throw Exception("${res.statusCode}: ${res.body}");
    }
    return res.body.split("Auth=").last.replaceAll("\n", "");
  }

  Future<String> _getModifyAuth() async {
    var res = await http.post(
      Uri.parse("${account.serverUrl}/reader/api/0/token"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'GoogleLogin auth=$auth',
      },
    );
    if (res.statusCode != 200) {
      throw Exception("${res.statusCode}: ${res.body}");
    }
    return res.body.replaceAll("\n", "");
  }

  @override
  Future<List<Subscription>> getServerSubscriptions() async {
    final subs = <Subscription>[];
    int count = 0;
    await http
        .get(
          Uri.parse(
            "${account.serverUrl}/reader/api/0/subscription/list?output=json",
          ),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'GoogleLogin auth=$auth',
          },
        )
        .then((value) {
          jsonDecode(value.body)["subscriptions"].forEach((element) {
            Subscription sub = Subscription.fromJson(element, account.id);
            subs.add(sub);
            count++;
          });
          debugPrint("Fetched subscriptions: $count");
        })
        .catchError((onError) {
          if (foundation.kDebugMode) {
            throw onError;
          }
          debugPrint(onError.toString());
        });
    return subs;
  }

  @override
  Future<List<Category>> getServerCategories() async {
    List<Category> cats = [];
    int count = 0;
    await http
        .get(
          Uri.parse("${account.serverUrl}/reader/api/0/tag/list?output=json"),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'GoogleLogin auth=$auth',
          },
        )
        .then((value) {
          List<dynamic> tags = jsonDecode(value.body)["tags"];
          for (var element in tags) {
            Category cat = Category.fromJson(element, account.id);
            cats.add(cat);
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
    return cats;
  }

  @override
  Stream<(int?, List<Article>)> getAllServerArticles() async* {
    int count = 0;
    bool updateTime = true;
    String url =
        "${account.serverUrl}/reader/api/0/stream/contents/reading-list?xt=user/-/state/com.google/read&n=1000&ot=${account.updatedArticleTime}";
    String con = "";
    do {
      try {
        var res = await http.get(
          Uri.parse("$url${con == "" ? "" : "&c=$con"}"),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Accept': 'application/json',
            'Authorization': 'GoogleLogin auth=$auth',
          },
        );
        var body = jsonDecode(String.fromCharCodes(res.bodyBytes));
        List<Article> articles = [];
        body["items"].forEach((json) {
          Article article = Article.fromCloudJson(json, account.id);
          articles.add(article);
          count++;
        });
        con = body["continuation"]?.toString() ?? "";
        yield (null, articles);
      } catch (e) {
        updateTime = false;
        debugPrint(e.toString());
        if (foundation.kDebugMode) {
          rethrow;
        } else {
          return;
        }
      }
    } while (con != "");
    if (updateTime) {
      account.updatedArticleTime =
          (DateTime.now().millisecondsSinceEpoch / 1000).floor();
      yield (account.updatedArticleTime, []);
    }
    debugPrint("Fetched new articles: $count");
  }

  @override
  Future<Set<String>> getServerReadIds() async {
    int count = 0;
    Set<String> syncedArticleIDs = <String>{};
    String con = "";
    do {
      http.Response response = await http.get(
        Uri.parse(
          "${account.serverUrl}/reader/api/0/stream/items/ids?s=user/-/state/com.google/reading-list&xt=user/-/state/com.google/read&merge=true&ot=0&output=json&n=10000${con == "" ? "" : "&c=$con"}",
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
    debugPrint("Fetched readIds: $count");
    return syncedArticleIDs;
  }

  @override
  Future<(int?, Set<String>)> getServerStarredIds() async {
    int count = 0;
    bool updateTime = true;
    Set<String> syncedArticleIDs = <String>{};
    String con = "";
    do {
      http.Response response = await http.get(
        Uri.parse(
          "${account.serverUrl}/reader/api/0/stream/items/ids?s=user/-/state/com.google/starred&merge=true&output=json&n=10000${con == "" ? "" : "&c=$con"}",
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
    debugPrint("Fetched starredIDs: $count");
    if (updateTime) {
      account.updatedStarredTime =
          (DateTime.now().millisecondsSinceEpoch / 1000).floor();
      return (account.updatedStarredTime, syncedArticleIDs);
    }
    return (null, syncedArticleIDs);
  }

  @override
  Future<List<Article>> getServerStarredArticles() async {
    int count = 0;
    String con = "";
    List<Article> articles = [];
    do {
      http.Response response = await http.get(
        Uri.parse(
          "${account.serverUrl}/reader/api/0/stream/contents/user/-/state/com.google/starred?it=user/-/state/com.google/read&xt=user/-/state/com.google/reading-lis&ot=${account.updatedStarredTime}&output=json&n=1000${con == "" ? "" : "&c=$con"}",
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'GoogleLogin auth=$auth',
        },
      );
      if (response.statusCode == 200 && (response.contentLength ?? 0) > 0) {
        dynamic res = jsonDecode(String.fromCharCodes(response.bodyBytes));
        res["items"].forEach((json) {
          Article article = Article.fromCloudJson(json, account.id);
          article.read = true;
          article.starred = true;
          articles.add(article);
          count++;
        });
        con = res["continuation"]?.toString() ?? "";
      } else {
        debugPrint(response.body);
      }
    } while (con != "");
    debugPrint("Fetched starred articles: $count");
    return articles;
  }

  @override
  Future<Map<String, DelayedAction>> setServerRead(
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
          Uri.parse("${account.serverUrl}/reader/api/0/edit-tag"),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'GoogleLogin auth=$auth',
          },
          body: idString,
        )
        .then((value) {
          if (value.body == "OK") {
            done = true;
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
      return actions;
    }
    return {};
  }

  @override
  Future<Map<String, DelayedAction>> setServerStar(
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
          Uri.parse("${account.serverUrl}/reader/api/0/edit-tag"),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'GoogleLogin auth=$auth',
          },
          body: idString,
        )
        .then((value) {
          if (value.body == "OK") {
            done = true;
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
      return actions;
    }
    return {};
  }
}

class ApiTest extends ApiBase {
  ApiTest(super.account);

  @override
  Stream<(int?, List<Article>)> getAllServerArticles() async* {
    yield (
      null,
      [
        Article(
          articleID: "articleID_1",
          subID: "subID/testFeed",
          accountID: account.id,
          title: "First article",
          read: false,
          starred: false,
          published: 0,
          content: "Hello world",
          url: "http://google.com/first",
        ),
      ],
    );

    yield (
      null,
      [
        Article(
          articleID: "articleID_2",
          subID: "subID/testFeed",
          accountID: account.id,
          title: "Second article",
          read: false,
          starred: true,
          published: 5,
          content: "Hello world",
          url: "http://google.com/second",
        ),
      ],
    );

    yield (1000, []);
  }

  @override
  Future<List<Category>> getServerCategories() async {
    return [
      Category(catID: "catID/Gaming", accountID: account.id, name: "Gaming"),
    ];
  }

  @override
  Future<Set<String>> getServerReadIds() async {
    return {};
  }

  @override
  Future<List<Article>> getServerStarredArticles() async {
    // TODO: implement getServerStarredArticles
    throw UnimplementedError();
  }

  @override
  Future<(int?, Set<String>)> getServerStarredIds() {
    // TODO: implement getServerStarredIds
    throw UnimplementedError();
  }

  @override
  Future<List<Subscription>> getServerSubscriptions() async {
    return [
      Subscription(
        subID: "subID/testFeed",
        catID: "catID/Gaming",
        accountID: account.id,
        title: "test feed",
        url: "http://google.com",
        htmlUrl: "http://google.com",
        iconUrl: "http://google.com",
      ),
    ];
  }

  @override
  Future<Map<String, DelayedAction>> setServerRead(
    List<String> ids,
    List<String> subIDs,
    bool isRead,
  ) async {
    return {};
  }

  @override
  Future<Map<String, DelayedAction>> setServerStar(
    List<String> ids,
    List<String> subIDs,
    bool isStar,
  ) async {
    return {};
  }
}

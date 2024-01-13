import 'dart:convert';

import 'package:http/http.dart' as http;

class Api {
  String urlBase = "http://192.168.100.20/freshrss/p/api/greader.php";
  String userName = "hassanali92";
  String password = "PfHdPfH123";
  String auth = "";
  String modifyAuth = "";
  Map<String, dynamic> subscriptions = {};
  Map<String, dynamic> tags = {};
  Map<String, dynamic> articles = {};
  Map<String, dynamic> unread = {};
  // Map<String, dynamic> list = {};

  Api();

  Future<void> test() async {
    if (auth == "") {
      await getAuth(Uri.parse(
              "$urlBase/accounts/ClientLogin?Email=$userName&Passwd=$password"))
          .then((value) {
        auth = value;
      }).catchError((onError) => print(onError));
    }
    await Future.wait([
      getModifyAuth(auth).then((value) => modifyAuth = value.body),
      getSubscriptions(auth)
          .then((value) => subscriptions = jsonDecode(value.body)),
      getTags(auth).then((value) => tags = jsonDecode(value.body)),
      getArticles(auth).then((value) => articles = jsonDecode(value.body)),
      getUnread(auth).then((value) => unread = jsonDecode(value.body)),
      // getList(auth).then((value) => list = jsonDecode(value.body)),
    ]);
  }

  Future<String> getAuth(Uri uriWithAuth) async {
    http.Response res = await http.post(uriWithAuth);
    if (res.statusCode != 200) {
      throw Exception("${res.statusCode}: ${res.body}");
    }
    return res.body.split("Auth=").last.replaceAll("\n", "");
  }

  Future<http.Response> getModifyAuth(String auth) {
    return http.post(
      Uri.parse("$urlBase/reader/api/0/token"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'GoogleLogin auth=$auth',
      },
    );
  }

  Future<http.Response> getSubscriptions(String auth) {
    return http.post(
      Uri.parse("$urlBase/reader/api/0/subscription/list?output=json"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'GoogleLogin auth=$auth',
      },
    );
  }

  Future<http.Response> getTags(String auth) {
    return http.post(
      Uri.parse("$urlBase/reader/api/0/tag/list?output=json"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'GoogleLogin auth=$auth',
      },
    );
  }

  Future<http.Response> getArticles(String auth) {
    return http.post(
      Uri.parse("$urlBase/reader/api/0/stream/contents/reading-list"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'GoogleLogin auth=$auth',
      },
    );
  }

  Future<http.Response> getUnread(String auth) {
    return http.post(
      Uri.parse("$urlBase/reader/api/0/unread-count?output=json"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'GoogleLogin auth=$auth',
      },
    );
  }

  // Future<http.Response> getList(String auth) {
  //   return http.post(
  //     Uri.parse("$urlBase/reader/api/0/tag/list?output=json"),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Accept': 'application/json',
  //       'Authorization': 'GoogleLogin auth=$auth',
  //     },
  //   );
  // }
}

Map<String, dynamic> getData(Api api) {
  Map<String, dynamic> data = {};
  // get tags
  List<dynamic> tags = [];
  api.tags["tags"].forEach((element) {
    tags.add(element["id"]?.split("/").last ?? "");
  });
  data["tags"] = tags;

  data["unreadTotal"] = api.unread["max"] ?? 0; // get total unread count

  // get unread counts for each subscription
  Map<String, dynamic> items = {};
  api.unread["unreadcounts"].forEach((element) {
    items[element["id"]] = {"count": element["count"] ?? 0};
  });

  // get subscription data for each feed
  api.subscriptions["subscriptions"].forEach((element) {
    items[element["id"]]["title"] = element["title"] ?? "";
    items[element["id"]]["url"] = element["url"] ?? "";
    items[element["id"]]["htmlUrl"] = element["htmlUrl"] ?? "";
    items[element["id"]]["iconUrl"] = element["iconUrl"] ?? "";
    List<String> categories = [];
    element["categories"].forEach((cat) {
      categories.add(cat["label"]);
    });
    items[element["id"]]["categories"] = categories;
  });
  data["subscriptions"] = items;

  //get updated time
  data["updated"] = api.articles["updated"] ?? 0;
  data["articles"] = [];
  // sort the articles into the appropriate feed
  api.articles["items"].forEach((element) {
    data["articles"].add({
      "feedId": element["origin"]["streamId"],
      "read": false,
      "published": element["published"],
      "title": element["title"],
      "urls": element["canonical"],
      "altUrls": element["alternate"],
      "summary": element["summary"],
    });
  });
  return data;
}

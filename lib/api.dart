import 'dart:convert';

import 'package:http/http.dart' as http;

class Api {
  String urlBase = "http://192.168.100.20/freshrss/p/api/greader.php";
  String userName = "hassanali92";
  String password = "PfHdPfH123";
  String auth = "";
  String modifyAuth = "";
  Map<String, dynamic> subs = {};
  Set<String> tags = <String>{};
  List<dynamic> articles = [];
  int updatedTime = 0;
  int unreadTotal = 0;
  Map<String, dynamic> unread = {};

  Api();

  Future<bool> load() async {
    if (auth == "") {
      await getAuth(Uri.parse(
              "$urlBase/accounts/ClientLogin?Email=$userName&Passwd=$password"))
          .then((value) {
        auth = value;
      });
    }
    await Future.wait([
      getModifyAuth(auth).then((value) => modifyAuth = value.body),
      getTags(auth).then((value) {
        jsonDecode(value.body)["tags"].forEach((element) {
          tags.add(element["id"]?.split("/").last ?? "");
        });
        List<String> list = tags.toList()..sort(); // sort the set
        tags = list.toSet();
      }),
      getSubscriptions(auth).then((value) {
        jsonDecode(value.body)["subscriptions"].forEach((element) {
          if (subs[element["id"]] == null) {
            subs[element["id"]] = {};
          }
          subs[element["id"]]["title"] = element["title"] ?? "";
          subs[element["id"]]["url"] = element["url"] ?? "";
          subs[element["id"]]["htmlUrl"] = element["htmlUrl"] ?? "";
          subs[element["id"]]["iconUrl"] = element["iconUrl"] ?? "";
          List<String> categories = [];
          element["categories"].forEach((cat) {
            categories.add(cat["label"]);
          });
          subs[element["id"]]["categories"] = categories;
        });
      }),
      getUnreadCounts(auth).then((value) {
        Map<String, dynamic> json = jsonDecode(value.body);
        unreadTotal = json["max"] ?? 0; // get total unread count

        // get unread counts for each subscription
        json["unreadcounts"].forEach((element) {
          if (subs[element["id"]] == null) {
            subs[element["id"]] = {};
          }
          subs[element["id"]]["count"] = element["count"] ?? 0;
        });
      }),
      getAllArticles(auth, "reading-list")
          .then((value) => articles.addAll(value)),
    ]);
    return true;
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

  // Future<http.Response> getArticles(String auth) {
  //   return http.post(
  //     Uri.parse("$urlBase/reader/api/0/stream/contents/reading-list&ot=0"),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Accept': 'application/json',
  //       'Authorization': 'GoogleLogin auth=$auth',
  //     },
  //   );
  // }

  Future<http.Response> getUnreadCounts(String auth) {
    return http.post(
      Uri.parse("$urlBase/reader/api/0/unread-count?output=json"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'GoogleLogin auth=$auth',
      },
    );
  }

  Future<List<dynamic>> getAllArticles(String auth, String feed) async {
    String url =
        "$urlBase/reader/api/0/stream/contents/$feed?xt=user/-/state/com.google/read";
    String con = "";
    List<dynamic> articles = [];
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
        articles.add({
          "feedId": element["origin"]["streamId"] ?? "",
          "read": false,
          "published": element["published"] ?? 0,
          "title": element["title"] ?? "",
          "url": element["origin"]["htmlUrl"] ?? "",
          "urls": element["canonical"] ??
              [
                {"href": ""}
              ],
          "altUrls": element["alternate"] ??
              [
                {"href": ""}
              ],
          "summary": element["summary"]["content"] ?? "",
        });
      });
      con = res["continuation"]?.toString() ?? "";
    } while (con != "");
    return articles;
  }
}

String getFirstImage(String content) {
  RegExpMatch? match = RegExp('(?<=src=")(.*?)(?=")').firstMatch(content);
  if (match != null && match?[0] != null) {
    print(match[0]);
  }
  return match?[0] ?? "";
}

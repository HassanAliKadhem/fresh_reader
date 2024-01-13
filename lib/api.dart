import 'dart:convert';

import 'package:http/http.dart' as http;

class Api {
  static String urlBase = "http://192.168.100.20/freshrss/p/api/greader.php";
  static String userName = "hassanali92";
  static String password = "PfHdPfH123";
  static String auth = "";
  static String modifyAuth = "";
  static Map<String, dynamic> subscriptions = {};
  static Map<String, dynamic> articles = {};
  static Map<String, dynamic> unread = {};
  static Map<String, dynamic> list = {};

  Api() {
    test();
  }

  void test() async {
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
      getArticles(auth).then((value) => articles = jsonDecode(value.body)),
      getUnread(auth).then((value) => unread = jsonDecode(value.body)),
      getList(auth).then((value) => list = jsonDecode(value.body)),
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

  Future<http.Response> getList(String auth) {
    return http.post(
      Uri.parse("$urlBase/reader/api/0/tag/list?output=json"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'GoogleLogin auth=$auth',
      },
    );
  }
}

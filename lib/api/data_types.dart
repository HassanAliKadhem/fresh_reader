// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:fresh_reader/api/api.dart';

const Utf8Decoder decoder = Utf8Decoder();

class Account {
  int id;
  String serverUrl;
  String provider;
  String username;
  String password;
  int updatedArticleTime;
  int updatedStarredTime;
  Account(
    this.id,
    this.serverUrl,
    this.provider,
    this.username,
    this.password,
    this.updatedArticleTime,
    this.updatedStarredTime,
  );

  Account copyWith({
    int? id,
    String? serverUrl,
    String? provider,
    String? username,
    String? password,
    int? updatedArticleTime,
    int? updatedStarredTime,
  }) {
    return Account(
      id ?? this.id,
      serverUrl ?? this.serverUrl,
      provider ?? this.provider,
      username ?? this.username,
      password ?? this.password,
      updatedArticleTime ?? this.updatedArticleTime,
      updatedStarredTime ?? this.updatedStarredTime,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'serverUrl': serverUrl,
      'provider': provider,
      'username': username,
      'password': password,
      'updatedArticleTime': updatedArticleTime,
      'updatedStarredTime': updatedStarredTime,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      map['id'] as int,
      map['serverUrl'] as String,
      map['provider'] as String,
      map['username'] as String,
      map['password'] as String,
      map['updatedArticleTime'] as int,
      map['updatedStarredTime'] as int,
    );
  }

  @override
  String toString() {
    return 'Account(id: $id, serverUrl: $serverUrl, provider: $provider, username: $username, password: $password, updatedArticleTime: $updatedArticleTime, updatedStarredTime: $updatedStarredTime)';
  }

  @override
  bool operator ==(covariant Account other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.serverUrl == serverUrl &&
        other.provider == provider &&
        other.username == username &&
        other.password == password &&
        other.updatedArticleTime == updatedArticleTime &&
        other.updatedStarredTime == updatedStarredTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        serverUrl.hashCode ^
        provider.hashCode ^
        username.hashCode ^
        password.hashCode ^
        updatedArticleTime.hashCode ^
        updatedStarredTime.hashCode;
  }
}

class Subscription {
  final String subID;
  final String catID;
  final int accountID;
  String title;
  String url;
  String htmlUrl;
  String iconUrl;

  Subscription({
    required this.subID,
    required this.catID,
    required this.accountID,
    required this.title,
    required this.url,
    required this.htmlUrl,
    required this.iconUrl,
  });

  Subscription.fromJson(Map<String, dynamic> json, this.accountID)
    : subID = json['id'] ?? "",
      catID = json["categories"][0]["id"],
      title = tryDecode((json['title'] ?? "").toString()) ?? json['title'],
      url = json["url"] ?? "",
      htmlUrl = json["htmlUrl"] ?? "",
      iconUrl = json["iconUrl"] ?? "";

  Subscription.fromDB(Map<String, Object?> db)
    : subID = db["subID"] as String,
      catID = (db["catID"] ?? "") as String,
      accountID = db["accountID"] as int,
      title = db["title"] as String,
      url = db["url"] as String,
      htmlUrl = db["htmlUrl"] as String,
      iconUrl = db["iconUrl"] as String;

  Map<String, Object?> toDB() => {
    "subID": subID,
    "catID": catID,
    "accountID": accountID,
    "title": title,
    "url": url,
    "htmlUrl": htmlUrl,
    "iconUrl": iconUrl,
  };
}

class Category {
  final String catID;
  final int accountID;
  String name;
  Category({required this.catID, required this.accountID, required this.name});

  Category copyWith({
    String? catID,
    String? subID,
    int? accountID,
    String? name,
  }) {
    return Category(
      catID: catID ?? this.catID,
      accountID: accountID ?? this.accountID,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'catID': catID,
      'accountID': accountID,
      'name': name,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      catID: map['catID'] as String,
      accountID: map['accountID'] as int,
      name: map['name'] as String,
    );
  }

  // Article.fromDB(Map<String, Object?> element)
  //     : articleID = element["articleID"] as String,
  //       subID = element["subID"] as String,
  //       title = element["title"] as String,
  //       read = element["isRead"] == "true",
  //       starred = element["isStarred"] == "true",
  //       published = element["timeStampPublished"] as int,
  //       content =
  //           element.containsKey("content") ? element["content"] as String : "",
  //       url = element["url"] as String,
  //       image = (element["img"] ?? "") as String;

  Category.fromJson(Map<String, Object?> element, this.accountID)
    : catID = element["id"] as String,
      name = (element["id"] as String).split("/").last;

  @override
  String toString() {
    return 'Category(catID: $catID, accountID: $accountID, name: $name)';
  }

  @override
  bool operator ==(covariant Category other) {
    if (identical(this, other)) return true;

    return other.catID == catID &&
        other.accountID == accountID &&
        other.name == name;
  }

  @override
  int get hashCode {
    return catID.hashCode ^ accountID.hashCode ^ name.hashCode;
  }
}

class Article {
  final String articleID;
  final String subID;
  final int accountID;
  String title;
  bool read;
  bool starred;
  int published;
  String content;
  String url;
  String? image;

  Article({
    required this.articleID,
    required this.subID,
    required this.accountID,
    required this.title,
    required this.read,
    required this.starred,
    required this.published,
    required this.content,
    required this.url,
    this.image,
    // required this.urls,
    // required this.altUrls,
  });

  Article.fromCloudJson(Map<String, dynamic> json, this.accountID)
    : articleID = json["id"],
      subID = json["origin"]["streamId"],
      title = tryDecode(json["title"].toString()) ?? json["title"].toString(),
      read = json["read"] ?? false,
      starred = false,
      published = json["published"],
      content =
          tryDecode(json["summary"]["content"].toString()) ??
          json["summary"]["content"].toString(),
      url = (json["canonical"])[0]["href"] as String,
      image = getFirstImage(json["summary"]["content"].toString());

  Article.fromDB(Map<String, Object?> element)
    : articleID = element["articleID"] as String,
      subID = element["subID"] as String,
      accountID = element["accountID"] as int,
      title = element["title"] as String,
      read = element["isRead"] == "true",
      starred = element["isStarred"] == "true",
      published = element["timeStampPublished"] as int,
      content =
          element.containsKey("content") ? element["content"] as String : "",
      url = element["url"] as String,
      image = (element["img"] ?? "") as String;

  Map<String, Object?> toDB() => {
    "articleID": articleID,
    "subID": subID,
    "accountID": accountID,
    "title": title,
    "isRead": read ? "true" : "false",
    "isStarred": starred ? "true" : "false",
    "timeStampPublished": published,
    "content": content,
    "url": url,
    "img": image,
  };
}

enum DelayedAction { unread, read, star, unStar }

enum ScreenSize { big, medium, small }

String? tryDecode(content) {
  try {
    return decoder.convert(content.codeUnits);
  } catch (e) {
    return null;
  }
}

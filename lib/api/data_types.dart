import 'package:fresh_reader/api/api.dart';

class Subscription {
  String id;
  String title;
  String url;
  String htmlUrl;
  String iconUrl;
  List<String> categories;

  Subscription({
    required this.id,
    required this.title,
    required this.url,
    required this.htmlUrl,
    required this.iconUrl,
    required this.categories,
  });

  Subscription.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? "",
        title = json['title'] ?? "",
        url = json["url"] ?? "",
        htmlUrl = json["htmlUrl"] ?? "",
        iconUrl = json["iconUrl"] ?? "",
        categories = (json["categories"] ?? [])
            .map<String>((cat) => cat.toString())
            .toList();

  Subscription.fromDB(Map<String, Object?> db, List<Map<String, Object?>> cats)
      : id = db["subID"] as String,
        title = db["title"] as String,
        url = db["url"] as String,
        htmlUrl = db["htmlUrl"] as String,
        iconUrl = db["iconUrl"] as String,
        categories = cats
            .where((cat) => cat["subID"] == db["subID"])
            .map((cat) => cat["name"] as String)
            .toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        "title": title,
        "url": url,
        "htmlUrl": htmlUrl,
        "iconUrl": iconUrl,
        "categories": categories,
      };

  Map<String, Object?> toDB() => {
        "subID": id,
        "title": title,
        "url": url,
        "htmlUrl": htmlUrl,
        "iconUrl": iconUrl,
      };
}

class Article {
  String id;
  String subID;
  String title;
  bool read;
  bool starred;
  int published;
  String content;
  String url;
  String? image;
  // List<String> urls;
  // List<String> altUrls;

  Article({
    required this.id,
    required this.subID,
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

  Article.fromCloudJson(Map<String, dynamic> json)
      : id = json["id"],
        subID = json["origin"]["streamId"],
        title = json["title"],
        read = json["read"] ?? false,
        starred = false,
        published = json["published"],
        content = json["summary"]["content"],
        url = (json["canonical"])[0]["href"] as String;
  // url = json["origin"]["htmlUrl"];
  // urls = (json["canonical"] ??
  //         [
  //           {"href": ""}
  //         ])
  //     .map<String>((element) => element["href"] as String)
  //     .toList(),
  // altUrls = (json["alternate"] ??
  //         [
  //           {"href": ""}
  //         ])
  //     .map<String>((element) => element["href"] as String)
  //     .toList();

  Article.fromDB(Map<String, Object?> element, bool loadContent)
      : id = element["articleID"] as String,
        subID = element["subID"] as String,
        title = element["title"] as String,
        read = element["isRead"] == "true",
        starred = element["isStarred"] == "true",
        published = element["timeStampPublished"] as int,
        content = loadContent ? element["content"] as String : "",
        url = element["url"] as String,
        image = getFirstImage(element["content"] as String);
  // urls = [],
  // altUrls = [];

  Map<String, Object?> toDB() => {
        "articleID": id,
        "subID": subID,
        "title": title,
        "isRead": read ? "true" : "false",
        "isStarred": starred ? "true" : "false",
        "timeStampPublished": published,
        "content": content,
        "url": url
      };
}

enum DelayedAction { unread, read, star, unstar }

enum ScreenSize { big, medium, small }

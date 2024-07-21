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

  Map<String, dynamic> toJson() => {
        'id': id,
        "title": title,
        "url": url,
        "htmlUrl": htmlUrl,
        "iconUrl": iconUrl,
        "categories": categories,
      };
}

class Article {
  String id;
  String feedId;
  String title;
  bool read;
  int published;
  String content;
  String url;
  List<String> urls;
  List<String> altUrls;

  Article({
    required this.id,
    required this.feedId,
    required this.title,
    required this.read,
    required this.published,
    required this.content,
    required this.url,
    required this.urls,
    required this.altUrls,
  });

  Article.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? "",
        feedId = json["feedId"] ?? "",
        title = json['title'] ?? "",
        read = json["read"] ?? false,
        published = json["published"] ?? 0,
        content = json["content"] ?? "",
        url = json["url"] ?? "",
        urls =
            (json["urls"] ?? []).map<String>((url) => url.toString()).toList(),
        altUrls = (json["altUrls"] ?? [])
            .map<String>((url) => url.toString())
            .toList();

  Article.fromCloudJson(Map<String, dynamic> json)
      : id = json["id"] ?? "",
        feedId = json["feedId"] ?? "",
        title = json["title"] ?? "",
        read = json["read"] ?? false,
        published = json["published"] ?? 0,
        content = json["summary"]["content"] ?? "",
        url = json["origin"]["htmlUrl"] ?? "",
        urls = (json["canonical"] ??
                [
                  {"href": ""}
                ])
            .map<String>((element) => element["href"] as String)
            .toList(),
        altUrls = (json["alternate"] ??
                [
                  {"href": ""}
                ])
            .map<String>((element) => element["href"] as String)
            .toList();

  Map<String, dynamic> toJson() => {
        "id": id,
        "feedId": feedId,
        "title": title,
        "read": read,
        "published": published,
        "content": content,
        "url": url,
        "urls": urls,
        "altUrls": altUrls,
      };
}

enum DelayedAction { unread, read }

enum ScreenSize { big, medium, small }
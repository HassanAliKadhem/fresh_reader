import 'package:flutter/material.dart';
import 'package:fresh_reader/api.dart';
import 'package:fresh_reader/article_list.dart';

class FeedList extends StatefulWidget {
  const FeedList({super.key, required this.title, required this.api});
  final String title;
  final Api api;

  @override
  State<FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<FeedList> {
  Map<String, dynamic> data = {};

  @override
  void initState() {
    super.initState();
    data = getData(widget.api);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: "Filter",
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: ListView.builder(
          itemCount: data["tags"]?.length ?? 0 + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return ListTile(
                title: const Text("All Articles"),
                trailing: Text(data["unreadTotal"]?.toString() ?? "0"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleList(
                            title: "All Articles",
                            articles: data["articles"].toList()),
                      ));
                },
              );
            } else {
              String tag = data["tags"][index - 1];
              Map<String, dynamic> currentSubscriptions = {};
              data["subscriptions"].forEach((key, value) {
                if ((value["categories"] ?? []).toString().contains(tag)) {
                  currentSubscriptions[key] = value;
                }
              });
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  shape: const Border(),
                  initiallyExpanded: true,
                  title: Text(tag),
                  trailing: IconButton(
                      onPressed: () {
                        List<String> ids = currentSubscriptions.keys.toList();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArticleList(
                                  title: tag,
                                  articles: data["articles"]
                                      .where((article) =>
                                          ids.contains(article["feedId"]))
                                      .toList()),
                            ));
                      },
                      icon: const Icon(Icons.arrow_forward_ios)),
                  childrenPadding: const EdgeInsets.all(8.0),
                  children: currentSubscriptions.keys
                      .map((e) => ListTile(
                            title: Text(currentSubscriptions[e]["title"]),
                            trailing: Text(
                                currentSubscriptions[e]["count"].toString()),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ArticleList(
                                        title: currentSubscriptions[e]["title"],
                                        articles: data["articles"]
                                            .where((article) =>
                                                article["feedId"] == e)
                                            .toList())),
                              );
                            },
                          ))
                      .toList(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

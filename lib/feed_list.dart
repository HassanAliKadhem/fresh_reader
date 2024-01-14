import 'package:flutter/material.dart';
import 'package:fresh_reader/api.dart';
import 'package:fresh_reader/article_list.dart';
import 'package:fresh_reader/settings_view.dart';

class FeedList extends StatefulWidget {
  const FeedList({
    super.key,
    required this.title,
  });
  final String title;

  @override
  State<FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<FeedList> {
  late Api api;

  @override
  void initState() {
    super.initState();
    api = Api();
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
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return SettingsView(
                    api: api,
                  );
                },
              ));
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: api.storageLoad(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return RefreshIndicator.adaptive(
              onRefresh: () async {
                await api.networkLoad();
                setState(() {
                  
                });
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: api.tags.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      title: const Text("All Articles"),
                      trailing: UnreadCount(api.unreadTotal.toString()),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArticleList(
                                  title: "All Articles",
                                  articles: api.articles),
                            ));
                      },
                    );
                  } else {
                    String tag = api.tags.elementAt(index - 1);
                    num tagCount = 0;
                    Map<String, dynamic> currentSubscriptions = {};
                    api.subs.forEach((key, value) {
                      if ((value["categories"] ?? [])
                          .toString()
                          .contains(tag)) {
                        currentSubscriptions[key] = value;
                        tagCount += value["count"];
                      }
                    });
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ExpansionTile(
                        shape: const Border(),
                        initiallyExpanded: true,
                        title: Text(tag),
                        childrenPadding: const EdgeInsets.all(8.0),
                        children: [
                          ListTile(
                            title: Text("All $tag"),
                            trailing: UnreadCount(tagCount.toString()),
                            onTap: () {
                              List<String> ids =
                                  currentSubscriptions.keys.toList();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArticleList(
                                        title: tag,
                                        articles: api.articles
                                            .where((article) =>
                                                ids.contains(article["feedId"]))
                                            .toList()),
                                  ));
                            },
                          ),
                          ...currentSubscriptions.keys
                              .map((e) => ListTile(
                                    title:
                                        Text(currentSubscriptions[e]["title"]),
                                    trailing: UnreadCount(
                                        currentSubscriptions[e]["count"]
                                            .toString()),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ArticleList(
                                                title: currentSubscriptions[e]
                                                    ["title"],
                                                articles: api.articles
                                                    .where((article) =>
                                                        article["feedId"] == e)
                                                    .toList())),
                                      );
                                    },
                                  ))
                              .toList()
                        ],
                      ),
                    );
                  }
                },
              ),
            );
          } else {
            return Center(
              child: snapshot.hasError
                  ? Text(snapshot.error.toString())
                  : const CircularProgressIndicator.adaptive(),
            );
          }
        },
      ),
    );
  }
}

class UnreadCount extends StatelessWidget {
  const UnreadCount(this.unread, {super.key});
  final String unread;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        color: Theme.of(context).dialogBackgroundColor,
      ),
      child: Text(unread),
    );
  }
}

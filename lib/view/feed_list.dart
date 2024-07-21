import 'package:flutter/material.dart';
import 'package:fresh_reader/widget/blur_bar.dart';
import 'package:fresh_reader/api/data_types.dart';

import '../api/api.dart';
import 'settings_view.dart';

class FeedList extends StatefulWidget {
  const FeedList({super.key, required this.title, required this.onSelect});
  final String title;
  final Function(String) onSelect;

  @override
  State<FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<FeedList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<bool>(
              icon: Icon(Api.of(context).getShowAll()
                  ? Icons.filter_alt_off
                  : Icons.filter_alt),
              // icon: const SizedBox(),
              value: Api.of(context).getShowAll(),
              items: const [
                DropdownMenuItem<bool>(
                  value: true,
                  child: Text("All "),
                ),
                DropdownMenuItem<bool>(
                  value: false,
                  child: Text("Unread "),
                ),
              ],
              onChanged: (showAll) {
                Api.of(context).setShowAll(showAll ?? false);
                setState(() {
                  
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return const SettingsView();
                },
              ));
            },
          ),
        ],
        flexibleSpace: const BlurBar(),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: CategoryList(
        onSelect: widget.onSelect,
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
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        color: Theme.of(context).dialogBackgroundColor,
      ),
      child: Text(unread),
    );
  }
}

class CategoryList extends StatefulWidget {
  const CategoryList({super.key, required this.onSelect});
  final Function(String) onSelect;

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  void openArticleList(BuildContext context, String filter) {
    widget.onSelect(filter);
  }

  dynamic networkError;

  @override
  Widget build(BuildContext context) {
    bool showAll = Api.of(context).getShowAll();
    List<Article> allArticles = Api.of(context)
        .articles
        .values
        .where((article) => showAll || !article.read)
        .toList();
    return RefreshIndicator.adaptive(
      displacement: kToolbarHeight * 2,
      onRefresh: () async {
        await Api.of(context).serverSync().then((value) {
          setState(() {
            networkError = null;
          });
        }).catchError((onError) {
          setState(() {
            networkError = onError;
          });
        });
      },
      child: networkError != null
          ? ListView(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(networkError.toString()),
                ),
              ],
            )
          : ListView.builder(
              // padding: const EdgeInsets.all(8.0),
              itemCount: Api.of(context).tags.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    title: const Text("All Articles"),
                    trailing: UnreadCount(allArticles.length.toString()),
                    onTap: () => openArticleList(context, ""),
                  );
                } else {
                  String tag = Api.of(context).tags.elementAt(index - 1);
                  Map<String, Subscription> currentSubscriptions = {};
                  Api.of(context).subs.forEach((key, value) {
                    if (value.categories.toString().contains(tag)) {
                      currentSubscriptions[key] = value;
                    }
                  });
                  return Card(
                    clipBehavior: Clip.hardEdge,
                    margin: const EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      title: Text(tag),
                      shape: const Border(),
                      initiallyExpanded: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      childrenPadding: const EdgeInsets.only(left: 40.0),
                      children: currentSubscriptions.keys.map<Widget>((key) {
                        int count = allArticles
                            .where((element) => element.feedId == key)
                            .length;
                        return Visibility(
                          visible: count > 0,
                          child: ListTile(
                            title: Text(currentSubscriptions[key]!.title),
                            trailing: UnreadCount(count.toString()),
                            onTap: () {
                              openArticleList(context, key);
                            },
                          ),
                        );
                      }).toList()
                        ..insert(
                            0,
                            ListTile(
                              title: Text("All $tag"),
                              onTap: () => openArticleList(context, tag),
                              trailing: UnreadCount(allArticles
                                  .where((element) => currentSubscriptions.keys
                                      .contains(element.feedId))
                                  .length
                                  .toString()),
                            )),
                    ),
                  );
                }
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fresh_reader/blur_bar.dart';
import 'package:fresh_reader/data_types.dart';

import 'api.dart';
import 'article_list.dart';
import 'settings_view.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<bool>(
              // icon: Icon(Api.of(context).getShowAll()
              //     ? Icons.filter_alt_off
              //     : Icons.filter_alt),
              icon: const SizedBox(),
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
      body: const CategoryList(),
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

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  void openArticleList(BuildContext context, String filter, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleList(
          key: ValueKey(filter + Api.of(context).getShowAll().toString()),
          title: title,
          filter: filter,
        ),
      ),
    ).then((value) {
      setState(() {});
    });
  }

  dynamic networkError;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      displacement: kToolbarHeight * 2,
      onRefresh: () async {
        await Api.of(context).networkLoad().then((value) {
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
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Text(networkError.toString()),
            )
          : ListView.builder(
              // padding: const EdgeInsets.all(8.0),
              itemCount: Api.of(context).tags.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    title: const Text("All Articles"),
                    trailing: UnreadCount(Api.of(context)
                        .getFilteredArticles("")
                        .length
                        .toString()),
                    onTap: () => openArticleList(context, "", "All Articles"),
                  );
                } else {
                  String tag = Api.of(context).tags.elementAt(index - 1);
                  Map<String, Subscription> currentSubscriptions = {};
                  Api.of(context).subs.forEach((key, value) {
                    if (value.categories.toString().contains(tag)) {
                      currentSubscriptions[key] = value;
                    }
                  });
                  return ExpansionTile(
                    title: Text(tag),
                    shape: const Border(),
                    initiallyExpanded: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    childrenPadding: const EdgeInsets.only(left: 40.0),
                    trailing: InkWell(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0, 16.0),
                        child: UnreadCount(Api.of(context)
                            .getFilteredArticles("")
                            .values
                            .where((element) => currentSubscriptions.keys
                                .contains(element.feedId))
                            .length
                            .toString()),
                      ),
                      onTap: () => openArticleList(context, tag, tag),
                    ),
                    children: currentSubscriptions.keys
                        .map((key) => ListTile(
                              title: Text(currentSubscriptions[key]!.title),
                              trailing: UnreadCount(Api.of(context)
                                  .getFilteredArticles("")
                                  .values
                                  .where((element) => element.feedId == key)
                                  .length
                                  .toString()),
                              onTap: () {
                                openArticleList(context, key,
                                    currentSubscriptions[key]!.title);
                              },
                            ))
                        .toList(),
                  );
                }
              },
            ),
    );
  }
}

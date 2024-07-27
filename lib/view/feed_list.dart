import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fresh_reader/widget/blur_bar.dart';
import 'package:fresh_reader/api/data_types.dart';

import '../api/api.dart';
import 'settings_view.dart';

class FeedList extends StatefulWidget {
  const FeedList({super.key, required this.title, required this.onSelect});
  final String title;
  final Function(String?, String?) onSelect;

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
                setState(() {});
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
  final int unread;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        color: Theme.of(context).dialogBackgroundColor,
      ),
      child: Text(unread.toString()),
    );
  }
}

class CategoryList extends StatefulWidget {
  const CategoryList({super.key, required this.onSelect});
  final Function(String?, String?) onSelect;

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  void openArticleList(BuildContext context, String? column, String? value) {
    widget.onSelect(column, value);
  }

  dynamic networkError;

  @override
  Widget build(BuildContext context) {
    bool showAll = Api.of(context).getShowAll();
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
          : FutureBuilder(
              future: Api.of(context).db!.countAllArticles(showAll),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return const Center(
                    child: SizedBox(
                      height: 48,
                      width: 48,
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  );
                }

                int allCount = 0;
                for (var element in snapshot.data!.entries) {
                  if (element.key.startsWith("feed")) {
                    allCount += element.value;
                  }
                }
                return ListView.builder(
                  itemCount: Api.of(context).tags.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        title: const Text("All Articles"),
                        trailing: UnreadCount(allCount),
                        onTap: () => openArticleList(context, null, null),
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
                          title: Text(tag.split("/").last),
                          shape: const Border(),
                          initiallyExpanded: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          childrenPadding: const EdgeInsets.only(left: 40.0),
                          children: currentSubscriptions.keys
                              .where((sub) =>
                                  showAll || (snapshot.data![sub] ?? 0) > 0)
                              .map<Widget>((key) {
                            return ListTile(
                              title: Text(currentSubscriptions[key]!.title),
                              trailing: UnreadCount(snapshot.data![key] ?? 0),
                              leading: SizedBox(
                                height: 28,
                                width: 28,
                                child: CachedNetworkImage(
                                  imageUrl: Api.of(context).getIconUrl(key)?? "",
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                              onTap: () {
                                openArticleList(context, "subID",
                                    currentSubscriptions[key]!.id.toString());
                              },
                            );
                          }).toList()
                            ..insert(
                              0,
                              ListTile(
                                title: Text("All ${tag.split("/").last}"),
                                trailing: UnreadCount(snapshot.data![tag] ?? 0),
                                onTap: () =>
                                    openArticleList(context, "tag", tag),
                              ),
                            ),
                        ),
                      );
                    }
                  },
                );
              }),
    );
  }
}

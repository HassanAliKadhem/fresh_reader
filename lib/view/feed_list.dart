import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fresh_reader/main.dart';
import 'package:fresh_reader/widget/blur_bar.dart';
import 'package:fresh_reader/api/data_types.dart';

import '../api/api.dart';
import 'settings_view.dart';

class FeedList extends StatefulWidget {
  const FeedList({super.key, required this.onSelect});
  final Function(String?, String?) onSelect;

  @override
  State<FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<FeedList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FreshReader"),
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
              )).then((_) {
                setState(() {});
              });
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
      bottomNavigationBar: BlurBar(
        child: SizedBox(
          height: MediaQuery.paddingOf(context).bottom,
        ),
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
  late Map<String, bool> isOpen = {};
  // Map.fromEntries(Api.of(context).tags.map((tag) => MapEntry(tag, true)));

  @override
  void initState() {
    super.initState();
    networkError = mainLoadError;
  }

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
                  padding: const EdgeInsets.all(16.0),
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
                  if (element.key.startsWith("feed/")) {
                    allCount += element.value;
                  }
                }
                return ListView(
                  children: [
                    ListTile(
                      selected: Api.of(context).filteredTitle == "All Articles",
                      title: const Text("All Articles"),
                      trailing: UnreadCount(allCount),
                      onTap: () => openArticleList(context, null, null),
                    ),
                    ListTile(
                      selected: Api.of(context).filteredTitle == "Starred",
                      title: const Text("Starred"),
                      trailing: UnreadCount(snapshot.data!["Starred"] ?? 0),
                      onTap: () =>
                          openArticleList(context, "isStarred", "true"),
                    ),
                    ...Api.of(context)
                        .tags
                        .where(
                            (tag) => tag != "user/-/state/com.google/starred")
                        .map(
                      (tag) {
                        Map<String, Subscription> currentSubscriptions = {};
                        Api.of(context).subs.forEach((key, value) {
                          if (value.categories.toString().contains(tag)) {
                            currentSubscriptions[key] = value;
                          }
                        });
                        bool isExpanded = true;
                        if (isOpen.containsKey(tag)) {
                          isExpanded = isOpen[tag]!;
                        } else {
                          isOpen[tag] = true;
                        }
                        return Card(
                          clipBehavior: Clip.hardEdge,
                          margin: const EdgeInsets.all(8.0),
                          child: ExpansionTile(
                            title: Text(tag.split("/").last),
                            shape: const Border(),
                            initiallyExpanded: isExpanded,
                            onExpansionChanged: (value) {
                              setState(() {
                                isOpen[tag] = value;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            childrenPadding: const EdgeInsets.only(left: 40.0),
                            children: [
                              ListTile(
                                selected: Api.of(context).filteredTitle == tag,
                                title: Text("All ${tag.split("/").last}"),
                                trailing: UnreadCount(snapshot.data![tag] ?? 0),
                                onTap: () =>
                                    openArticleList(context, "tag", tag),
                              ),
                              ...currentSubscriptions.keys
                                  .where((sub) =>
                                      showAll || (snapshot.data![sub] ?? 0) > 0)
                                  .map<Widget>(
                                (key) {
                                  return ListTile(
                                    selected: Api.of(context).filteredTitle ==
                                        currentSubscriptions[key]!.title,
                                    title:
                                        Text(currentSubscriptions[key]!.title),
                                    trailing:
                                        UnreadCount(snapshot.data![key] ?? 0),
                                    leading: SizedBox(
                                      height: 28,
                                      width: 28,
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            Api.of(context).getIconUrl(key) ??
                                                "",
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                    onTap: () {
                                      openArticleList(
                                          context,
                                          "subID",
                                          currentSubscriptions[key]!
                                              .id
                                              .toString());
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              }),
    );
  }
}

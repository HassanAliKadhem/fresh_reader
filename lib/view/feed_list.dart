import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fresh_reader/main.dart';
import 'package:fresh_reader/widget/blur_bar.dart';
import 'package:fresh_reader/api/data_types.dart';

import '../api/api.dart';
import '../api/database.dart';
import 'settings_view.dart';

class FeedList extends StatefulWidget {
  const FeedList({super.key, required this.onSelect});
  final Function(String?, String?, String) onSelect;

  @override
  State<FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<FeedList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FreshReader"),
        leading: FutureBuilder(
          future: database.query("Account"),
          builder: (context, accountSnapshot) {
            if (!accountSnapshot.hasData) {
              return CircularProgressIndicator.adaptive();
            }
            return MenuAnchor(
              menuChildren:
                  accountSnapshot.data!.isEmpty
                      ? [
                        MenuItemButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return SettingsView();
                              },
                            );
                          },
                          trailingIcon: Icon(Icons.add),
                          child: Text("Click here to add account"),
                        ),
                      ]
                      : accountSnapshot.data!
                          .map(
                            (acc) => MenuItemButton(
                              onPressed: () {
                                widget.onSelect(null, null, "");
                                Api.of(
                                  context,
                                ).changeAccount(Account.fromMap(acc));
                              },
                              leadingIcon:
                                  Api.of(context).account?.id == acc["id"]
                                      ? Icon(Icons.check)
                                      : null,
                              child: Text(
                                "${acc["provider"]}: ${acc["username"]}",
                              ),
                            ),
                          )
                          .toList(),
              builder: (_, MenuController controller, Widget? child) {
                return IconButton(
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  icon: const Icon(Icons.account_circle),
                );
              },
            );
          },
        ),
        actions: [
          MenuAnchor(
            menuChildren: [
              MenuItemButton(
                onPressed: () {
                  Api.of(context).setShowAll(true);
                },
                trailingIcon: Icon(Icons.filter_alt_off),
                child: Text("All Articles"),
              ),
              MenuItemButton(
                onPressed: () {
                  Api.of(context).setShowAll(false);
                },
                trailingIcon: Icon(Icons.filter_alt),
                child: Text("Only Unread"),
              ),
            ],
            builder: (_, MenuController controller, Widget? child) {
              return IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: Icon(
                  Api.of(context).showAll
                      ? Icons.filter_alt_off
                      : Icons.filter_alt,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
            onPressed: () {
              showAdaptiveDialog(
                context: context,
                builder: (context) {
                  return const SettingsView();
                },
              ).then((_) {
                setState(() {});
              });
            },
          ),
        ],
        flexibleSpace: const BlurBar(),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: CategoryList(onSelect: widget.onSelect),
      bottomNavigationBar: BlurBar(
        child: SizedBox(height: MediaQuery.paddingOf(context).bottom),
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
  final Function(String?, String?, String) onSelect;

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

  void openArticleList(
    BuildContext context,
    String? column,
    String? value,
    String title,
  ) {
    widget.onSelect(column, value, title);
  }

  dynamic networkError;

  @override
  Widget build(BuildContext context) {
    bool showAll = Api.of(context).showAll;
    return RefreshIndicator.adaptive(
      displacement: kToolbarHeight * 2,
      onRefresh: () async {
        await Api.of(context)
            .serverSync()
            .then((value) {
              setState(() {
                networkError = null;
              });
            })
            .catchError((onError) {
              setState(() {
                networkError = onError;
              });
            });
      },
      child:
          networkError != null
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
                future: database.query(
                  "Subscriptions",
                  where: "accountID = ?",
                  whereArgs: [Api.of(context).account?.id ?? -1],
                ),
                builder: (context, subSnapshot) {
                  return FutureBuilder(
                    future: database.query(
                      "Categories",
                      where: "accountID = ?",
                      whereArgs: [Api.of(context).account?.id ?? -1],
                    ),
                    builder: (context, catSnapshot) {
                      return FutureBuilder(
                        future: countAllArticles(
                          showAll,
                          Api.of(context).account?.id ?? -1,
                        ),
                        builder: (context, countSnapshot) {
                          if (countSnapshot.data == null) {
                            return const Center(
                              child: SizedBox(
                                height: 48,
                                width: 48,
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            );
                          }
                          int allCount = 0;
                          for (var element in countSnapshot.data!.entries) {
                            if (element.key.startsWith("feed/")) {
                              allCount += element.value;
                            }
                          }
                          return ListView(
                            children: [
                              ListTile(
                                selected:
                                    Api.of(context).filteredTitle ==
                                    "All Articles",
                                title: const Text("All Articles"),
                                trailing: UnreadCount(allCount),
                                onTap:
                                    () => openArticleList(
                                      context,
                                      null,
                                      null,
                                      "All Articles",
                                    ),
                              ),
                              ListTile(
                                selected:
                                    Api.of(context).filteredTitle == "Starred",
                                title: const Text("Starred"),
                                trailing: UnreadCount(
                                  countSnapshot.data!["Starred"] ?? 0,
                                ),
                                onTap:
                                    () => openArticleList(
                                      context,
                                      "isStarred",
                                      "true",
                                      "Starred",
                                    ),
                              ),
                              if (catSnapshot.hasData &&
                                  catSnapshot.data != null)
                                ...catSnapshot.data!
                                    .where(
                                      (cat) =>
                                          !cat["catID"].toString().endsWith(
                                            "/starred",
                                          ),
                                    )
                                    .map((cat) {
                                      Map<String, Subscription>
                                      currentSubscriptions = {};
                                      subSnapshot.data?.forEach((value) {
                                        if (value["catID"].toString() ==
                                            cat["catID"].toString()) {
                                          currentSubscriptions[value["subID"]
                                                  .toString()] =
                                              Subscription.fromDB(value);
                                        }
                                      });
                                      bool isExpanded = true;
                                      if (isOpen.containsKey(cat["catID"])) {
                                        isExpanded = isOpen[cat["catID"]]!;
                                      } else {
                                        isOpen[cat["catID"].toString()] = true;
                                      }
                                      return Card(
                                        clipBehavior: Clip.hardEdge,
                                        margin: const EdgeInsets.all(8.0),
                                        child: ExpansionTile(
                                          title: Text(
                                            cat["catID"]
                                                .toString()
                                                .split("/")
                                                .last,
                                          ),
                                          shape: const Border(),
                                          initiallyExpanded: isExpanded,
                                          onExpansionChanged: (value) {
                                            setState(() {
                                              isOpen[cat["catID"].toString()] =
                                                  value;
                                            });
                                          },
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          childrenPadding:
                                              const EdgeInsets.only(left: 40.0),
                                          children: [
                                            ListTile(
                                              selected:
                                                  Api.of(
                                                    context,
                                                  ).filteredTitle ==
                                                  cat["catID"]
                                                      .toString()
                                                      .split("/")
                                                      .last,
                                              title: Text(
                                                "All ${cat["catID"].toString().split("/").last}",
                                              ),
                                              trailing: UnreadCount(
                                                countSnapshot
                                                        .data![cat["catID"]] ??
                                                    0,
                                              ),
                                              onTap:
                                                  () => openArticleList(
                                                    context,
                                                    "tag",
                                                    cat["catID"].toString(),
                                                    cat["catID"]
                                                        .toString()
                                                        .split("/")
                                                        .last,
                                                  ),
                                            ),
                                            ...currentSubscriptions.keys
                                                .where(
                                                  (sub) =>
                                                      showAll ||
                                                      (countSnapshot
                                                                  .data![sub] ??
                                                              0) >
                                                          0,
                                                )
                                                .map<Widget>((key) {
                                                  return ListTile(
                                                    selected:
                                                        Api.of(
                                                          context,
                                                        ).filteredTitle ==
                                                        currentSubscriptions[key]!
                                                            .title,
                                                    title: Text(
                                                      currentSubscriptions[key]!
                                                          .title,
                                                    ),
                                                    trailing: UnreadCount(
                                                      countSnapshot
                                                              .data![key] ??
                                                          0,
                                                    ),
                                                    leading: SizedBox(
                                                      height: 28,
                                                      width: 28,
                                                      child: CachedNetworkImage(
                                                        imageUrl: Api.of(
                                                          context,
                                                        ).getIconUrl(
                                                          currentSubscriptions[key]!
                                                              .iconUrl,
                                                        ),
                                                        errorWidget:
                                                            (
                                                              context,
                                                              url,
                                                              error,
                                                            ) => const Icon(
                                                              Icons.error,
                                                            ),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      openArticleList(
                                                        context,
                                                        "subID",
                                                        currentSubscriptions[key]!
                                                            .subID
                                                            .toString(),
                                                        currentSubscriptions[key]!
                                                            .title,
                                                      );
                                                    },
                                                  );
                                                }),
                                          ],
                                        ),
                                      );
                                    }),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
    );
  }
}

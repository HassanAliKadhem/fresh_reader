import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../api/api.dart';
import '../api/data_types.dart';
import '../api/database.dart';
import '../widget/transparent_container.dart';
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
      backgroundColor: Color.alphaBlend(
        Colors.black.withAlpha(46),
        Theme.of(context).scaffoldBackgroundColor,
      ),
      appBar: AppBar(
        title: Text(Api.of(context).account?.username ?? "Feeds"),
        actions: [
          MenuAnchor(
            menuChildren: [
              MenuItemButton(
                onPressed: () {
                  Api.of(context).setShowAll(true);
                },
                trailingIcon: Icon(Icons.circle_outlined),
                child: Text("All Articles"),
              ),
              MenuItemButton(
                onPressed: () {
                  Api.of(context).setShowAll(false);
                },
                trailingIcon: Icon(Icons.circle),
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
                      ? Icons.circle_outlined
                      : Icons.circle,
                ),
              );
            },
          ),
          FutureBuilder(
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
                                  return SettingsPage();
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
                                  // widget.onSelect(null, null, "");
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
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
            onPressed: () {
              if (screenSizeOf(context) == ScreenSize.big) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const SettingsDialog();
                  },
                ).then((_) {
                  setState(() {});
                });
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                ).then((_) {
                  setState(() {});
                });
              }
            },
          ),
        ],
        flexibleSpace: TransparentContainer(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ValueListenableBuilder(
              valueListenable: Api.of(context).progress,
              builder: (context, value, child) {
                return SizedBox(
                  height: 2.0,
                  child:
                      value < 1.0
                          ? LinearProgressIndicator(value: value)
                          : null,
                );
              },
            ),
          ),
        ),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: CategoryList(onSelect: widget.onSelect),
      bottomNavigationBar: TransparentContainer(
        hasBorder: false,
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
        color: Theme.of(context).scaffoldBackgroundColor,
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

  void openArticleList(
    BuildContext context,
    String? column,
    String? value,
    String title,
  ) {
    widget.onSelect(column, value, title);
  }

  @override
  Widget build(BuildContext context) {
    bool showAll = Api.of(context).showAll;
    return RefreshIndicator.adaptive(
      displacement: kToolbarHeight * 2.5,
      onRefresh: () async {
        await Api.of(context)
            .serverSync()
            .then((value) {
              setState(() {});
            })
            .catchError((onError) {
              debugPrint(onError.toString());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(onError.toString(), maxLines: 3)),
              );
            });
      },
      child:
          Api.of(context).account == null || Api.of(context).account?.id == null
              ? Center(child: Text("Please add/select an account"))
              : FutureBuilder(
                future: database.query(
                  "Categories",
                  where: "accountID = ?",
                  whereArgs: [Api.of(context).account!.id],
                ),
                builder: (context, catSnapshot) {
                  return FutureBuilder(
                    future: countAllArticles(
                      showAll,
                      Api.of(context).account!.id,
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
                      List<Map<String, Object?>> categories = [];
                      if (catSnapshot.hasData && catSnapshot.data != null) {
                        categories =
                            catSnapshot.data!
                                .where(
                                  (cat) =>
                                      !cat["catID"].toString().endsWith(
                                        "/starred",
                                      ),
                                )
                                .toList();
                      }
                      return Scrollbar(
                        child: CustomScrollView(
                          primary: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverPadding(
                              padding: EdgeInsetsGeometry.only(
                                top: MediaQuery.paddingOf(context).top,
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildListDelegate([
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
                                      Api.of(context).filteredTitle ==
                                      "Starred",
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
                              ]),
                            ),
                            SliverList.builder(
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                Map<String, Subscription> currentSubscriptions =
                                    {};
                                Api.of(context).subscriptions.values.forEach((
                                  value,
                                ) {
                                  if (value.catID ==
                                      categories[index]["catID"].toString()) {
                                    currentSubscriptions[value.subID
                                            .toString()] =
                                        value;
                                  }
                                });
                                bool isExpanded = true;
                                if (isOpen.containsKey(
                                  categories[index]["catID"],
                                )) {
                                  isExpanded =
                                      isOpen[categories[index]["catID"]]!;
                                } else {
                                  isOpen[categories[index]["catID"]
                                          .toString()] =
                                      true;
                                }
                                return Card(
                                  clipBehavior: Clip.hardEdge,
                                  margin: const EdgeInsets.all(8.0),
                                  child: ExpansionTile(
                                    title: Text(
                                      categories[index]["catID"]
                                          .toString()
                                          .split("/")
                                          .last,
                                    ),
                                    shape: const Border(),
                                    initiallyExpanded: isExpanded,
                                    onExpansionChanged: (value) {
                                      setState(() {
                                        isOpen[categories[index]["catID"]
                                                .toString()] =
                                            value;
                                      });
                                    },
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    // childrenPadding:
                                    //     const EdgeInsets.only(
                                    //       left: 40.0,
                                    //     ),
                                    children: [
                                      ListTile(
                                        selected:
                                            Api.of(context).filteredTitle ==
                                            categories[index]["catID"]
                                                .toString()
                                                .split("/")
                                                .last,
                                        title: Text(
                                          "All ${categories[index]["catID"].toString().split("/").last}",
                                        ),
                                        trailing: UnreadCount(
                                          countSnapshot
                                                  .data![categories[index]["catID"]] ??
                                              0,
                                        ),
                                        onTap:
                                            () => openArticleList(
                                              context,
                                              "tag",
                                              categories[index]["catID"]
                                                  .toString(),
                                              categories[index]["catID"]
                                                  .toString()
                                                  .split("/")
                                                  .last,
                                            ),
                                      ),
                                      ...currentSubscriptions.keys
                                          .where(
                                            (sub) =>
                                                showAll ||
                                                (countSnapshot.data![sub] ??
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
                                                countSnapshot.data![key] ?? 0,
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
                                                      (context, url, error) =>
                                                          const Icon(
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
                              },
                            ),
                            SliverPadding(
                              padding: EdgeInsetsGeometry.only(
                                bottom: MediaQuery.paddingOf(context).bottom,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}

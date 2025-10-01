import 'package:flutter/material.dart';

import '../main.dart';
import '../api/api.dart';
import '../api/data_types.dart';
import '../widget/article_image.dart';
import '../widget/transparent_container.dart';
import 'settings_view.dart';

class FeedList extends StatefulWidget {
  const FeedList({super.key});

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
          hasBorder: false,
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
      body: const CategoryList(),
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
      child: Text(unread.toString(), textScaler: TextScaler.linear(1.15)),
    );
  }
}

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  Map<String, bool> isOpen = {};
  // Map.fromEntries(Api.of(context).tags.map((tag) => MapEntry(tag, true)));

  void openArticleList(
    BuildContext context,
    String? column,
    String? value,
    String title,
  ) {
    Api.of(
      context,
    ).getFilteredArticles(Api.of(context).showAll, column, value, title);
  }

  @override
  Widget build(BuildContext context) {
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
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(onError.toString(), maxLines: 3)),
                );
                Api.of(context).progress.value = 1.0;
              } else {
                debugPrint("Context not mounted");
              }
            });
      },
      child:
          Api.of(context).account == null || Api.of(context).account?.id == null
              ? Center(child: Text("Please add/select an account"))
              : Builder(
                builder: (context) {
                  bool showAll = Api.of(context).showAll;
                  int allCount = 0;
                  for (var element in Api.of(context).counts.entries) {
                    if (element.key.startsWith("feed/")) {
                      allCount += element.value;
                    }
                  }
                  List<Category> categories =
                      Api.of(context).categories.values
                          .where(
                            (cat) =>
                                cat.catID != "user/-/state/com.google/starred",
                          )
                          .toList();
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
                                  Api.of(context).filteredTitle == "Starred",
                              title: const Text("Starred"),
                              trailing: UnreadCount(
                                Api.of(context).counts["Starred"] ?? 0,
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
                            Map<String, Subscription> currentSubscriptions = {};
                            Api.of(context).subscriptions.values.forEach((
                              value,
                            ) {
                              if (value.catID == categories[index].catID) {
                                currentSubscriptions[value.subID] = value;
                              }
                            });
                            bool isExpanded = true;
                            if (isOpen.containsKey(categories[index].catID)) {
                              isExpanded = isOpen[categories[index].catID]!;
                            } else {
                              isOpen[categories[index].catID] = true;
                            }
                            return Card(
                              clipBehavior: Clip.hardEdge,
                              margin: const EdgeInsets.all(8.0),
                              child: ExpansionTile(
                                title: Text(
                                  categories[index].catID.split("/").last,
                                ),
                                shape: const Border(),
                                initiallyExpanded: isExpanded,
                                onExpansionChanged: (value) {
                                  setState(() {
                                    isOpen[categories[index].catID] = value;
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
                                        categories[index].catID.split("/").last,
                                    title: Text(
                                      "All ${categories[index].catID.split("/").last}",
                                    ),
                                    trailing: UnreadCount(
                                      Api.of(context).counts[categories[index]
                                              .catID] ??
                                          0,
                                    ),
                                    onTap:
                                        () => openArticleList(
                                          context,
                                          "tag",
                                          categories[index].catID,
                                          categories[index].catID
                                              .split("/")
                                              .last,
                                        ),
                                  ),
                                  ...currentSubscriptions.keys
                                      .where(
                                        (sub) =>
                                            showAll ||
                                            (Api.of(context).counts[sub] ?? 0) >
                                                0,
                                      )
                                      .map<Widget>((key) {
                                        return ListTile(
                                          // shape: Border(
                                          //   top: BorderSide(
                                          //     color:
                                          //         Theme.of(
                                          //           context,
                                          //         ).scaffoldBackgroundColor,
                                          //     width: 2.0,
                                          //   ),
                                          // ),
                                          selected:
                                              Api.of(context).filteredTitle ==
                                              currentSubscriptions[key]!.title,
                                          title: Text(
                                            currentSubscriptions[key]!.title,
                                          ),
                                          trailing: UnreadCount(
                                            Api.of(context).counts[key] ?? 0,
                                          ),
                                          leading: ArticleImage(
                                            imageUrl: Api.of(
                                              context,
                                            ).getIconUrl(
                                              currentSubscriptions[key]!
                                                  .iconUrl,
                                            ),
                                            height: 28,
                                            width: 28,
                                            onError:
                                                (error) =>
                                                    const Icon(Icons.error),
                                          ),
                                          onTap: () {
                                            openArticleList(
                                              context,
                                              "subID",
                                              currentSubscriptions[key]!.subID
                                                  .toString(),
                                              currentSubscriptions[key]!.title,
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
              ),
    );
  }
}

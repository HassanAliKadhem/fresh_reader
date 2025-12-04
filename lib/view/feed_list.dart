import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api.dart';
import '../api/data_types.dart';
import '../util/date.dart';
import '../util/formatting_setting.dart';
import '../util/screen_size.dart';
import '../widget/account_switcher.dart';
import '../widget/category_card.dart';
import '../widget/show_all_switcher.dart';
import '../widget/transparent_container.dart';
import '../widget/unread_count.dart';
import 'settings_view.dart';

class FeedList extends StatefulWidget {
  const FeedList({super.key});

  @override
  State<FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<FeedList> {
  double? loadingProgress = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.alphaBlend(
        Colors.black.withAlpha(46),
        Theme.of(context).scaffoldBackgroundColor,
      ),
      appBar: AppBar(
        title: Text(context.read<Api>().account?.username ?? "Feeds"),
        actions: [
          ShowAllSwitcherWidget(),
          AccountSwitcherWidget(),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
            onPressed: () {
              if (screenSizeOf(context) == ScreenSize.big) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
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
            child: SizedBox(
              height: 2.0,
              child: (loadingProgress ?? 0.0) < 1.0
                  ? LinearProgressIndicator(value: loadingProgress)
                  : null,
            ),
          ),
        ),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: RefreshIndicator.adaptive(
        displacement: kToolbarHeight * 2.5,
        onRefresh: () async {
          await for (double? progress
              in context.read<Api>().serverSync().handleError((onError) {
                debugPrint(onError.toString());
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(onError.toString(), maxLines: 3)),
                  );
                  setState(() {
                    loadingProgress = 1.0; // reset progress
                  });
                } else {
                  debugPrint("Context not mounted");
                }
              })) {
            setState(() {
              loadingProgress = progress;
            });
          }
        },
        child: const CategoryList(),
      ),
      bottomNavigationBar: TransparentContainer(
        hasBorder: false,
        child: SizedBox(height: MediaQuery.paddingOf(context).bottom),
      ),
    );
  }
}

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  int secondsSinceToday = 0;

  void openArticleList(
    BuildContext context,
    String? column,
    String? value,
    String title,
  ) {
    context.read<Api>().getFilteredArticles(
      context.read<Api>().showAll,
      column,
      value,
      title,
      secondsSinceToday,
    );
  }

  @override
  Widget build(BuildContext context) {
    secondsSinceToday = getTodaySecondsSinceEpoch();
    String? filteredTitle = context.select<Api, String?>(
      (value) => value.filteredTitle,
    );

    bool showLastSync = context.select<Preferences, bool>(
      (a) => a.showLastSync,
    );
    bool showAll = context.select<Api, bool>((a) => a.showAll);
    List<Category> categories = context.select<Api, List<Category>>(
      (a) => a.categories.values
          .where((cat) => cat.catID != "user/-/state/com.google/starred")
          .toList(),
    );
    return context.select<Api, Account?>((a) => a.account) == null
        ? Center(child: Text("Please add/select an account"))
        : Scrollbar(
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
                      selected: filteredTitle == "All Articles",
                      title: const Text("All Articles"),
                      trailing: UnreadCount(
                        context.select<Api, int>(
                          (value) => value.articlesMetaData.values
                              .where((a) => showAll || !a.$3)
                              .length,
                        ),
                      ),
                      onTap: () =>
                          openArticleList(context, null, null, "All Articles"),
                    ),
                    ListTile(
                      selected: filteredTitle == "Today",
                      title: const Text("Today"),
                      trailing: UnreadCount(
                        context.select<Api, int>(
                          (value) => value.articlesMetaData.values
                              .where(
                                (a) =>
                                    a.$1 > secondsSinceToday &&
                                    (showAll || !a.$3),
                              )
                              .length,
                        ),
                      ),
                      onTap: () => openArticleList(
                        context,
                        "timeStampPublished",
                        null,
                        "Today",
                      ),
                    ),
                    if (showLastSync)
                      ListTile(
                        selected: filteredTitle == "lastSync",
                        title: const Text("last Sync Articles"),
                        trailing: UnreadCount(
                          showAll
                              ? (context.select<Api, int>(
                                  (a) => a.lastSyncIDs.length,
                                ))
                              : context.select<Api, int>(
                                  (value) => value.articlesMetaData.entries
                                      .where(
                                        (a) =>
                                            value.lastSyncIDs.contains(a.key) &&
                                            !a.value.$3,
                                      )
                                      .length,
                                ),
                        ),
                        onTap: () =>
                            openArticleList(context, null, null, "lastSync"),
                      ),
                    ListTile(
                      selected: filteredTitle == "Starred",
                      title: const Text("Starred"),
                      trailing: UnreadCount(
                        context.select<Api, int>(
                          (value) => value.articlesMetaData.values
                              .where((a) => a.$4 && (showAll || !a.$3))
                              .length,
                        ),
                      ),
                      onTap: () => openArticleList(
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
                    for (var value
                        in context.read<Api>().subscriptions.values) {
                      if (value.catID == categories[index].catID) {
                        currentSubscriptions[value.subID] = value;
                      }
                    }
                    return CategoryCard(
                      categoryName: categories[index].catID.split("/").last,
                      selected: filteredTitle ?? "",
                      openAll: () {
                        openArticleList(
                          context,
                          "tag",
                          categories[index].catID,
                          categories[index].catID.split("/").last,
                        );
                      },
                      openFeed: (key) {
                        openArticleList(
                          context,
                          "subID",
                          currentSubscriptions[key]!.subID.toString(),
                          currentSubscriptions[key]!.title,
                        );
                      },
                      currentSubscriptions: currentSubscriptions,
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
  }
}

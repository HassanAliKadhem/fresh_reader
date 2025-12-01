import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api.dart';
import '../api/data_types.dart';
import '../util/date.dart';
import '../util/formatting_setting.dart';
import '../util/screen_size.dart';
import '../widget/account_switcher.dart';
import '../widget/article_image.dart';
import '../widget/show_all_switcher.dart';
import '../widget/transparent_container.dart';
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
  int secondsSinceToday = 0;
  // Map.fromEntries(Api.of(context).tags.map((tag) => MapEntry(tag, true)));

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
    Map<String, (int, String, bool, bool)> metaData = context
        .select<Api, Map<String, (int, String, bool, bool)>>(
          (value) => value.articlesMetaData,
        );

    bool showLastSync = context.select<Preferences, bool>(
      (a) => a.showLastSync,
    );
    return context.select<Api, Account?>((a) => a.account) == null ||
            context.select<Api, Account?>((a) => a.account)?.id == null
        ? Center(child: Text("Please add/select an account"))
        : Builder(
            builder: (context) {
              bool showAll = context.select<Api, bool>((a) => a.showAll);
              List<Category> categories = context
                  .select<Api, Map<String, Category>>((a) => a.categories)
                  .values
                  .where(
                    (cat) => cat.catID != "user/-/state/com.google/starred",
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
                          selected: filteredTitle == "All Articles",
                          title: const Text("All Articles"),
                          trailing: UnreadCount(
                            metaData.values
                                .where((a) => showAll || !a.$3)
                                .length,
                          ),
                          onTap: () => openArticleList(
                            context,
                            null,
                            null,
                            "All Articles",
                          ),
                        ),
                        ListTile(
                          selected: filteredTitle == "Today",
                          title: const Text("Today"),
                          trailing: UnreadCount(
                            metaData.values
                                .where(
                                  (a) =>
                                      a.$1 > secondsSinceToday &&
                                      (showAll || !a.$3),
                                )
                                .length,
                          ),
                          onTap: () => openArticleList(
                            context,
                            "timeStampPublished",
                            null,
                            "Today",
                          ),
                        ),
                        if (showLastSync)
                          FutureBuilder(
                            future: context.read<Api>().database.getLastSyncIDs(
                              context.read<Api>().account!.id,
                            ),
                            builder: (context, snapshot) {
                              int count = showAll
                                  ? (snapshot.data?.length ?? 0)
                                  : snapshot.data
                                            ?.where(
                                              (id) =>
                                                  !(metaData[id]?.$3 ?? true),
                                            )
                                            .length ??
                                        0;
                              return ListTile(
                                selected: filteredTitle == "lastSync",
                                title: const Text("last Sync Articles"),
                                trailing: UnreadCount(count),
                                onTap: () => openArticleList(
                                  context,
                                  null,
                                  null,
                                  "lastSync",
                                ),
                              );
                            },
                          ),
                        ListTile(
                          selected: filteredTitle == "Starred",
                          title: const Text("Starred"),
                          trailing: UnreadCount(
                            metaData.values
                                .where((a) => a.$4 && (showAll || !a.$3))
                                .length,
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
                        context.read<Api>().subscriptions.values.forEach((
                          value,
                        ) {
                          if (value.catID == categories[index].catID) {
                            currentSubscriptions[value.subID] = value;
                          }
                        });
                        return Card(
                          clipBehavior: Clip.hardEdge,
                          margin: const EdgeInsets.all(8.0),
                          child: ExpansionTile(
                            title: Text(
                              categories[index].catID.split("/").last,
                            ),
                            key: PageStorageKey(
                              'categoryTile_${categories[index].catID.split("/")}',
                            ),
                            shape: const Border(),
                            initiallyExpanded: true,
                            controlAffinity: ListTileControlAffinity.leading,
                            // childrenPadding:
                            //     const EdgeInsets.only(
                            //       left: 40.0,
                            //     ),
                            children: [
                              ListTile(
                                selected:
                                    filteredTitle ==
                                    categories[index].catID.split("/").last,
                                title: Text(
                                  "All ${categories[index].catID.split("/").last}",
                                ),
                                trailing: UnreadCount(
                                  metaData.values
                                      .where(
                                        (a) =>
                                            currentSubscriptions.keys.contains(
                                              a.$2,
                                            ) &&
                                            (showAll || !a.$3),
                                      )
                                      .length,
                                ),
                                onTap: () => openArticleList(
                                  context,
                                  "tag",
                                  categories[index].catID,
                                  categories[index].catID.split("/").last,
                                ),
                              ),
                              ...currentSubscriptions.keys
                                  .where(
                                    (sub) =>
                                        showAll ||
                                        metaData.values
                                            .where(
                                              (a) =>
                                                  a.$2 == sub &&
                                                  (showAll || !a.$3),
                                            )
                                            .isNotEmpty,
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
                                          filteredTitle ==
                                          currentSubscriptions[key]!.title,
                                      title: Text(
                                        currentSubscriptions[key]!.title,
                                      ),
                                      trailing: UnreadCount(
                                        metaData.values
                                            .where(
                                              (a) =>
                                                  a.$2 == key &&
                                                  (showAll || !a.$3),
                                            )
                                            .length,
                                      ),
                                      leading: ArticleImage(
                                        imageUrl: context
                                            .read<Api>()
                                            .getIconUrl(
                                              currentSubscriptions[key]!
                                                  .iconUrl,
                                            ),
                                        height: 28,
                                        width: 28,
                                        onError: (error) =>
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
          );
  }
}

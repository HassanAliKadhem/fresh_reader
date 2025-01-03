import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/main.dart';
import '/widget/blur_bar.dart';
import '../api/database.dart';

import '../api/filter.dart';
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
      appBar: AppBar(
        title: Text(Filter.of(context).api == null
            ? "<- choose account"
            : "${Filter.of(context).api?.account.provider}: ${Filter.of(context).api?.account.userName}"),
        leading: StreamBuilder<List<AccountData>>(
            stream: database.select(database.account).watch(),
            builder: (context, accountSnapshot) {
              if (!accountSnapshot.hasData) {
                return CircularProgressIndicator.adaptive();
              }
              return MenuAnchor(
                menuChildren: accountSnapshot.data!.isEmpty
                    ? [
                        MenuItemButton(
                          onPressed: () {
                            var onSelectAccount =
                                Filter.of(context).onSelectAccount;
                            showDialog(
                              context: context,
                              builder: (context) {
                                return SettingsView(
                                  currentAccount: null,
                                  chooseAccount: onSelectAccount,
                                );
                              },
                            );
                          },
                          trailingIcon: Icon(Icons.add),
                          child: Text("Click here to add account"),
                        ),
                      ]
                    : accountSnapshot.data!
                        .map((acc) => MenuItemButton(
                              onPressed: () {
                                Filter.of(context).onSelectAccount(acc);
                              },
                              leadingIcon:
                                  Filter.of(context).api?.account.id == acc.id
                                      ? Icon(Icons.check)
                                      : null,
                              child: Text("${acc.provider}: ${acc.userName}"),
                            ))
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
            }),
        actions: [
          MenuAnchor(
            menuChildren: [
              MenuItemButton(
                onPressed: () {
                  setState(() {
                    Filter.of(context).changeShowAll(true);
                  });
                },
                child: Text("All"),
              ),
              MenuItemButton(
                onPressed: () {
                  setState(() {
                    Filter.of(context).changeShowAll(false);
                  });
                },
                child: Text("Unread"),
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
                tooltip: "Filter Read articles",
                icon: Icon(Filter.of(context).showAll
                    ? Icons.filter_alt_off
                    : Icons.filter_alt),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
            onPressed: () {
              int? accountId = Filter.of(context).api?.account.id;
              var onSelectAccount = Filter.of(context).onSelectAccount;
              showDialog(
                context: context,
                builder: (context) {
                  return SettingsView(
                    currentAccount: accountId,
                    chooseAccount: onSelectAccount,
                  );
                },
              );
            },
          ),
        ],
        flexibleSpace: const BlurBar(),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: CategoryList(key: ValueKey(Filter.of(context).showAll)),
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
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  late Map<int, bool> isOpen = {};

  void openArticleList(
      BuildContext context, ArticleListType? type, int? value) {
    Filter.of(context).onSelectFeed(type, value);
  }

  dynamic networkError;

  @override
  Widget build(BuildContext context) {
    if (Filter.of(context).api == null) {
      return Center(
        child: Text("Please choose an account"),
      );
    }
    return RefreshIndicator.adaptive(
      displacement: kToolbarHeight * 2,
      onRefresh: () async {
        await Filter.of(context).api!.serverSync().then((value) {
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
          : StreamBuilder<List<CategoryData>>(
              stream: (database.select(database.category)
                    ..where(
                      (tbl) => tbl.account
                          .equals(Filter.of(context).api!.account.id),
                    ))
                  .watch(),
              builder: (context, categorySnapshot) {
                return StreamBuilder<List<SubscriptionData>>(
                    stream: (database.select(database.subscription)
                          ..where(
                            (tbl) => tbl.account
                                .equals(Filter.of(context).api!.account.id),
                          ))
                        .watch(),
                    builder: (context, subscriptionSnapshot) {
                      return StreamBuilder(
                          stream: (database.selectOnly(database.article)
                                ..addColumns([
                                  database.article.subscription,
                                  database.article.starred,
                                  database.article.account,
                                  database.article.read,
                                ])
                                ..where(database.article.account
                                    .equals(Filter.of(context).api!.account.id))
                                ..where(database.article.read.isIn(
                                    Filter.of(context).showAll
                                        ? [true, false]
                                        : [false])))
                              .map((res) => (
                                    res.read(database.article.subscription),
                                    res.read(database.article.starred)
                                  ))
                              .watch(),
                          builder: (context, articleSnapshot) {
                            List<(int?, bool?)> subCounts =
                                articleSnapshot.data ?? [];
                            return ListView(
                              children: [
                                ListTile(
                                  selected: Filter.of(context).filterType ==
                                      ArticleListType.all,
                                  title: const Text("All Articles"),
                                  trailing: UnreadCount(subCounts.length),
                                  onTap: () => openArticleList(
                                      context, ArticleListType.all, null),
                                ),
                                ListTile(
                                  selected: Filter.of(context).filterType ==
                                      ArticleListType.starred,
                                  title: const Text("Starred"),
                                  trailing: UnreadCount(subCounts
                                      .where((art) => art.$2 ?? false)
                                      .length),
                                  onTap: () => openArticleList(
                                      context, ArticleListType.starred, null),
                                ),
                                if (categorySnapshot.hasData)
                                  ...categorySnapshot.data!
                                      .where((tag) =>
                                          tag.serverID !=
                                          "user/-/state/com.google/starred")
                                      .map(
                                    (category) {
                                      return categoryWidget(
                                          category,
                                          subscriptionSnapshot.data ?? [],
                                          subCounts);
                                    },
                                  ),
                              ],
                            );
                          });
                    });
              }),
    );
  }

  Widget categoryWidget(CategoryData category,
      List<SubscriptionData> subscriptions, List<(int?, bool?)> subCounts) {
    Iterable<SubscriptionData> currentSubscriptions =
        subscriptions.where((sub) => sub.category == category.id);
    bool isExpanded = true;
    if (isOpen.containsKey(category.id)) {
      isExpanded = isOpen[category.id]!;
    } else {
      isOpen[category.id] = true;
    }
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(category.serverID.split("/").last),
        shape: const Border(),
        initiallyExpanded: isExpanded,
        onExpansionChanged: (value) {
          setState(() {
            isOpen[category.id] = value;
          });
        },
        controlAffinity: ListTileControlAffinity.leading,
        childrenPadding: const EdgeInsets.only(left: 40.0),
        children: [
          ListTile(
            selected:
                Filter.of(context).filterType == ArticleListType.category &&
                    Filter.of(context).filterValue == category.id,
            title: Text("All ${category.title}"),
            trailing: UnreadCount(subCounts
                .where((art) => currentSubscriptions
                    .where((sub) => sub.id == art.$1)
                    .isNotEmpty)
                .length),
            onTap: () =>
                openArticleList(context, ArticleListType.category, category.id),
          ),
          ...currentSubscriptions
              .where((sub) =>
                  Filter.of(context).showAll ||
                  subCounts.where((art) => art.$1 == sub.id).isNotEmpty)
              .map<Widget>(
            (subscription) {
              return ListTile(
                selected: Filter.of(context).filterType ==
                        ArticleListType.subscription &&
                    Filter.of(context).filterValue == subscription.id,
                title: Text(subscription.title),
                trailing: UnreadCount(
                    subCounts.where((art) => art.$1 == subscription.id).length),
                leading: SizedBox(
                  height: 28,
                  width: 28,
                  child: CachedNetworkImage(
                    imageUrl: subscription.iconUrl,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                onTap: () {
                  openArticleList(
                      context, ArticleListType.subscription, subscription.id);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

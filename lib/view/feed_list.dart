import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:provider/provider.dart';

import '../api/data.dart';
import '../api/data_types.dart';
import '../util/date.dart';
import '../api/preferences.dart';
import '../util/show_error.dart';
import '../widget/account_switcher.dart';
import '../widget/category_card.dart';
import '../widget/show_all_switcher.dart';
import '../widget/transparent_container.dart';
import '../widget/unread_count.dart';

class FeedList extends StatefulWidget {
  const FeedList({super.key});

  @override
  State<FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<FeedList> {
  double? loadingProgress = 1.0;
  bool isSearching = false;
  String? searchTerms;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.alphaBlend(
        Colors.black.withAlpha(
          Theme.brightnessOf(context) == Brightness.dark ? 46 : 16,
        ),
        Theme.of(context).scaffoldBackgroundColor,
      ),
      appBar: AppBar(
        title: isSearching
            ? SearchBar(
                key: const ValueKey("searchFeeds"),
                hintText: "Search Feeds",
                textInputAction: TextInputAction.search,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(Icons.search),
                ),
                autoFocus: true,
                constraints: const BoxConstraints(minHeight: 42.0),
                elevation: const WidgetStatePropertyAll(0.0),
                trailing: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        searchTerms = null;
                        isSearching = false;
                      });
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    searchTerms = value;
                  });
                },
              )
            : Text(
                context.select<DataProvider, String>(
                  (d) => d.api?.account.username ?? "Feeds",
                ),
              ),
        actions: isSearching
            ? []
            : [
                IconButton(
                  onPressed: () {
                    setState(() {
                      isSearching = true;
                    });
                  },
                  icon: Icon(Icons.search),
                ),
                ShowAllSwitcherWidget(),
                AccountSwitcherWidget(),
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: "Settings",
                  onPressed: () {
                    context.read<DataProvider>().settingsPage = "settings";
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
                  ? LinearProgressIndicatorM3E(value: loadingProgress, size: .s)
                  : null,
            ),
          ),
        ),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: ExpressiveRefreshIndicator(
        displacement: kToolbarHeight * 2.5,
        onRefresh: () async {
          await for (double? progress
              in context.read<DataProvider>().serverSync().handleError((
                onError,
              ) {
                debugPrint(onError.toString());
                if (context.mounted) {
                  showError(context, onError.toString());
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
        child: CategoryList(searchTerms: searchTerms),
      ),
      bottomNavigationBar: TransparentContainer(
        hasBorder: false,
        child: SizedBox(height: MediaQuery.paddingOf(context).bottom),
      ),
    );
  }
}

class CategoryList extends StatefulWidget {
  const CategoryList({super.key, this.searchTerms});
  final String? searchTerms;

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
    context.read<DataProvider>().getFilteredArticles(
      context.read<DataProvider>().showAll,
      context.read<Preferences>().sorting,
      column,
      value,
      title,
      secondsSinceToday,
    );
  }

  @override
  Widget build(BuildContext context) {
    secondsSinceToday = getTodaySecondsSinceEpoch();
    String? search = widget.searchTerms?.toLowerCase();
    String? filteredTitle = context.select<DataProvider, String?>(
      (value) => value.filteredTitle,
    );

    bool showLastSync = context.select<Preferences, bool>(
      (a) => a.showLastSync,
    );
    bool showAll = context.select<DataProvider, bool>((a) => a.showAll);
    List<Category> categories = context.select<DataProvider, List<Category>>(
      (a) => a.categories.values
          .where((cat) => cat.catID != "user/-/state/com.google/starred")
          .toList(),
    );
    return context.select<DataProvider, int?>((a) => a.accountID) == null
        ? Center(child: Text("Please add/select an account"))
        : CustomScrollView(
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
                    trailing: UnreadCounter((a) => showAll || !a.$3),
                    onTap: () =>
                        openArticleList(context, null, null, "All Articles"),
                  ),
                  ListTile(
                    selected: filteredTitle == "Today",
                    title: const Text("Today"),
                    trailing: UnreadCounter(
                      (a) => a.$1 > secondsSinceToday && (showAll || !a.$3),
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
                      trailing: const UnreadLastSync(),
                      onTap: () =>
                          openArticleList(context, null, null, "lastSync"),
                    ),
                  ListTile(
                    selected: filteredTitle == "Starred",
                    title: const Text("Starred"),
                    trailing: UnreadCounter((a) => a.$4 && (showAll || !a.$3)),
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
                      in context.read<DataProvider>().subscriptions.values) {
                    if (value.catID == categories[index].catID &&
                        (search == null ||
                            value.title.toLowerCase().contains(search) ||
                            value.htmlUrl.toLowerCase().contains(search))) {
                      currentSubscriptions[value.subID] = value;
                    }
                  }
                  if (widget.searchTerms != null &&
                      currentSubscriptions.isEmpty) {
                    return SizedBox();
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
          );
  }
}

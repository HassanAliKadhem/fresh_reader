import 'package:cached_network_image/cached_network_image.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:fresh_reader/main.dart';
import 'package:fresh_reader/widget/blur_bar.dart';

import '../api/database.dart';
import '../api/filter.dart';
import '../util/date_helper.dart';

class ArticleList extends StatefulWidget {
  const ArticleList({
    super.key,
    required this.filterType,
    required this.filterValue,
    required this.showAll,
  });
  final ArticleListType? filterType;
  final int? filterValue;
  final bool showAll;
  @override
  State<ArticleList> createState() => _ArticleListState();
}

List<(ArticleData, SubscriptionData)> currentArticles = [];
int currentIndex = -1;

class _ArticleListState extends State<ArticleList> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late Future<List<int>> articleIds =
      getIds(widget.filterType!, widget.filterValue, widget.showAll);

  @override
  void didUpdateWidget(ArticleList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.key != widget.key) {
      setState(() {
        articleIds =
            getIds(widget.filterType!, widget.filterValue, widget.showAll);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    articleIndex.addListener(() => scrollToCurrent());
  }

  @override
  void dispose() {
    super.dispose();
    articleIndex.removeListener(() => scrollToCurrent());
  }

  void scrollToCurrent() {
    if (articleIndex.value != null && _scrollController.hasClients) {
      currentIndex = articleIndex.value!;
      double scrollTarget = (currentIndex * 128);
      _scrollController.animateTo(
        curve: Curves.linear,
        duration: const Duration(milliseconds: 300),
        scrollTarget,
      );
    }
  }

  Future<String?> getTitle(ArticleListType filterType, int? filterValue) async {
    if (filterType == ArticleListType.all) {
      return Future(() => "All Articles");
    } else if (filterType == ArticleListType.starred) {
      return Future(() => "Starred");
    } else if (filterType == ArticleListType.subscription) {
      return (database.selectOnly(database.subscription)
            ..addColumns([
              database.subscription.title,
              database.subscription.account,
              database.subscription.id
            ])
            ..where(database.subscription.account
                .equals(Filter.of(context).api!.account.id))
            ..where(database.subscription.id.equals(filterValue!)))
          .map((res) => res.read(database.subscription.title))
          .getSingle();
    } else {
      return (database.selectOnly(database.category)
            ..addColumns([
              database.category.title,
              database.category.account,
              database.category.id
            ])
            ..where(database.category.account
                .equals(Filter.of(context).api!.account.id))
            ..where(database.category.id.equals(filterValue!)))
          .map((res) => res.read(database.category.title))
          .getSingle();
    }
  }

  Future<List<int>> getIds(
      ArticleListType filterType, int? filterValue, bool showAll) async {
    List<int> catSubIds = [];
    if (filterType == ArticleListType.category && filterValue != null) {
      catSubIds = await (database.selectOnly(database.subscription)
            ..addColumns([
              database.subscription.id,
              database.subscription.category,
            ])
            ..where(database.subscription.category.equals(filterValue)))
          .map(
            (p0) => p0.read(database.subscription.id)!,
          )
          .get();
    }
    return (database.selectOnly(database.article)
          ..addColumns([
            database.article.id,
            database.article.account,
            database.article.read,
            database.article.starred,
            database.article.subscription,
          ])
          ..where(database.article.account
              .equals(Filter.of(context).api?.account.id ?? -1))
          ..where(database.article.read.isIn(showAll ? [true, false] : [false]))
          ..where(switch (filterType) {
            ArticleListType.all => database.article.id.isNotNull(),
            ArticleListType.starred => database.article.starred.equals(true),
            ArticleListType.category =>
              database.article.subscription.isIn(catSubIds),
            ArticleListType.subscription => database.article.subscription
                .equals(Filter.of(context).filterValue!),
          }))
        .map(
          (p0) => p0.read(database.article.id) ?? -1,
        )
        .get();
  }

  @override
  Widget build(BuildContext context) {
    if (Filter.of(context).filterType == null ||
        Filter.of(context).api == null) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: const BlurBar(),
        title: FutureBuilder(
          future: getTitle(
              Filter.of(context).filterType!, Filter.of(context).filterValue),
          builder: (context, snapshot) =>
              Text(snapshot.hasData ? snapshot.data ?? "" : ""),
        ),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: BlurBar(
        child: SizedBox(
          height: MediaQuery.paddingOf(context).bottom,
        ),
      ),
      body: FutureBuilder(
          future: articleIds,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            return StreamBuilder(
                stream: (database.select(database.article)
                      ..where((art) => art.id.isIn(snapshot.data!)))
                    .join([
                      drift.leftOuterJoin(
                          database.subscription,
                          database.subscription.id
                              .equalsExp(database.article.subscription))
                    ])
                    .map((e) => (
                          e.readTable(database.article),
                          e.readTable(database.subscription)
                        ))
                    .watch(),
                builder: (context, snapshot) {
                  currentArticles = snapshot.hasData
                      ? snapshot.data!
                          .where((article) => article.$1.title
                              .toLowerCase()
                              .contains(
                                  _searchController.value.text.toLowerCase()))
                          .toList()
                      : [];
                  return ListView.builder(
                    key: const PageStorageKey(0),
                    itemCount: currentArticles.length + 1,
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return SizedBox(
                          height: 64,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SearchBar(
                              hintText: "Search",
                              controller: _searchController,
                              backgroundColor:
                                  const WidgetStatePropertyAll(Colors.black26),
                              trailing: [
                                _searchController.text != ""
                                    ? IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _searchController.text = "";
                                          });
                                        },
                                        icon: const Icon(Icons.clear),
                                      )
                                    : const Padding(
                                        padding: EdgeInsets.only(right: 10.0),
                                        child: Icon(Icons.search),
                                      ),
                              ],
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                        );
                      }
                      return ArticleTile(currentArticles[index - 1].$1,
                          currentArticles[index - 1].$2, index - 1);
                    },
                  );
                });
          }),
    );
  }
}

class ArticleTile extends StatefulWidget {
  const ArticleTile(this.article, this.subscription, this.index, {super.key});
  final int index;
  final ArticleData article;
  final SubscriptionData subscription;

  @override
  State<ArticleTile> createState() => _ArticleTileState();
}

class _ArticleTileState extends State<ArticleTile> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
        key: ValueKey(widget.article.id),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            Filter.of(context).api?.setRead(widget.article,
                widget.subscription.serverID, !widget.article.read);
          } else {
            Filter.of(context).api?.setStarred(widget.article,
                widget.subscription.serverID, !widget.article.starred);
          }
          setState(() {});
          return false;
        },
        background: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    !widget.article.starred ? Icons.star_border : Icons.star,
                  ),
                  Text(
                    widget.article.starred ? "UnFavorite" : "Favorite",
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    widget.article.read ? "Set Unread" : "Set Read",
                    textAlign: TextAlign.end,
                  ),
                  Icon(
                    widget.article.read
                        ? Icons.circle_outlined
                        : Icons.circle_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
        child: ArticleWidget(
            article: widget.article,
            subscription: widget.subscription,
            onSelect: () {
              currentIndex = widget.index;
              articleIndex.value = widget.index;
            }));
  }
}

class ArticleWidget extends StatelessWidget {
  const ArticleWidget(
      {super.key,
      required this.article,
      required this.subscription,
      required this.onSelect});
  final ArticleData article;
  final SubscriptionData subscription;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Container(
        color: articleIndex.value != null &&
                currentArticles[articleIndex.value!].$1.id == article.id
            ? Theme.of(context).listTileTheme.selectedTileColor
            : null,
        height: 128,
        child: Opacity(
          opacity: (article.read) ? 0.5 : 1,
          child: InkWell(
            onTap: onSelect,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (article.image != null)
                  Container(
                    clipBehavior: Clip.hardEdge,
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey.shade800,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: article.image!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: 0.75,
                        child: RichText(
                          maxLines: 1,
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                  child: SizedBox(
                                height: 16,
                                width: 16,
                                child: CachedNetworkImage(
                                  imageUrl: subscription.iconUrl,
                                  fit: BoxFit.contain,
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error, size: 16),
                                ),
                              )),
                              TextSpan(
                                text: "  ${subscription.title}",
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        article.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8.0),
                      Opacity(
                        opacity: 0.75,
                        child: Text(
                          "${getRelativeDate(article.published)} ${article.read ? "✔️" : ""} ${article.starred ? "★" : ""}",
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

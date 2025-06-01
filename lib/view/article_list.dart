import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../api/api.dart';
import '../api/data_types.dart';
import '../widget/blur_bar.dart';
import 'article_view.dart';

class ArticleList extends StatefulWidget {
  const ArticleList({super.key});

  @override
  State<ArticleList> createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int currentIndex = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Api.of(context).selectedIndex != null &&
        _scrollController.hasClients &&
        Api.of(context).selectedIndex != currentIndex) {
      currentIndex = Api.of(context).selectedIndex!;
      double scrollTarget = (Api.of(context).selectedIndex! * 128);
      _scrollController.animateTo(
        curve: Curves.linear,
        duration: const Duration(milliseconds: 300),
        scrollTarget,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: const BlurBar(),
        title: Text(
          Api.of(context).filteredTitle == null
              ? ""
              : Api.of(context).filteredTitle!.split("/").last,
        ),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: BlurBar(
        child: SizedBox(height: MediaQuery.paddingOf(context).bottom),
      ),
      body:
          Api.of(context).filteredArticles == null
              ? const SizedBox()
              : Builder(
                builder: (context) {
                  Api.of(context).searchResults =
                      Api.of(context).filteredArticles?.entries
                          .where(
                            (entry) => entry.value.title.toLowerCase().contains(
                              _searchController.value.text.toLowerCase(),
                            ),
                          )
                          .map((toElement) => toElement.key)
                          .toList();
                  return ListView.builder(
                    key: const PageStorageKey(0),
                    itemCount: (Api.of(context).searchResults?.length ?? 0) + 1,
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
                              backgroundColor: const WidgetStatePropertyAll(
                                Colors.black26,
                              ),
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
                      Article article =
                          Api.of(context).filteredArticles![Api.of(
                            context,
                          ).searchResults![index - 1]]!;
                      return ArticleTile(
                        article,
                        index - 1,
                        Api.of(context).subscriptions[article.subID]?.iconUrl ??
                            "",
                        Api.of(context).subscriptions[article.subID]?.title ??
                            "",
                      );
                    },
                  );
                },
              ),
    );
  }
}

class ArticleTile extends StatefulWidget {
  const ArticleTile(
    this.article,
    this.index,
    this.subIcon,
    this.subTitle, {
    super.key,
  });
  final int index;
  final Article article;
  final String subIcon;
  final String subTitle;

  @override
  State<ArticleTile> createState() => _ArticleTileState();
}

class _ArticleTileState extends State<ArticleTile> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.article.articleID),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          Api.of(context).setRead(
            widget.article.articleID,
            widget.article.subID,
            !widget.article.read,
          );
        } else {
          Api.of(context).setStarred(
            widget.article.articleID,
            widget.article.subID,
            !widget.article.starred,
          );
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
                Icon(!widget.article.starred ? Icons.star_border : Icons.star),
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
        subIcon: widget.subIcon,
        subTitle: widget.subTitle,
        onSelect: () {
          Api.of(context).selectedIndex = widget.index;
          if (Api.of(context).filteredArticles != null &&
              Api.of(context).filteredArticles![widget.article.articleID] !=
                  null) {
            currentArticleNotifier.value = Api.of(context).setRead(
              widget.article.articleID,
              Api.of(
                context,
              ).filteredArticles![widget.article.articleID]!.subID,
              true,
            );
          }
        },
      ),
    );
  }
}

class ArticleWidget extends StatelessWidget {
  const ArticleWidget({
    super.key,
    required this.article,
    required this.subIcon,
    required this.subTitle,
    required this.onSelect,
  });
  final Article article;
  final String subIcon;
  final String subTitle;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color:
              Api.of(context).filteredArticleIDs != null &&
                      Api.of(context).selectedIndex != null &&
                      Api.of(context).filteredArticleIDs!.elementAt(
                            Api.of(context).selectedIndex!,
                          ) ==
                          article.articleID
                  ? Theme.of(context).listTileTheme.selectedTileColor
                  : null,
          borderRadius: BorderRadius.circular(10),
        ),
        height: 128,
        child: Opacity(
          opacity: (article.read) ? 0.4 : 1,
          child: InkWell(
            onTap: onSelect,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (article.image != null)
                  Container(
                    margin: EdgeInsets.only(left: 12.0),
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
                      errorWidget:
                          (context, url, error) => const Icon(Icons.error),
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
                                    imageUrl: Api.of(
                                      context,
                                    ).getIconUrl(subIcon),
                                    fit: BoxFit.contain,
                                    errorWidget:
                                        (context, url, error) =>
                                            const Icon(Icons.error, size: 16),
                                  ),
                                ),
                              ),
                              TextSpan(text: "  $subTitle"),
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

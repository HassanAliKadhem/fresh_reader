import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api/api.dart';
import '../api/data_types.dart';
import '../main.dart';
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
  int currentIndex = -1; // used to save last scroll position

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Api.of(context).selectedIndex != null &&
        _scrollController.hasClients &&
        Api.of(context).selectedIndex != currentIndex) {
      currentIndex = Api.of(context).selectedIndex!;
      double scrollTarget = (Api.of(context).selectedIndex! * 128);
      _scrollController.animateTo(
        min(scrollTarget, _scrollController.position.maxScrollExtent),
        curve: Curves.linear,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(220),
      appBar: AppBar(
        flexibleSpace: const BlurBar(),
        title: Text(
          Api.of(context).filteredTitle == null
              ? ""
              : Api.of(context).filteredTitle!.split("/").last,
        ),
        leading:
            screenSizeOf(context) == ScreenSize.big
                ? IconButton(
                  onPressed: () {
                    isExpanded.value = !isExpanded.value;
                  },
                  icon: Icon(CupertinoIcons.fullscreen),
                )
                : null,
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: BlurBar(
        hasBorder: false,
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
                  return Scrollbar(
                    controller: _scrollController,
                    child: ListView.builder(
                      key: const PageStorageKey(0),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount:
                          (Api.of(context).searchResults?.length ?? 0) + 1,
                      controller: _scrollController,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 12.0,
                            ),
                            child:
                                (Platform.isIOS || Platform.isMacOS)
                                    ? CupertinoSearchTextField(
                                      controller: _searchController,
                                      onChanged: (value) => setState(() {}),
                                      padding: const EdgeInsets.all(12.0),
                                    )
                                    : SearchBar(
                                      hintText: "Search",
                                      controller: _searchController,
                                      textInputAction: TextInputAction.search,
                                      leading: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.search),
                                      ),
                                      padding: WidgetStatePropertyAll(
                                        const EdgeInsets.all(8.0),
                                      ),
                                      trailing:
                                          _searchController.text != ""
                                              ? [
                                                IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _searchController.clear();
                                                    });
                                                  },
                                                  icon: const Icon(Icons.clear),
                                                ),
                                              ]
                                              : null,
                                      onChanged: (value) {
                                        setState(() {});
                                      },
                                    ),
                          );
                        }
                        return ArticleTile(
                          article:
                              Api.of(context).filteredArticles![Api.of(
                                context,
                              ).searchResults![index - 1]]!,
                          index: index - 1,
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}

class ArticleTile extends StatefulWidget {
  const ArticleTile({required this.article, required this.index, super.key});
  final int index;
  final Article article;

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
                Text(widget.article.starred ? "  UnFavorite" : "  Favorite"),
              ],
            ),
            Row(
              children: [
                Text(widget.article.read ? "Set Unread  " : "Set Read  "),
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
        subIcon:
            Api.of(context).subscriptions[widget.article.subID]?.iconUrl ?? "",
        subTitle:
            Api.of(context).subscriptions[widget.article.subID]?.title ?? "",
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
    return Container(
      height: 128,
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
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Opacity(
        opacity: (article.read) ? 0.3 : 1.0,
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 8.0),
              if (article.image != null)
                Container(
                  clipBehavior: Clip.hardEdge,
                  width: 100.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.grey.shade800,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: article.image!,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder:
                        (context, url, progress) =>
                            CircularProgressIndicator.adaptive(
                              constraints: BoxConstraints(
                                maxWidth: 16.0,
                                maxHeight: 16.0,
                              ),
                              value: progress.progress,
                            ),
                    errorWidget:
                        (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    RichText(
                      maxLines: 2,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          height: 1.2,
                        ),
                        children: [
                          WidgetSpan(
                            child: SizedBox(
                              height: 16,
                              width: 16,
                              child: CachedNetworkImage(
                                imageUrl: Api.of(context).getIconUrl(subIcon),
                                fit: BoxFit.contain,
                                errorWidget:
                                    (context, url, error) =>
                                        const Icon(Icons.error, size: 16),
                              ),
                            ),
                          ),
                          TextSpan(
                            text:
                                " $subTitle\n${article.read ? "" : "⚪️"}${article.starred ? "⭐️" : ""}${getRelativeDate(article.published)}",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
            ],
          ),
        ),
      ),
    );
  }
}

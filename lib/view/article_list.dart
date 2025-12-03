import 'dart:io';
import 'dart:math';

import 'package:anchor_scroll_controller/anchor_scroll_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fresh_reader/util/date.dart';
import 'package:fresh_reader/widget/article_image.dart';
import 'package:provider/provider.dart';

import '../api/api.dart';
import '../api/data_types.dart';
import '../main.dart';
import '../util/formatting_setting.dart';
import '../util/screen_size.dart';
import '../widget/transparent_container.dart';

class ArticleList extends StatefulWidget {
  const ArticleList({super.key});

  @override
  State<ArticleList> createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  final TextEditingController _searchController = TextEditingController();
  final AnchorScrollController _scrollController = AnchorScrollController(
    anchorOffset: kToolbarHeight * 2.5,
  );
  int lastIndex = 0;

  void search(String? text) {
    setState(() {
      context.read<Api>().searchResults = text != null
          ? context
                .read<Api>()
                .filteredArticles
                ?.entries
                .where(
                  (entry) => entry.value.title.toLowerCase().contains(
                    text.toLowerCase(),
                  ),
                )
                .map((toElement) => toElement.key)
                .toList()
          : context
                .read<Api>()
                .filteredArticles
                ?.entries
                .map((toElement) => toElement.key)
                .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<Api>().listController = _scrollController;
  }

  @override
  void dispose() {
    context.read<Api>().listController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Article>? filteredArticles = context
        .select<Api, Map<String, Article>?>((a) => a.filteredArticles);
    List<String>? searchResults = context.select<Api, List<String>?>(
      (a) => a.searchResults,
    );
    return Scaffold(
      backgroundColor: Color.alphaBlend(
        Colors.black.withAlpha(24),
        Theme.of(context).scaffoldBackgroundColor,
      ),
      appBar: AppBar(
        flexibleSpace: const TransparentContainer(hasBorder: false),
        title: (Platform.isIOS || Platform.isMacOS)
            ? CupertinoSearchTextField(
                controller: _searchController,
                onChanged: (value) {
                  search(value);
                },
                onSuffixTap: () {
                  _searchController.clear();
                  search(null);
                },
                padding: const EdgeInsets.all(12.0),
                placeholder:
                    "Search ${context.select<Api, String?>((value) => value.filteredTitle)?.split("/").last ?? ""}",
              )
            : SearchBar(
                hintText:
                    "Search ${context.select<Api, String?>((value) => value.filteredTitle)?.split("/").last ?? ""}",
                controller: _searchController,
                textInputAction: TextInputAction.search,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.search),
                ),
                constraints: BoxConstraints(minHeight: 42.0),
                elevation: WidgetStatePropertyAll(0.0),
                trailing: _searchController.text != ""
                    ? [
                        IconButton(
                          onPressed: () {
                            _searchController.clear();
                            search(null);
                          },
                          icon: const Icon(Icons.clear),
                        ),
                      ]
                    : null,
                onChanged: (value) {
                  search(value);
                },
              ),
        leading: screenSizeOf(context) == ScreenSize.big
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
      bottomNavigationBar: TransparentContainer(
        hasBorder: false,
        child: SizedBox(height: MediaQuery.paddingOf(context).bottom),
      ),
      body:
          context.select<Api, String?>((value) => value.filteredTitle) ==
                  null ||
              filteredArticles == null ||
              searchResults == null
          ? const SizedBox()
          : Scrollbar(
              controller: _scrollController,
              child: ListView.separated(
                key: const PageStorageKey(0),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: searchResults.length,
                controller: _scrollController,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    String date = getFormattedDate(
                      filteredArticles[searchResults[index]]!.published,
                    ).split(", ")[1].split(" ")[0];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        separator(date),
                        AnchorItemWrapper(
                          index: index,
                          key: ValueKey("list-$index"),
                          controller: _scrollController,
                          child: ArticleTile(
                            article: filteredArticles[searchResults[index]]!,
                            index: index,
                          ),
                        ),
                      ],
                    );
                  }
                  return AnchorItemWrapper(
                    index: index,
                    key: ValueKey("list-$index"),
                    controller: _scrollController,
                    child: ArticleTile(
                      article: filteredArticles[searchResults[index]]!,
                      index: index,
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  int? previous =
                      filteredArticles[searchResults[index]]?.published;
                  if (previous != null) {
                    String previousDate = getFormattedDate(
                      previous,
                    ).split(", ")[1].split(" ")[0];
                    int? next =
                        filteredArticles[searchResults.elementAtOrNull(
                              index + 1,
                            )]
                            ?.published;
                    if (next != null) {
                      String nextDate = getFormattedDate(
                        next,
                      ).split(", ")[1].split(" ")[0];
                      if (nextDate != previousDate) {
                        return separator(nextDate);
                      }
                    }
                  }

                  return Container();
                },
              ),
            ),
    );
  }

  Widget separator(String date) {
    double? height = Theme.of(context).textTheme.bodyLarge?.height;
    return Text(
      "  $date",
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        height: height != null ? height * 1.5 : null,
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
          context.read<Api>().setRead(
            widget.article.articleID,
            widget.article.subID,
            !widget.article.read,
          );
        } else {
          context.read<Api>().setStarred(
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
            context.select<Api, String?>(
              (a) => a.subscriptions[widget.article.subID]?.iconUrl,
            ) ??
            "",
        subTitle:
            context.select<Api, String?>(
              (a) => a.subscriptions[widget.article.subID]?.title,
            ) ??
            "",
        onSelect: () {
          context.read<Api>().setSelectedIndex(widget.index, false, true);
          if (context.read<Api>().filteredArticles != null &&
              context.read<Api>().filteredArticles![widget.article.articleID] !=
                  null) {
            bool newValue = context.read<Preferences>().markReadWhenOpen
                ? true
                : widget.article.read;
            context.read<Api>().setRead(
              widget.article.articleID,
              context
                  .read<Api>()
                  .filteredArticles![widget.article.articleID]!
                  .subID,
              newValue,
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
    String? selectedID = context.select<Api, String?>(
      (a) => a.selectedIndex != null
          ? a.filteredArticleIDs?.elementAt(a.selectedIndex!)
          : null,
    );
    bool isRead = context.select<Api, bool>(
      (a) => a.articlesMetaData[article.articleID]!.$3,
    );
    bool isStarred = context.select<Api, bool>(
      (a) => a.articlesMetaData[article.articleID]!.$4,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          onTap: onSelect,
          // borderRadius: BorderRadius.circular(8.0),
          child: Container(
            height: 128.0,
            decoration: BoxDecoration(
              color: selectedID == article.articleID
                  ? Theme.of(context).listTileTheme.selectedTileColor
                  : null,
              // borderRadius: BorderRadius.circular(8.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Opacity(
              opacity: (article.read) ? 0.3 : 1.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8.0,
                children: [
                  if (article.image != null)
                    Container(
                      clipBehavior: Clip.hardEdge,
                      width: min(112.0, constraints.maxWidth / 3.0),
                      height: 112.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.grey.shade800,
                      ),
                      child: ArticleImage(
                        imageUrl: article.image!,
                        fit: BoxFit.cover,
                        onError: (error) => const Icon(Icons.error),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            // style: TextStyle(color: Colors.grey.shade500),
                            style: Theme.of(context).textTheme.bodySmall,
                            children: [
                              WidgetSpan(
                                child: ArticleImage(
                                  imageUrl: context.read<Api>().getIconUrl(
                                    subIcon,
                                  ),
                                  fit: BoxFit.contain,
                                  width: 16.0,
                                  height: 16.0,
                                  onError: (error) =>
                                      const Icon(Icons.error, size: 16.0),
                                ),
                              ),
                              TextSpan(text: " $subTitle"),
                            ],
                          ),
                        ),
                        Text(
                          article.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${isRead ? "" : "⚪️ "}${isStarred ? "⭐️ " : ""}${getFormattedDate(article.published)}",
                          // style: TextStyle(color: Colors.grey.shade500),
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

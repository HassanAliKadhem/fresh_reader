import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api.dart';
import '../api/data_types.dart';
import '../util/date.dart';
import '../util/formatting_setting.dart';
import 'article_image.dart';

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

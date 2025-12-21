import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/data.dart';
import '../util/date.dart';
import '../api/preferences.dart';
import 'article_image.dart';

class ArticleTile extends StatefulWidget {
  const ArticleTile({required this.articleID, required this.index, super.key});
  final int index;
  final String articleID;

  @override
  State<ArticleTile> createState() => _ArticleTileState();
}

class _ArticleTileState extends State<ArticleTile> {
  @override
  Widget build(BuildContext context) {
    final String subID = context
        .read<DataProvider>()
        .articlesMetaData[widget.articleID]!
        .$2;
    bool isRead = context.select<DataProvider, bool>(
      (a) => a.articlesMetaData[widget.articleID]!.$3,
    );
    bool isStarred = context.select<DataProvider, bool>(
      (a) => a.articlesMetaData[widget.articleID]!.$4,
    );
    return Dismissible(
      key: ValueKey("tile${widget.articleID}"),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          context.read<DataProvider>().setRead(
            widget.articleID,
            subID,
            !isRead,
          );
        } else {
          context.read<DataProvider>().setStarred(
            widget.articleID,
            subID,
            !isStarred,
          );
        }
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
                Icon(!isStarred ? Icons.star_border : Icons.star),
                Text(isStarred ? "  UnFavorite" : "  Favorite"),
              ],
            ),
            Row(
              children: [
                Text(isRead ? "Set Unread  " : "Set Read  "),
                Icon(isRead ? Icons.circle_outlined : Icons.circle_rounded),
              ],
            ),
          ],
        ),
      ),
      child: ArticleWidget(
        articleID: widget.articleID,
        subIcon:
            context.select<DataProvider, String?>(
              (a) => a.subscriptions[subID]?.iconUrl,
            ) ??
            "",
        subTitle:
            context.select<DataProvider, String?>(
              (a) => a.subscriptions[subID]?.title,
            ) ??
            "",
        onSelect: () {
          context.read<DataProvider>().setSelectedIndex(
            widget.index,
            false,
            true,
          );
          // if (context.read<Api>().filteredArticles != null &&
          //     context.read<Api>().filteredArticles![widget.articleID] != null) {
          bool newValue = context.read<Preferences>().markReadWhenOpen
              ? true
              : isRead;
          context.read<DataProvider>().setRead(
            widget.articleID,
            subID,
            newValue,
          );
          // }
        },
      ),
    );
  }
}

class ArticleWidget extends StatelessWidget {
  const ArticleWidget({
    super.key,
    required this.articleID,
    required this.subIcon,
    required this.subTitle,
    required this.onSelect,
  });
  final String articleID;
  final String subIcon;
  final String subTitle;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    bool isSelected = context.select<DataProvider, bool>(
      (a) =>
          a.selectedIndex != null &&
          a.filteredArticleIDs?.elementAt(a.selectedIndex!) == articleID,
    );
    bool isRead = context.select<DataProvider, bool>(
      (a) => a.articlesMetaData[articleID]!.$3,
    );
    bool isStarred = context.select<DataProvider, bool>(
      (a) => a.articlesMetaData[articleID]!.$4,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          onTap: onSelect,
          // borderRadius: BorderRadius.circular(8.0),
          child: Container(
            height: 128.0,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).listTileTheme.selectedTileColor
                  : null,
              // borderRadius: BorderRadius.circular(8.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Opacity(
              opacity: (isRead) ? 0.3 : 1.0,
              child: FutureBuilder(
                future: context.read<DataProvider>().db.loadArticles([
                  articleID,
                ], context.read<DataProvider>().accountID!),
                builder: (context, asyncSnapshot) {
                  if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                    return Container();
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8.0,
                    children: [
                      if (asyncSnapshot.data!.first.image != null)
                        Container(
                          clipBehavior: Clip.hardEdge,
                          width: min(112.0, constraints.maxWidth / 3.0),
                          height: 112.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.grey.shade800,
                          ),
                          child: ArticleImage(
                            imageUrl: asyncSnapshot.data!.first.image!,
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
                                      imageUrl: context
                                          .read<DataProvider>()
                                          .getIconUrl(subIcon),
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
                              asyncSnapshot.data!.first.title,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "${isRead ? "" : "⚪️ "}${isStarred ? "⭐️ " : ""}${getFormattedDate(asyncSnapshot.data!.first.published)}",
                              // style: TextStyle(color: Colors.grey.shade500),
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

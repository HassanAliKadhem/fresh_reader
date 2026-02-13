import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/data.dart';
import '../api/data_types.dart';
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
    var (_, subID, isRead, isStarred) = context
        .select<DataProvider, (int, String, bool, bool)>(
          (a) => a.articlesMetaData[widget.articleID]!,
        );
    return Dismissible(
      key: ValueKey("Dismissible_${widget.articleID}"),
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
      child: InkWell(
        onTap: () {
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
        },
        child: Opacity(
          opacity: isRead ? 0.3 : 1.0,
          child: ArticleWidget(
            articleID: widget.articleID,
            subIcon: context.read<DataProvider>().getIconUrl(
              context.read<DataProvider>().subscriptions[subID]?.iconUrl ?? "",
            ),
            subTitle:
                context.read<DataProvider>().subscriptions[subID]?.title ?? "",
            isStarred: isStarred,
          ),
        ),
      ),
    );
  }
}

class ArticleWidget extends StatefulWidget {
  const ArticleWidget({
    super.key,
    required this.articleID,
    required this.subIcon,
    required this.subTitle,
    required this.isStarred,
  });
  final String articleID;
  final String subIcon;
  final String subTitle;
  final bool isStarred;

  @override
  State<ArticleWidget> createState() => _ArticleWidgetState();
}

const double _tileHeight = 128.0;
const double _tileIconSize = 14.0;
const double _tilePadding = 8.0;

class _ArticleWidgetState extends State<ArticleWidget> {
  late final Future<List<Article>> future = context
      .read<DataProvider>()
      .db
      .loadArticles([
        widget.articleID,
      ], context.read<DataProvider>().accountID!);

  @override
  Widget build(BuildContext context) {
    bool isSelected = context.select<DataProvider, bool>(
      (a) =>
          a.selectedIndex != null &&
          a.filteredArticleIDs?.elementAt(a.selectedIndex!) == widget.articleID,
    );
    TextStyle? subTitleStyle = Theme.of(context).textTheme.bodySmall;
    TextStyle? titleStyle = Theme.of(context).textTheme.titleMedium;
    return Container(
      height: _tileHeight,
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).listTileTheme.selectedTileColor
            : null,
        // borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(_tilePadding),
      child: FutureBuilder(
        future: future,
        builder: (context, asyncSnapshot) {
          if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
            return Text(asyncSnapshot.error.toString());
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: _tilePadding,
            children: [
              if (asyncSnapshot.data!.first.image != null)
                Container(
                  clipBehavior: Clip.hardEdge,
                  width: _tileHeight - 16.0,
                  height: _tileHeight - 16.0,
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
                        style: subTitleStyle,
                        children: [
                          WidgetSpan(
                            child: ArticleImage(
                              imageUrl: widget.subIcon,
                              fit: BoxFit.contain,
                              width: _tileIconSize,
                              height: _tileIconSize,
                              onError: (error) =>
                                  const Icon(Icons.error, size: _tileIconSize),
                            ),
                          ),
                          TextSpan(text: " ${widget.subTitle}"),
                        ],
                      ),
                    ),
                    Text(
                      asyncSnapshot.data!.first.title,
                      style: titleStyle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${widget.isStarred ? "★ " : ""}${getFormattedDate(asyncSnapshot.data!.first.published)}",
                      // style: TextStyle(color: Colors.grey.shade500),
                      style: subTitleStyle,
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
    );
  }
}

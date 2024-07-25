import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fresh_reader/widget/blur_bar.dart';
import 'package:fresh_reader/api/data_types.dart';

import '../api/api.dart';

class ArticleList extends StatefulWidget {
  const ArticleList({
    super.key,
    required this.onSelect,
  });
  final Function(int, String) onSelect;

  @override
  State<ArticleList> createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  List<Article> currentArticles = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (Api.of(context).filteredArticles != null) {
      if (_searchController.text == "") {
        currentArticles = Api.of(context).filteredArticles!.values.toList();
      } else {
        currentArticles = Api.of(context)
            .filteredArticles!
            .values
            .where((element) =>
                element.title.toLowerCase().contains(_searchController.text) ||
                element.content.toLowerCase().contains(_searchController.text))
            .toList();
      }
    }
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + 15,
        title: SearchBar(
          hintText: "Search",
          controller: _searchController,
          trailing: [
            if (_searchController.text != "")
              IconButton(
                onPressed: () {
                  setState(() {
                    _searchController.text = "";
                  });
                },
                icon: const Icon(Icons.clear),
              ),
          ],
          onChanged: (value) {
            setState(() {});
          },
        ),
        flexibleSpace: const BlurBar(),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: articlesListView(),
    );
  }

  ListView articlesListView() {
    return ListView.separated(
      itemCount: currentArticles.length,
      separatorBuilder: (context, index) {
        int day = getDifferenceInDays(currentArticles[index].published);
        String date = getRelativeDate(currentArticles[index].published);
        String nextDate = getRelativeDate(currentArticles[index + 1].published);
        if (day > 0 && date != nextDate) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              nextDate,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
      itemBuilder: (context, index) {
        if (index == 0) {
          String date = getRelativeDate(currentArticles[index].published);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  date,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              articleTile(index),
            ],
          );
        } else {
          return articleTile(index);
        }
      },
    );
  }

  Dismissible articleTile(int index) {
    Article article = currentArticles[index];
    String? iconUrl = Api.of(context).getIconUrl(article.feedId);
    String? imgLink = getFirstImage(article.content);
    return Dismissible(
      key: ValueKey(article.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        Api.of(context)
            .setRead(article.id, !Api.of(context).isRead(article.id));
        setState(() {});
        return false;
      },
      background: Center(
        child: ListTile(
          title: Text(
            Api.of(context).isRead(article.id) ? "Set Unread" : "Set Read",
            textAlign: TextAlign.end,
          ),
          trailing: Icon(
            Api.of(context).isRead(article.id)
                ? Icons.circle_outlined
                : Icons.circle_rounded,
          ),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        clipBehavior: Clip.hardEdge,
        child: ListTile(
          title: Text(
            article.title,
            style: TextStyle(
              color: Api.of(context).isRead(article.id)
                  ? Theme.of(context).disabledColor
                  : null,
            ),
          ),
          subtitle: Text(
            "${Api.of(context).subs[article.feedId]?.title ?? ""}\n${getRelativeDate(article.published)}",
            style: TextStyle(
              color: Api.of(context).isRead(article.id)
                  ? Theme.of(context).disabledColor
                  : null,
            ),
          ),
          leading: iconUrl == null
              ? null
              : SizedBox(
                  height: 28,
                  width: 28,
                  child: CachedNetworkImage(
                    imageUrl: iconUrl,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                      value: downloadProgress.progress,
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
          trailing: Container(
            height: 48,
            width: 48,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            child: imgLink == null
                ? null
                : CachedNetworkImage(
                    imageUrl: imgLink,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: CircularProgressIndicator(
                                                    value: downloadProgress.progress,
                                                  ),
                            ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
          ),
          onTap: () => widget.onSelect(index, article.id),
        ),
      ),
    );
  }
}

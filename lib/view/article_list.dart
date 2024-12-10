import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fresh_reader/widget/blur_bar.dart';

import '../api/api.dart';
import '../api/data_types.dart';
import 'article_view.dart';

class ArticleList extends StatefulWidget {
  const ArticleList({
    super.key,
  });

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
    if (Api.of(context).filteredIndex != null &&
        _scrollController.hasClients &&
        Api.of(context).filteredIndex != currentIndex) {
      currentIndex = Api.of(context).filteredIndex!;
      double scrollTarget = (Api.of(context).filteredIndex! * 128);
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
          title: Text(Api.of(context).filteredTitle == null
              ? ""
              : Api.of(context).filteredTitle!.split("/").last),
        ),
        extendBody: true,
        extendBodyBehindAppBar: true,
        bottomNavigationBar: BlurBar(
          child: SizedBox(
            height: MediaQuery.paddingOf(context).bottom,
          ),
        ),
        body: Api.of(context).filteredArticles == null
            ? const SizedBox()
            : Builder(builder: (context) {
                List<Article> currentArticles = Api.of(context)
                    .filteredArticles!
                    .values
                    .where((article) => article.title
                        .toLowerCase()
                        .contains(_searchController.value.text.toLowerCase()))
                    .toList();
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
                    return ArticleTile(currentArticles[index - 1], index - 1);
                  },
                );
              }));
  }
}

class ArticleTile extends StatefulWidget {
  const ArticleTile(this.article, this.index, {super.key});
  final int index;
  final Article article;

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
            Api.of(context).setRead(
                widget.article.id, widget.article.subID, !widget.article.read);
          } else {
            Api.of(context).setStarred(widget.article.id, widget.article.subID,
                !widget.article.starred);
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
          onSelect: () {
            Api.of(context).filteredIndex = widget.index;
            if (Api.of(context).filteredArticles != null &&
                Api.of(context).filteredArticles![widget.article.id] != null) {
              currentArticleNotifier.value = Api.of(context).setRead(
                  widget.article.id,
                  Api.of(context).filteredArticles![widget.article.id]!.subID,
                  true);
            }
          },
        ));
  }
}

class ArticleWidget extends StatelessWidget {
  const ArticleWidget(
      {super.key, required this.article, required this.onSelect});
  final Article article;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    String? iconUrl = Api.of(context).getIconUrl(article.subID);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SizedBox(
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
                                    imageUrl: iconUrl ?? "",
                                    fit: BoxFit.contain,
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error, size: 16),
                                  ),
                                ),
                              ),
                              TextSpan(
                                text:
                                    "  ${Api.of(context).subs[article.subID]?.title}",
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

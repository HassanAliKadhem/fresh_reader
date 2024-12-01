import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fresh_reader/widget/blur_bar.dart';

import '../api/api.dart';
import '../api/data_types.dart';

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
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(Api.of(context).filteredTitle == null
              ? ""
              : Api.of(context).filteredTitle!.split("/").last),
          bottom: PreferredSize(
            preferredSize: const Size(double.infinity, kToolbarHeight),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchBar(
                hintText: "Search",
                controller: _searchController,
                backgroundColor: const WidgetStatePropertyAll(Colors.black26),
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
            ),
          ),
          flexibleSpace: const BlurBar(),
        ),
        extendBody: true,
        extendBodyBehindAppBar: true,
        bottomNavigationBar: BlurBar(
          child: SizedBox(
            height: MediaQuery.paddingOf(context).bottom,
          ),
        ),
        body: Api.of(context).filteredArticles == null
            ? const Center(child: CircularProgressIndicator.adaptive())
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
                  itemCount: currentArticles.length,
                  // separatorBuilder: (context, index) {
                  //   return const SizedBox(height: 16,);
                  // int day = getDifferenceInDays(currentArticles[index].published);
                  // String date = getRelativeDate(currentArticles[index].published);
                  // String nextDate = getRelativeDate(currentArticles[index + 1].published);
                  // if (day > 0 && date != nextDate) {
                  //   return Padding(
                  //     padding:
                  //         const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  //     child: Text(
                  //       nextDate,
                  //       style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  //     ),
                  //   );
                  // } else {
                  //   return const SizedBox();
                  // }
                  // },
                  itemBuilder: (context, index) {
                    return ArticleTile(
                        currentArticles[index], index, widget.onSelect);
                  },
                );
              }));
  }
}

class ArticleTile extends StatefulWidget {
  const ArticleTile(this.article, this.index, this.onSelect, {super.key});
  final int index;
  final Article article;
  final Function(int, String) onSelect;

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
          onSelect: () => widget.onSelect(widget.index, widget.article.id),
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        height: 120,
        child: Opacity(
          opacity: (article.read) ? 0.5 : 1,
          child: InkWell(
            onTap: onSelect,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (article.image != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
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
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        article.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8.0),
                      Opacity(
                        opacity: 0.75,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                child: SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CachedNetworkImage(
                                    imageUrl: iconUrl ?? "",
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                              ),
                              TextSpan(
                                text:
                                    "  ${Api.of(context).subs[article.subID]?.title}${"  -  ${getRelativeDate(article.published)} ${article.read ? "✔️" : ""} ${article.starred ? "★" : ""}"}",
                              ),
                            ],
                          ),
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
    // return ListTile(
    //   textColor:
    //       (article?.read ?? false) ? Theme.of(context).disabledColor : null,
    //   visualDensity: VisualDensity.compact,
    //   title: Text(
    //     article?.title ?? "",
    //     maxLines: 2,
    //     overflow: TextOverflow.ellipsis,
    //   ),
    //   onTap: () => onSelect,
    //   subtitle: Column(
    //     children: [
    //       if (iconUrl != null)
    //         SizedBox(
    //           height: 16,
    //           width: 16,
    //           child: CachedNetworkImage(
    //             imageUrl: iconUrl,
    //             errorWidget: (context, url, error) => const Icon(Icons.error),
    //           ),
    //         ),
    //       Text(
    //         Api.of(context).subs[article?.subID]?.title ?? "",
    //         maxLines: 1,
    //         overflow: TextOverflow.ellipsis,
    //       ),
    //       Text(
    //         article != null
    //             ? "${getRelativeDate(article!.published)} ${article!.read ? "" : "⚪️"} ${article!.starred ? "⭐️" : ""}"
    //             : "",
    //         maxLines: 1,
    //         overflow: TextOverflow.ellipsis,
    //       ),
    //     ],
    //   ),
    //   leading: imgLink == null
    //       ? null
    //       : Container(
    //           clipBehavior: Clip.hardEdge,
    //           decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
    //           child: CachedNetworkImage(
    //             imageUrl: imgLink,
    //             fit: BoxFit.cover,
    //             width: 80,
    //             height: 80,
    //             placeholder: (context, url) {
    //               return Container(
    //                 color: Colors.grey.shade800,
    //                 height: 64,
    //                 width: 64,
    //               );
    //             },
    //             errorWidget: (context, url, error) => const Icon(Icons.error),
    //           ),
    //         ),
    // );
  }
}

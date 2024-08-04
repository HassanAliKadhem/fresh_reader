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
  Set<String> currentArticlesIDs = <String>{};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      setState(() {
        currentArticlesIDs = currentArticlesIDs =
            Api.of(context).filteredArticleIDs ?? <String>{};
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Api.of(context).filteredTitle == null
            ? ""
            : Api.of(context).filteredTitle!.split("/").last),
        // bottom: PreferredSize(
        //     preferredSize: const Size(double.infinity, kToolbarHeight),
        //     child: Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: SearchBar(
        //         hintText: "Search",
        //         controller: _searchController,
        //         backgroundColor: const WidgetStatePropertyAll(Colors.black26),
        //         trailing: [
        //           if (_searchController.text != "")
        //             IconButton(
        //               onPressed: () {
        //                 setState(() {
        //                   _searchController.text = "";
        //                 });
        //               },
        //               icon: const Icon(Icons.clear),
        //             ),
        //         ],
        //         onChanged: (value) {
        //           setState(() {});
        //         },
        //       ),
        //     ),),
        flexibleSpace: const BlurBar(),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: articlesListView(),
    );
  }

  ListView articlesListView() {
    return ListView.builder(
      cacheExtent: MediaQuery.sizeOf(context).height * 2,
      itemCount: currentArticlesIDs.length,
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
        return articleTile(index);
      },
    );
  }

  Widget articleTile(int index) {
    return FutureBuilder(
      future:
          Api.of(context).db!.loadArticle(currentArticlesIDs.elementAt(index)),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return ArticleWidget(article: null, onSelect: () {});
        } else {
          return Dismissible(
              key: ValueKey(snapshot.data!.id),
              direction: DismissDirection.horizontal,
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  Api.of(context).setRead(snapshot.data!.id,
                      snapshot.data!.subID, !snapshot.data!.read);
                } else {
                  Api.of(context).setStarred(snapshot.data!.id,
                      snapshot.data!.subID, !snapshot.data!.starred);
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
                          !snapshot.data!.starred
                              ? Icons.star_border
                              : Icons.star,
                        ),
                        Text(
                          snapshot.data!.read ? "UnFavorite" : "Favorite",
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          snapshot.data!.read ? "Set Unread" : "Set Read",
                          textAlign: TextAlign.end,
                        ),
                        Icon(
                          snapshot.data!.read
                              ? Icons.circle_outlined
                              : Icons.circle_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              child: ArticleWidget(
                article: snapshot.data,
                onSelect: () => widget.onSelect(index, snapshot.data!.id),
              ));
        }
      },
    );
  }
}

class ArticleWidget extends StatelessWidget {
  const ArticleWidget(
      {super.key, required this.article, required this.onSelect});
  final Article? article;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    String? iconUrl = Api.of(context).getIconUrl(article?.subID ?? "");
    String? imgLink = getFirstImage(article?.content ?? "");
    double imgSize = MediaQuery.sizeOf(context).width / 4;
    return Opacity(
      opacity: (article != null && (article?.read ?? false)) ? 0.5 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: InkWell(
          onTap: onSelect,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (imgLink != null)
                Container(
                  clipBehavior: Clip.hardEdge,
                  width: imgSize,
                  height: imgSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey.shade800,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imgLink,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article?.title ?? "\n\n",
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 4,
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
                                  "  ${Api.of(context).subs[article?.subID]?.title}${article != null ? "  -  ${getRelativeDate(article!.published)} ${article!.read ? "✔️" : ""} ${article!.starred ? "★" : ""}" : ""}",
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

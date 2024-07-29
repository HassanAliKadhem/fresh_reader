import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fresh_reader/widget/blur_bar.dart';

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
  // final TextEditingController _searchController = TextEditingController();
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
    // Set<String> articleIDs = <String>{};
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + 15,
        title: Text(Api.of(context).filteredTitle == null
            ? ""
            : Api.of(context).filteredTitle!.split("/").last),
        // title: SearchBar(
        //   hintText: "Search",
        //   controller: _searchController,
        //   trailing: [
        //     if (_searchController.text != "")
        //       IconButton(
        //         onPressed: () {
        //           setState(() {
        //             _searchController.text = "";
        //           });
        //         },
        //         icon: const Icon(Icons.clear),
        //       ),
        //   ],
        //   onChanged: (value) {
        //     setState(() {});
        //   },
        // ),
        flexibleSpace: const BlurBar(),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: articlesListView(),
    );
  }

  ListView articlesListView() {
    return ListView.separated(
      cacheExtent: 250,
      itemCount: currentArticlesIDs.length,
      separatorBuilder: (context, index) {
        return const SizedBox();
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
      },
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
          return const ListTile(
            title: Text(" \n "),
            subtitle: Text(" \n "),
          );
        } else {
          String? iconUrl = Api.of(context).getIconUrl(snapshot.data!.subID);
          String? imgLink = getFirstImage(snapshot.data!.content);
          return Dismissible(
            key: ValueKey(snapshot.data!.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              Api.of(context).setRead(snapshot.data!.id, snapshot.data!.subID,
                  !snapshot.data!.read);
              setState(() {});
              return false;
            },
            background: Center(
              child: ListTile(
                title: Text(
                  snapshot.data!.read ? "Set Unread" : "Set Read",
                  textAlign: TextAlign.end,
                ),
                trailing: Icon(
                  snapshot.data!.read
                      ? Icons.circle_outlined
                      : Icons.circle_rounded,
                ),
              ),
            ),
            child: Card(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              clipBehavior: Clip.hardEdge,
              child: ListTile(
                title: Text(
                  snapshot.data!.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: snapshot.data!.read
                        ? Theme.of(context).disabledColor
                        : null,
                  ),
                ),
                onTap: () => widget.onSelect(index, snapshot.data!.id),
                subtitle: Text(
                  "${Api.of(context).subs[snapshot.data!.subID]?.title ?? ""}\n${getRelativeDate(snapshot.data!.published)}",
                  style: TextStyle(
                    color: snapshot.data!.read
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
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                trailing: imgLink == null
                    ? null
                    : CachedNetworkImage(
                        imageUrl: imgLink,
                        height: 48,
                        width: 48,
                        placeholder: (context, url) {
                          return Container(
                            color: Colors.grey.shade800,
                            height: 48,
                            width: 48,
                          );
                        },
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
              ),
            ),
          );
        }
      },
    );
  }
}

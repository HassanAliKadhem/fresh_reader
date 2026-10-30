import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../api/data.dart';
import '../api/data_types.dart';
import 'article_image.dart';
import 'unread_count.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.categoryName,
    required this.selected,
    required this.openAll,
    required this.openFeed,
    required this.currentSubscriptions,
  });
  final String categoryName;
  final String selected;
  final Function openAll;
  final Function(String key) openFeed;
  final Map<String, Subscription> currentSubscriptions;

  @override
  Widget build(BuildContext context) {
    bool showAll = context.select<DataProvider, bool>((a) => a.showAll);
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(categoryName),
        key: PageStorageKey('categoryTile_$categoryName'),
        shape: const Border(),
        initiallyExpanded: true,
        // controlAffinity: ListTileControlAffinity.leading,
        children: [
          ListTile(
            selected: selected == categoryName,
            title: Text("All $categoryName"),
            trailing: UnreadCounter(
              (a) =>
                  currentSubscriptions.keys.contains(a.$2) &&
                  (showAll || !a.$3),
            ),
            onTap: () => openAll(),
          ),
          ...currentSubscriptions.keys
              .where(
                (sub) =>
                    showAll ||
                    context.select<DataProvider, bool>(
                      (value) => value.articlesMetaData.values.any(
                        (a) => a.$2 == sub && (showAll || !a.$3),
                      ),
                    ),
              )
              .map<Widget>((key) {
                return ListTile(
                  // shape: Border(
                  //   top: BorderSide(
                  //     color:
                  //         Theme.of(
                  //           context,
                  //         ).scaffoldBackgroundColor,
                  //     width: 2.0,
                  //   ),
                  // ),
                  selected: selected == currentSubscriptions[key]!.title,
                  title: Text(currentSubscriptions[key]!.title),
                  trailing: UnreadCounter(
                    (a) => a.$2 == key && (showAll || !a.$3),
                  ),
                  leading: ArticleImage(
                    imageUrl: context.read<DataProvider>().getIconUrl(
                      currentSubscriptions[key]!.iconUrl,
                    ),
                    height: 28,
                    width: 28,
                    onError: (error) => const Icon(Icons.error),
                  ),
                  onTap: () {
                    openFeed(key);
                  },
                  onLongPress: () {
                    showInfoDialog(context, currentSubscriptions[key]!.title, [
                      ["Url", currentSubscriptions[key]!.htmlUrl],
                      ["RssUrl", currentSubscriptions[key]!.url],
                      [
                        "IconUrl",
                        context.read<DataProvider>().getIconUrl(
                          currentSubscriptions[key]!.iconUrl,
                        ),
                      ],
                    ]);
                  },
                );
              }),
        ],
      ),
    );
  }

  Future<void> showInfoDialog(
    BuildContext context,
    String title,
    List<List<String>> urls,
  ) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        scrollable: true,
        content: Column(
          children: [
            ListTile(title: Text("Category: $categoryName"), dense: true),
            ...urls.map(
              (url) => ListTile(
                title: Text("${url[0]}: ${url[1]}"),
                trailing: url[0] == "IconUrl"
                    ? ArticleImage(
                        imageUrl: url[1],
                        height: 28,
                        width: 28,
                        onError: (error) => const Icon(Icons.error),
                      )
                    : const Icon(Icons.open_in_browser),
                dense: true,
                onTap: () {
                  launchUrlString(url[1]);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Close"),
          ),
        ],
      ),
    );
  }
}

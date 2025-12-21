import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        controlAffinity: ListTileControlAffinity.leading,
        children: [
          ListTile(
            selected: selected == categoryName,
            title: Text("All $categoryName"),
            trailing: UnreadCount(
              context.select<DataProvider, int>(
                (value) => value.articlesMetaData.values
                    .where(
                      (a) =>
                          currentSubscriptions.keys.contains(a.$2) &&
                          (showAll || !a.$3),
                    )
                    .length,
              ),
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
                  trailing: UnreadCount(
                    context.select<DataProvider, int>(
                      (value) => value.articlesMetaData.values
                          .where((a) => a.$2 == key && (showAll || !a.$3))
                          .length,
                    ),
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
                );
              }),
        ],
      ),
    );
  }
}

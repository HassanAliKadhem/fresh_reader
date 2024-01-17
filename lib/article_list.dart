import 'package:flutter/material.dart';
import 'package:fresh_reader/data_types.dart';

import 'api.dart';
import 'article_view.dart';

class ArticleList extends StatefulWidget {
  const ArticleList({
    super.key,
    required this.title,
    required this.filter,
  });
  final String title;
  final String filter;
  @override
  State<ArticleList> createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  late List<Article> articles = [];

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      articles = Api.of(context).getFilteredArticles(widget.filter).values.toList();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          Article article = articles[index];
          String imgLink = getFirstImage(article.title);
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
                  Api.of(context).isRead(article.id)
                      ? "Set Unread"
                      : "Set Read",
                  textAlign: TextAlign.end,
                ),
                trailing: Icon(
                  Api.of(context).isRead(article.id)
                      ? Icons.circle_outlined
                      : Icons.circle_rounded,
                ),
              ),
            ),
            child: ListTile(
              title: Text(
                article.title,
                style: TextStyle(
                  color: Api.of(context).isRead(article.id)
                      ? Colors.grey.shade700
                      : null,
                ),
              ),
              subtitle: Text(
                "${Api.of(context).subs[article.feedId]?.title ?? ""}\n${getRelativeDate(article.published)}",
                style: TextStyle(
                  color: Api.of(context).isRead(article.id)
                      ? Colors.grey.shade800
                      : null,
                ),
              ),
              // isThreeLine: true,
              trailing: Container(
                height: 48,
                width: 48,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: imgLink == ""
                    ? null
                    : Image.network(
                        imgLink,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return const Center(
                              child: CircularProgressIndicator.adaptive(),
                            );
                          }
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox();
                        },
                      ),
              ),
              onTap: () {
                Api.of(context).setRead(article.id, true);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ArticleView(index: index, articles: articles)),
                ).then((value) {
                  setState(() {});
                });
              },
            ),
          );
        },
      ),
    );
  }
}

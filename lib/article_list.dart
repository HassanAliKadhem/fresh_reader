import 'package:flutter/material.dart';
import 'package:fresh_reader/article_view.dart';

class ArticleList extends StatefulWidget {
  const ArticleList({
    super.key,
    required this.title,
    required this.articles,
  });
  final String title;
  final List<dynamic> articles;
  @override
  State<ArticleList> createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: widget.articles.length,
        itemBuilder: (context, index) {
          dynamic article = widget.articles[index];
          return ListTile(
            title: Text(article["title"]),
            subtitle: Text(
                DateTime.fromMillisecondsSinceEpoch(article["published"]*1000)
                    .toString()),
            leading: Icon(
              widget.articles[index]["read"] ?? false
                  ? Icons.remove_red_eye_outlined
                  : Icons.remove_red_eye,
            ),
            // trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ArticleView(index: index, articles: widget.articles)),
            ),
          );
        },
      ),
    );
  }
}

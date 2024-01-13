import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class ArticleView extends StatefulWidget {
  const ArticleView({
    required this.index,
    required this.articles,
    super.key,
  });
  final int index;
  final List<dynamic> articles;
  @override
  State<ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  late PageController _pageController;
  int currentIndex = 0;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index);
    currentIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight * 1.5,
        title: Text(widget.articles[currentIndex]["title"], maxLines: 2),
      ),
      bottomNavigationBar: Container(
        height: 48 + MediaQuery.viewPaddingOf(context).bottom,
        color: Theme.of(context).colorScheme.inversePrimary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                widget.articles[currentIndex]["read"]?? false
                    ? Icons.remove_red_eye_outlined
                    : Icons.remove_red_eye,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.open_in_browser,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.share,
              ),
            ),
          ],
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        itemCount: widget.articles.length,
        itemBuilder: (context, index) {
          dynamic article = widget.articles[index];
          return SelectionArea(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  DateTime.fromMillisecondsSinceEpoch(article["published"]*1000)
                      .toString(),
                ),
                HtmlWidget(
                  article["summary"]["content"] ?? "",
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

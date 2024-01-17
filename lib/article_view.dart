import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api.dart';
import 'data_types.dart';

class ArticleView extends StatefulWidget {
  const ArticleView({
    super.key,
    required this.index,
    required this.articles,
  });
  final int index;
  final List<Article> articles;
  @override
  State<ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  late PageController _pageController;
  int currentIndex = 0;
  bool showWebView = false;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index);
    currentIndex = widget.index;
  }

  void _onShare(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (Platform.isAndroid) {
      Share.shareUri(Uri.parse(widget.articles[currentIndex].urls.first));
    } else {
      Share.share(
        widget.articles[currentIndex].urls.first,
        subject: widget.articles[currentIndex].title,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    }
  }

  void _onPageChanged(BuildContext context, int page) {
    Api.of(context).setRead(widget.articles[page].id, true);
    setState(() {
      currentIndex = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$currentIndex / ${widget.articles.length}"),
      ),
      bottomNavigationBar: Container(
        height: 48 + MediaQuery.viewPaddingOf(context).bottom,
        color: Theme.of(context).colorScheme.inversePrimary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                Api.of(context).setRead(widget.articles[currentIndex].id,
                    !Api.of(context).isRead(widget.articles[currentIndex].id));
                setState(() {});
              },
              icon: Icon(
                Api.of(context).isRead(widget.articles[currentIndex].id)
                    ? Icons.circle_outlined
                    : Icons.circle_rounded,
              ),
            ),
            IconButton(
              onPressed: () {
                launchUrl(
                  Uri.parse(widget.articles[currentIndex].urls.first),
                  mode: LaunchMode.inAppBrowserView,
                );
              },
              icon: const Icon(
                Icons.open_in_browser,
              ),
            ),
            Builder(builder: (context) {
              return IconButton(
                onPressed: () {
                  _onShare(context);
                },
                icon: const Icon(
                  Icons.share,
                ),
              );
            }),
            DropdownButtonHideUnderline(
              child: DropdownButton<bool>(
                icon: const SizedBox(),
                value: showWebView,
                items: const [
                  DropdownMenuItem<bool>(
                    value: true,
                    child: Text("Web"),
                  ),
                  DropdownMenuItem<bool>(
                    value: false,
                    child: Text("Text"),
                  ),
                ],
                onChanged: (value) {
                  if (showWebView != value) {
                    setState(() {
                      showWebView = value ?? false;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (value) => _onPageChanged(context, value),
        itemCount: widget.articles.length,
        itemBuilder: (context, index) {
          Article article = widget.articles[index];
          late WebViewController controller;
          if (showWebView) {
            controller = WebViewController();
            controller.loadRequest(Uri.parse(article.urls.first));
          }
          return showWebView
              ? WebViewWidget(controller: controller)
              : SelectionArea(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.all(0),
                        title: Text(article.title),
                        subtitle: Text(
                          "${getRelativeDate(article.published)}, ${DateTime.fromMillisecondsSinceEpoch(article.published * 1000)}",
                        ),
                      ),
                      HtmlWidget(
                        article.content,
                        onTapUrl: (url) {
                          launchUrl(Uri.parse(url),
                              mode: LaunchMode.inAppBrowserView);
                          return true;
                        },
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fresh_reader/main.dart';
import 'package:fresh_reader/view/article_list.dart';
import 'package:fresh_reader/widget/article_buttons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../api/database.dart';
import '../api/filter.dart';
import '../util/date_helper.dart';
import '../util/formatting_setting.dart';

class ArticleView extends StatefulWidget {
  const ArticleView({super.key});
  @override
  State<ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  bool showWebView = false;
  final FormattingSetting formattingSetting = FormattingSetting();
  late final PageController _pageController =
      PageController(initialPage: articleIndex.value ?? 0);

  @override
  void initState() {
    super.initState();
    print(articleIndex.value);
    print("init state");
    if (articleIndex.value != null) {
      Future.microtask(
        () => _onPageChanged(articleIndex.value!),
      );
    }
    articleIndex.addListener(() => changeToCurrent());
  }

  @override
  void dispose() {
    super.dispose();
    articleIndex.removeListener(() => changeToCurrent());
  }

  void changeToCurrent() {
    if (articleIndex.value != null &&
        _pageController.hasClients &&
        articleIndex.value != _pageController.page!.toInt() &&
        _pageController.page!.toInt() == _pageController.page) {
      final int index = articleIndex.value!;
      Future.microtask(() {
        _pageController.jumpToPage(index);
      });
    }
  }

  void _onPageChanged(int page) {
    articleIndex.value = page;
    Filter.of(context).api?.setRead(currentArticles[articleIndex.value!].$1,
        currentArticles[articleIndex.value!].$2.serverID, true);
  }

  @override
  Widget build(BuildContext context) {
    if (articleIndex.value == null ||
        currentArticles.isEmpty ||
        articleIndex.value! >= currentArticles.length) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: ArticleCount(),
        // flexibleSpace: const BlurBar(),
        actions: [
          FormatButton(
            formattingSetting: formattingSetting,
            showWebView: showWebView,
          ),
        ],
      ),
      extendBodyBehindAppBar: !showWebView,
      extendBody: !showWebView,
      bottomNavigationBar: ArticleBottomButtons(
        formattingSetting: formattingSetting,
        showWebView: showWebView,
        changeShowWebView: () {
          setState(() {
            showWebView = !showWebView;
          });
        },
      ),
      body: ArticleViewPages(
        controller: _pageController,
        onPageChanged: (value) => _onPageChanged(value),
        showWebView: showWebView,
        formattingSetting: formattingSetting,
      ),
    );
  }
}

class ArticleViewPages extends StatefulWidget {
  const ArticleViewPages({
    super.key,
    required this.controller,
    required this.onPageChanged,
    required this.showWebView,
    required this.formattingSetting,
  });
  final PageController controller;
  final void Function(int) onPageChanged;
  final bool showWebView;
  final FormattingSetting formattingSetting;

  @override
  State<ArticleViewPages> createState() => _ArticleViewPagesState();
}

class _ArticleViewPagesState extends State<ArticleViewPages> {
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      allowImplicitScrolling: true,
      controller: widget.controller,
      onPageChanged: (value) => widget.onPageChanged(value),
      itemCount: currentArticles.length,
      itemBuilder: (context, index) {
        return ArticlePage(
          key: ValueKey("${currentArticles[index].$1.id}${widget.showWebView}"),
          article: currentArticles[index].$1,
          subscription: currentArticles[index].$2,
          showWebView: widget.showWebView,
          formattingSetting: widget.formattingSetting,
        );
      },
    );
  }
}

class ArticleCount extends StatelessWidget {
  const ArticleCount({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      articleIndex.value == null
          ? ""
          : "${articleIndex.value! + 1} / ${currentArticles.length}",
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }
}

class ArticlePage extends StatefulWidget {
  const ArticlePage({
    super.key,
    required this.article,
    required this.subscription,
    required this.showWebView,
    required this.formattingSetting,
  });

  final ArticleData article;
  final SubscriptionData subscription;
  final bool showWebView;
  final FormattingSetting formattingSetting;

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  @override
  Widget build(BuildContext context) {
    if (widget.showWebView) {
      return ArticleWebWidget(
        key: ValueKey(widget.article.url),
        url: widget.article.url,
      );
    } else {
      return ArticleTextWidget(
        key: ValueKey("text_${widget.article.url}"),
        article: widget.article,
        formattingSetting: widget.formattingSetting,
      );
    }
  }
}

class ArticleWebWidget extends StatefulWidget {
  const ArticleWebWidget({super.key, required this.url});
  final String url;

  @override
  State<ArticleWebWidget> createState() => _ArticleWebWidgetState();
}

class _ArticleWebWidgetState extends State<ArticleWebWidget> {
  late final WebViewController webViewController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse(widget.url));

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: webViewController,
      gestureRecognizers: {
        Factory<LongPressGestureRecognizer>(
          () => LongPressGestureRecognizer(),
        ),
        Factory<VerticalDragGestureRecognizer>(
          () => VerticalDragGestureRecognizer(),
        ),
      },
    );
  }
}

List<String> imgExtensions = [
  ".jpg",
  ".jpeg",
  ".apng",
  ".png",
  ".gif",
  ".webp",
  ".tiff",
  ".avif",
  ".bmp"
];

class ArticleTextWidget extends StatelessWidget {
  const ArticleTextWidget({
    super.key,
    required this.article,
    required this.formattingSetting,
  });
  final ArticleData article;
  final FormattingSetting formattingSetting;

  void showLinkMenu(BuildContext context, String link) {
    showDialog(
      context: context,
      builder: (context) {
        Widget? image;
        if (imgExtensions.any((ext) => link.toLowerCase().endsWith(ext))) {
          image = CachedNetworkImage(
            imageUrl: link,
            width: 128,
            height: 128,
          );
        }
        return AlertDialog(
          icon: image,
          title: Text(
            link,
            textScaler: const TextScaler.linear(0.75),
            style: TextStyle(color: Colors.white60),
          ),
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.hardEdge,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(),
                ListTile(
                  title: const Text("Open in browser"),
                  trailing: const Icon(Icons.open_in_browser),
                  onTap: () {
                    launchUrl(Uri.parse(link));
                  },
                ),
                ListTile(
                  title: const Text("Share Link"),
                  trailing: const Icon(Icons.share),
                  onTap: () {
                    try {
                      Share.shareUri(Uri.parse(link));
                    } catch (e) {
                      final box = context.findRenderObject() as RenderBox?;
                      Share.share(
                        link,
                        subject: "",
                        sharePositionOrigin:
                            box!.localToGlobal(Offset.zero) & box.size,
                      );
                      debugPrint(e.toString());
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showImage(BuildContext context, String url) {
    showImageViewer(
      context,
      CachedNetworkImageProvider(url),
      swipeDismissible: true,
      doubleTapZoomable: true,
      immersive: false,
      backgroundColor: Colors.black54,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: formattingSetting,
      builder: (context, child) {
        return AnimatedDefaultTextStyle(
          style: TextStyle(
            fontFamily: formattingSetting.font,
            fontSize: formattingSetting.fontSize,
            wordSpacing: formattingSetting.wordSpacing,
            height: formattingSetting.lineHeight,
          ),
          duration: const Duration(milliseconds: 100),
          child: child!,
        );
      },
      child: SelectionArea(
        child: ListView(
          padding:
              EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: [
                if (article.image != null)
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height / 2),
                    child: Container(
                      width: double.infinity,
                      foregroundDecoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black54,
                            Colors.black,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.7, 1],
                        ),
                      ),
                      child: CachedNetworkImage(
                        fit: BoxFit.fitWidth,
                        imageUrl: article.image!,
                        errorWidget: (context, url, error) => kDebugMode
                            ? Center(
                                child: Text(error.toString()),
                              )
                            : Center(child: Icon(Icons.error)),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: kToolbarHeight + 24),
                  child: InkWell(
                    onLongPress: () {
                      showLinkMenu(context, article.url);
                    },
                    onTap: () {
                      launchUrl(Uri.parse(article.url));
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.title,
                                textScaler: const TextScaler.linear(1.25),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${getRelativeDate(article.published)}, ${DateTime.fromMillisecondsSinceEpoch(article.published * 1000).toString().split(".").first}",
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Text.rich(
              textScaler: TextScaler.linear(1.15),
              TextSpan(
                children: [
                  TextSpan(text: "    "),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.bottom,
                    child: FutureBuilder<SubscriptionData>(
                        future: (database.select(database.subscription)
                              ..where((tbl) => tbl.account
                                  .equals(Filter.of(context).api!.account.id))
                              ..where(
                                  (tbl) => tbl.id.equals(article.subscription)))
                            .getSingle(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Icon(Icons.error);
                          return CachedNetworkImage(
                            alignment: Alignment.bottomCenter,
                            height: 16,
                            width: 16,
                            imageUrl: snapshot.data!.iconUrl,
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          );
                        }),
                  ),
                  TextSpan(text: "  ${"article.subscriptionId.title"}"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: HtmlWidget(
                article.content.replaceAll("<a", "<a class=\"link\""),
                buildAsync: true,
                enableCaching: true,
                onErrorBuilder: (context, element, error) {
                  return Placeholder(
                    child: Text(error.toString()),
                  );
                },
                onTapImage: (p0) {
                  if (p0.sources.isNotEmpty) {
                    showImage(context, p0.sources.first.url);
                  }
                },
                customWidgetBuilder: (element) {
                  if (element.classes.contains("link")) {
                    Widget? imgWidget;
                    if (element.children
                        .any((child) => child.localName == "img")) {
                      for (var child in element.children) {
                        if (child.localName == "img") {
                          imgWidget = CachedNetworkImage(
                            fit: BoxFit.fitWidth,
                            imageUrl: child.attributes["src"] ?? "",
                            width: double.tryParse(
                                child.attributes["width"] ?? ""),
                            height: double.tryParse(
                                child.attributes["height"] ?? ""),
                            errorWidget: (context, url, error) {
                              return Placeholder(
                                child: Text(error.toString()),
                              );
                            },
                          );
                        }
                      }
                    }
                    return InlineCustomWidget(
                      child: GestureDetector(
                        onLongPress: () {
                          showLinkMenu(context, element.attributes["href"]!);
                        },
                        onTap: () {
                          launchUrl(Uri.parse(element.attributes["href"]!));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (imgWidget != null) imgWidget,
                            Text(
                              element.text,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

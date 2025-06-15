import 'dart:io';

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../api/api.dart';
import '../api/data_types.dart';
import '../api/database.dart';
import '../util/formatting_setting.dart';
import '../widget/adaptive_list_tile.dart';
import '../widget/article_buttons.dart';
import '../widget/article_image.dart';
import '../widget/blur_bar.dart';

class ArticleView extends StatefulWidget {
  const ArticleView({super.key, required this.index, required this.articleIDs});
  final int? index;
  final Set<String>? articleIDs;

  @override
  State<ArticleView> createState() => _ArticleViewState();
}

ValueNotifier<Article?> currentArticleNotifier = ValueNotifier<Article?>(null);

class _ArticleViewState extends State<ArticleView> {
  bool showWebView = false;
  late final FormattingSetting formattingSetting = FormattingSetting();
  late final PageController _pageController = PageController(
    initialPage: widget.index ?? 0,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Api.of(context).selectedIndex != null &&
        _pageController.hasClients &&
        Api.of(context).selectedIndex != _pageController.page!.toInt() &&
        _pageController.page!.toInt() == _pageController.page) {
      final int index = Api.of(context).selectedIndex!;
      Future.microtask(() {
        _pageController.jumpToPage(index);
      });
    }
  }

  void _onPageChanged(int page) {
    Api.of(context).selectedIndex = page;
    currentArticleNotifier.value = Api.of(context).setRead(
      Api.of(
        context,
      ).filteredArticles![Api.of(context).searchResults![page]]!.articleID,
      Api.of(
        context,
      ).filteredArticles![Api.of(context).searchResults![page]]!.subID,
      true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ArticleCount(
          currentArticleNotifier: currentArticleNotifier,
          articleIDS: widget.articleIDs ?? {},
        ),
        automaticallyImplyLeading: screenSizeOf(context) == ScreenSize.small,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                barrierDismissible: true,
                barrierColor: Colors.transparent,
                context: context,
                builder: (context) {
                  return AlertDialog(
                    alignment: Alignment.topRight,
                    scrollable: true,
                    contentPadding: EdgeInsets.all(8.0),
                    insetPadding: EdgeInsets.only(
                      top: MediaQuery.paddingOf(context).top + kToolbarHeight,
                      right: 16.0,
                      left: 16.0,
                    ),
                    // title: Text("Formatting settings"),
                    content: ConstrainedBox(
                      constraints: BoxConstraints.tightFor(width: 400.0),
                      child: FormattingBottomSheet(
                        formattingSetting: formattingSetting,
                      ),
                    ),
                  );
                },
              );
              // showModalBottomSheet(
              //   context: context,
              //   enableDrag: true,
              //   isDismissible: true,
              //   showDragHandle: true,
              //   // isScrollControlled: true,
              //   scrollControlDisabledMaxHeightRatio: 0.75,
              //   // useSafeArea: true,
              //   builder: (context) {
              //     return FormattingBottomSheet(
              //       formattingSetting: formattingSetting,
              //     );
              //   },
              // ).then((_) {
              //   setState(() {});
              // });
            },
            icon: Icon(
              (Platform.isIOS || Platform.isMacOS)
                  ? CupertinoIcons.textformat
                  : Icons.text_format_rounded,
            ),
          ),
        ],
        flexibleSpace: const BlurBar(),
      ),
      extendBodyBehindAppBar: !showWebView,
      extendBody: !showWebView,
      bottomNavigationBar:
          widget.index != null && widget.articleIDs != null
              ? ArticleBottomButtons(
                articleNotifier: currentArticleNotifier,
                formattingSetting: formattingSetting,
                showWebView: showWebView,
                changeShowWebView: () {
                  setState(() {
                    showWebView = !showWebView;
                  });
                },
              )
              : null,
      body:
          widget.index != null && widget.articleIDs != null
              ? ArticleViewPages(
                controller: _pageController,
                onPageChanged: (value) => _onPageChanged(value),
                articleIDs: widget.articleIDs!,
                showWebView: showWebView,
                formattingSetting: formattingSetting,
              )
              : const Center(child: Text("Please select an article")),
    );
  }
}

class ArticleViewPages extends StatefulWidget {
  const ArticleViewPages({
    super.key,
    required this.articleIDs,
    required this.controller,
    required this.onPageChanged,
    required this.showWebView,
    required this.formattingSetting,
  });
  final Set<String> articleIDs;
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
      itemCount: widget.articleIDs.length,
      itemBuilder: (context, index) {
        return FutureBuilder<Article>(
          future: loadArticle(
            widget.articleIDs.elementAt(index),
            Api.of(context).account!.id,
          ),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return ArticlePage(
                key: ValueKey("${snapshot.data}${widget.showWebView}"),
                subscription:
                    Api.of(context).subscriptions[snapshot.data!.subID]!,
                article: snapshot.data!,
                showWebView: widget.showWebView,
                formattingSetting: widget.formattingSetting,
              );
            } else {
              return const Center(
                child: SizedBox(
                  height: 48,
                  width: 48,
                  child: FittedBox(child: CircularProgressIndicator.adaptive()),
                ),
              );
            }
          },
        );
      },
    );
  }
}

class ArticleCount extends StatelessWidget {
  const ArticleCount({
    super.key,
    required this.currentArticleNotifier,
    required this.articleIDS,
  });

  final ValueNotifier<Article?> currentArticleNotifier;
  final Set<String> articleIDS;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentArticleNotifier,
      builder: (context, value, child) {
        if (value != null) {
          return Text(
            "${articleIDS.toList().indexOf(value.articleID) + 1} / ${articleIDS.length}",
            style: TextStyle(fontWeight: FontWeight.bold),
          );
        } else {
          return const Text("");
        }
      },
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

  final Article article;
  final Subscription subscription;
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
        url: widget.article.url,
        title: widget.article.title,
        content: widget.article.content,
        feedTitle: Api.of(context).filteredTitle,
        timePublished: widget.article.published,
        subName: widget.subscription.title,
        iconUrl: Api.of(context).getIconUrl(widget.subscription.iconUrl),
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
  late final WebViewController webViewController =
      WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(widget.url));

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: webViewController,
      gestureRecognizers: {
        Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer()),
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
  ".bmp",
];

class ArticleTextWidget extends StatelessWidget {
  ArticleTextWidget({
    super.key,
    required this.url,
    required this.title,
    required this.content,
    this.iconUrl,
    required this.subName,
    this.feedTitle,
    required this.timePublished,
    required this.formattingSetting,
  });
  final String url;
  final String title;
  final String content;
  final String? iconUrl;
  final String subName;
  final String? feedTitle;
  final int timePublished;
  final FormattingSetting formattingSetting;
  final ScrollController scrollController = ScrollController();

  void showLinkMenu(BuildContext context, String link, String? imgUrl) {
    showDialog(
      context: context,
      builder: (context) {
        Widget? image;
        if (imgExtensions.any((ext) => link.toLowerCase().endsWith(ext))) {
          image = CachedNetworkImage(imageUrl: link, width: 164, height: 164);
        }
        return AlertDialog.adaptive(
          icon: image,
          title: Text(
            link,
            textScaler: const TextScaler.linear(0.75),
            // style: TextStyle(color: Colors.white60),
          ),
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.hardEdge,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                AdaptiveListTile(
                  title: "Open in browser",
                  trailing: Icon(
                    (Platform.isIOS || Platform.isMacOS)
                        ? CupertinoIcons.globe
                        : Icons.public_rounded,
                  ),
                  onTap: () {
                    launchUrl(Uri.parse(link));
                    Navigator.pop(context);
                  },
                ),
                AdaptiveListTile(
                  title: "Share Link",
                  trailing: Icon(
                    (Platform.isIOS || Platform.isMacOS)
                        ? CupertinoIcons.share
                        : Icons.share_rounded,
                  ),
                  onTap: () {
                    try {
                      final box = context.findRenderObject() as RenderBox?;
                      SharePlus.instance.share(
                        ShareParams(
                          uri: Uri.parse(link),
                          sharePositionOrigin:
                              box!.localToGlobal(Offset.zero) & box.size,
                        ),
                      );
                    } catch (e) {
                      debugPrint(e.toString());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString(), maxLines: 3)),
                      );
                    }
                    // Navigator.pop(context);
                  },
                ),
                if (imgUrl != null) const Divider(),
                if (imgUrl != null)
                  AdaptiveListTile(
                    title: "Open image in browser",
                    trailing: const Icon(Icons.image_search_rounded),
                    onTap: () {
                      launchUrl(Uri.parse(imgUrl));
                      Navigator.pop(context);
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
      backgroundColor: Colors.black54,
      swipeDismissible: true,
      doubleTapZoomable: true,
      immersive: false,
      useSafeArea: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle urlStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary,
      decoration: TextDecoration.underline,
    );
    return ListenableBuilder(
      listenable: formattingSetting,
      builder: (context, child) {
        return AnimatedDefaultTextStyle(
          style: TextStyle(
            fontFamily: formattingSetting.font,
            // fontFamilyFallback: [formattingSetting.fonts[0]],
            fontSize: formattingSetting.fontSize,
            wordSpacing: formattingSetting.wordSpacing,
            height: formattingSetting.lineHeight,
          ),
          duration: const Duration(milliseconds: 100),
          child: child!,
        );
      },
      child: SelectionArea(
        child: Scrollbar(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              controller: scrollController,
              children: [
                Text.rich(
                  textScaler: TextScaler.linear(0.8),
                  TextSpan(
                    children: [
                      WidgetSpan(
                        child: Builder(
                          builder: (context) {
                            return GestureDetector(
                              onLongPress: () {
                                showLinkMenu(context, url, null);
                              },
                              onTap: () {
                                launchUrl(Uri.parse(url));
                              },
                              child: Text(
                                title,
                                textScaler: TextScaler.linear(1.45),
                                style: urlStyle,
                              ),
                            );
                          },
                        ),
                      ),
                      TextSpan(
                        text:
                            "\n${getRelativeDate(timePublished)}, ${DateTime.fromMillisecondsSinceEpoch(timePublished * 1000).toString().split(".").first}\n",
                        style: TextStyle(color: Colors.grey),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: CachedNetworkImage(
                          alignment: Alignment.bottomCenter,
                          height: formattingSetting.fontSize * 0.8,
                          width: formattingSetting.fontSize * 0.8,
                          imageUrl: iconUrl ?? "",
                          errorWidget:
                              (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                      TextSpan(
                        text: "  $subName\n",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                HtmlWidget(
                  content,
                  // buildAsync: true,
                  enableCaching: false,
                  renderMode: RenderMode.column,
                  onErrorBuilder: (context, element, error) {
                    return Placeholder(child: Text(error.toString()));
                  },
                  customWidgetBuilder: (element) {
                    if (element.localName == "a") {
                      Widget? imgWidget;
                      String? imgUrl;
                      if (element.children.any(
                        (child) => child.localName == "img",
                      )) {
                        for (var child in element.children) {
                          if (child.localName == "img") {
                            imgUrl = child.attributes["src"];
                            imgWidget = ArticleImage(
                              imageUrl: imgUrl ?? "",
                              width: double.tryParse(
                                child.attributes["width"] ?? "",
                              ),
                              height: double.tryParse(
                                child.attributes["height"] ?? "",
                              ),
                            );
                            break;
                          }
                        }
                      }
                      return InlineCustomWidget(
                        child: GestureDetector(
                          onTap: () {
                            launchUrl(Uri.parse(element.attributes["href"]!));
                          },
                          onLongPress: () {
                            showLinkMenu(
                              context,
                              element.attributes["href"]!,
                              imgUrl,
                            );
                          },
                          child:
                              imgWidget ?? Text(element.text, style: urlStyle),
                        ),
                      );
                    } else if (element.localName == "img" &&
                        element.attributes["src"] != null) {
                      return InlineCustomWidget(
                        child: GestureDetector(
                          onTap: () {
                            showImage(context, element.attributes["src"]!);
                          },
                          onLongPress: () {
                            showLinkMenu(
                              context,
                              element.attributes["src"]!,
                              null,
                            );
                          },
                          child: ArticleImage(
                            imageUrl: element.attributes["src"]!,
                            width: double.tryParse(
                              element.attributes["width"] ?? "",
                            ),
                            height: double.tryParse(
                              element.attributes["height"] ?? "",
                            ),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

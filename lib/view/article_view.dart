import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fresh_reader/util/screen_size.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../api/data_types.dart';
import '../api/provider.dart';
import '../util/date.dart';
import '../util/formatting_setting.dart';
import '../widget/adaptive_list_tile.dart';
import '../widget/article_buttons.dart';
import '../widget/article_image.dart';
import '../widget/transparent_container.dart';

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
  late final PageController pageController = PageController(
    initialPage: widget.index ?? 0,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Api.of(context).selectedIndex != null &&
        pageController.hasClients &&
        Api.of(context).selectedIndex != pageController.page!.toInt() &&
        pageController.page!.toInt() == pageController.page) {
      final int index = Api.of(context).selectedIndex!;
      Future.microtask(() {
        pageController.jumpToPage(index);
      });
    }
  }

  void onPageChanged(int page) {
    if (Preferences.of(context).markReadWhenOpen) {
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
              setState(() {
                showWebView = !showWebView;
              });
            },
            icon: Icon(
              (Platform.isIOS || Platform.isMacOS)
                  ? CupertinoIcons.globe
                  : Icons.public,
              color: showWebView ? Theme.of(context).colorScheme.primary : null,
            ),
            tooltip: showWebView ? "Article" : "Web",
          ),
        ],
        flexibleSpace: const TransparentContainer(hasBorder: false),
      ),
      extendBodyBehindAppBar: !showWebView,
      extendBody: !showWebView,
      bottomNavigationBar:
          widget.index != null && widget.articleIDs != null && !showWebView
              ? ArticleBottomButtons(articleNotifier: currentArticleNotifier)
              : null,
      body:
          widget.index != null && widget.articleIDs != null
              ? ArticleViewPages(
                articleIDs: widget.articleIDs ?? {},
                pageController: pageController,
                onPageChanged: (page) => onPageChanged(page),
                initialIndex: widget.index,
                showWebView: showWebView,
              )
              : const Center(child: Text("Please select an article")),
    );
  }
}

class ArticleViewPages extends StatefulWidget {
  const ArticleViewPages({
    super.key,
    required this.articleIDs,
    required this.showWebView,
    required this.onPageChanged,
    required this.pageController,
    required this.initialIndex,
  });
  final Set<String> articleIDs;
  final bool showWebView;
  final Function(int) onPageChanged;
  final PageController pageController;
  final int? initialIndex;

  @override
  State<ArticleViewPages> createState() => _ArticleViewPagesState();
}

class _ArticleViewPagesState extends State<ArticleViewPages> {
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      allowImplicitScrolling: true,
      controller: widget.pageController,
      onPageChanged: (value) => widget.onPageChanged(value),
      itemCount: widget.articleIDs.length,
      itemBuilder: (context, index) {
        return FutureBuilder<Article>(
          future:
              Api.of(context).filteredArticles != null &&
                      Api.of(context).filteredArticles!.containsKey(
                        widget.articleIDs.elementAt(index),
                      )
                  ? Api.of(context).getArticleWithContent(
                    Api.of(context).filteredArticles![widget.articleIDs
                        .elementAt(index)]!,
                    Api.of(context).account!.id,
                  )
                  : null,
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return ArticlePage(
                key: ValueKey("${snapshot.data}${widget.showWebView}"),
                subscription:
                    Api.of(context).subscriptions[snapshot.data!.subID]!,
                article: snapshot.data!,
                showWebView: widget.showWebView,
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
  });

  final Article article;
  final Subscription subscription;
  final bool showWebView;

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
        ..loadRequest(Uri.parse(widget.url))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (newProgress) {
              if (mounted) {
                setState(() {
                  progress = newProgress;
                });
              }
            },
          ),
        );

  int progress = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 2,
          child:
              progress < 100
                  ? LinearProgressIndicator(value: progress / 100.0)
                  : null,
        ),
        Expanded(
          child: WebViewWidget(
            controller: webViewController,
            gestureRecognizers: {
              Factory<LongPressGestureRecognizer>(
                () => LongPressGestureRecognizer(),
              ),
              Factory<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer(),
              ),
            },
          ),
        ),
        ArticleWebViewButtons(webViewController: webViewController),
      ],
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
  });
  final String url;
  final String title;
  final String content;
  final String? iconUrl;
  final String subName;
  final String? feedTitle;
  final int timePublished;
  final ScrollController scrollController = ScrollController();

  void showLinkMenu(BuildContext context, String link, String? imgUrl) {
    showDialog(
      context: context,
      builder: (context) {
        Widget? image;
        if (imgExtensions.any((ext) => link.toLowerCase().endsWith(ext))) {
          image = ArticleImage(imageUrl: link, width: 164.0, height: 164.0);
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
                    Navigator.pop(context);
                    launchUrl(Uri.parse(link));
                  },
                ),
                Builder(
                  builder: (context) {
                    return AdaptiveListTile(
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
                    );
                  },
                ),
                if (imgUrl != null) const Divider(),
                if (imgUrl != null)
                  AdaptiveListTile(
                    title: "Preview Image",
                    trailing: const Icon(Icons.image),
                    onTap: () {
                      Navigator.pop(context);
                      showImage(context, imgUrl, null, null);
                    },
                  ),
                if (imgUrl != null)
                  AdaptiveListTile(
                    title: "Open image in browser",
                    trailing: const Icon(Icons.image_search_rounded),
                    onTap: () {
                      Navigator.pop(context);
                      launchUrl(Uri.parse(imgUrl));
                    },
                  ),
                if (imgUrl != null)
                  AdaptiveListTile(
                    title: "Open image link",
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
                            uri: Uri.parse(imgUrl),
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
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showImage(
    BuildContext context,
    String url,
    double? width,
    double? height,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      // fullscreenDialog: true,
      // useSafeArea: false,
      builder: (context) {
        return Stack(
          children: [
            ExtendedImageGesturePageView(
              canScrollPage: (gestureDetails) => false,
              children: [
                ExtendedImageSlidePage(
                  slideAxis: SlideAxis.both,
                  slideType: SlideType.onlyImage,
                  child: ArticleImage(
                    imageUrl: url,
                    width: width,
                    height: height,
                    isViewer: true,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close),
              tooltip: "Close",
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle urlStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary,
      decoration: TextDecoration.underline,
    );
    return AnimatedDefaultTextStyle(
      style: TextStyle(
        fontFamily: Preferences.of(context).font,
        // fontFamilyFallback: [formattingSetting.fonts[0]],
        fontSize: Preferences.of(context).fontSize,
        wordSpacing: Preferences.of(context).wordSpacing,
        height: Preferences.of(context).lineHeight,
      ),
      duration: const Duration(milliseconds: 100),
      child: SelectionArea(
        child: Scrollbar(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(height: MediaQuery.paddingOf(context).top + 16.0),
                    Text.rich(
                      textScaler: TextScaler.linear(0.9),
                      TextSpan(
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Builder(
                              builder: (context) {
                                double? size =
                                    DefaultTextStyle.of(context).style.fontSize;
                                return ArticleImage(
                                  imageUrl: iconUrl ?? "",
                                  height: size,
                                  width: size,
                                  onError:
                                      (error) => Icon(Icons.error, size: size),
                                );
                              },
                            ),
                          ),
                          TextSpan(
                            text: " $subName",
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onLongPress: () {
                        showLinkMenu(context, url, null);
                      },
                      onTap: () {
                        launchUrl(Uri.parse(url));
                      },
                      child: Text(
                        title,
                        textScaler: TextScaler.linear(1.15),
                        style: urlStyle,
                      ),
                    ),
                    Text(
                      getFormattedDate(timePublished),
                      style: TextStyle(color: Colors.grey.shade500),
                      textScaler: TextScaler.linear(0.8),
                    ),
                    SizedBox(height: 8.0),
                  ]),
                ),
                HtmlWidget(
                  content,
                  buildAsync: false,
                  enableCaching: true,
                  renderMode: RenderMode.sliverList,
                  onErrorBuilder: (context, element, error) {
                    return Text(error.toString());
                  },
                  customStylesBuilder: (element) {
                    return {"width": "100%"};
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
                            showImage(
                              context,
                              element.attributes["src"]!,
                              double.tryParse(
                                element.attributes["width"] ?? "",
                              ),
                              double.tryParse(
                                element.attributes["height"] ?? "",
                              ),
                            );
                          },
                          onLongPress: () {
                            showLinkMenu(
                              context,
                              element.attributes["src"]!,
                              element.attributes["src"]!,
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
                SliverPadding(
                  padding: EdgeInsetsGeometry.only(
                    bottom: MediaQuery.paddingOf(context).bottom + 16.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

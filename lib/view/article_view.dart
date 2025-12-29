import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../api/data.dart';
import '../api/data_types.dart';
import '../util/date.dart';
import '../api/preferences.dart';
import '../util/screen_size.dart';
import '../util/share.dart';
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

class _ArticleViewState extends State<ArticleView> {
  bool showWebView = false;
  late final PageController pageController = PageController(
    initialPage: widget.index ?? 0,
  );

  @override
  void initState() {
    super.initState();
    context.read<DataProvider>().pageController = pageController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ArticleCount(length: widget.articleIDs?.length ?? 0),
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
      bottomNavigationBar: widget.index != null && widget.articleIDs != null
          ? ArticleBottomButtons()
          : null,
      body: widget.index != null && widget.articleIDs != null
          ? ArticleViewPages(
              articleIDs: widget.articleIDs ?? {},
              pageController: pageController,
              initialIndex: widget.index,
              showWebView: showWebView,
            )
          : const Center(child: Text("Please select an article")),
    );
  }
}

class ArticleViewPages extends StatelessWidget {
  const ArticleViewPages({
    super.key,
    required this.articleIDs,
    required this.showWebView,
    required this.pageController,
    required this.initialIndex,
  });
  final Set<String> articleIDs;
  final bool showWebView;
  final PageController pageController;
  final int? initialIndex;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      key: const Key("articlePageView"),
      allowImplicitScrolling: true,
      controller: pageController,
      onPageChanged: (page) {
        context.read<DataProvider>().setSelectedIndex(
          page,
          true,
          !context.read<Preferences>().markReadWhenOpen,
        );
        if (context.read<Preferences>().markReadWhenOpen) {
          context.read<DataProvider>().setRead(
            articleIDs.elementAt(page),
            context
                .read<DataProvider>()
                .articlesMetaData[context
                    .read<DataProvider>()
                    .searchResults![page]]!
                .$2,
            true,
          );
        }
      },
      itemCount: articleIDs.length,
      itemBuilder: (context, index) {
        return ArticlePage(
          articleID: articleIDs.elementAt(index),
          showWebView: showWebView,
        );
      },
    );
  }
}

class ArticleCount extends StatelessWidget {
  const ArticleCount({super.key, required this.length});
  final int length;

  @override
  Widget build(BuildContext context) {
    int? page = context.select<DataProvider, int?>((a) => a.selectedIndex);
    if (page != null) {
      return Text("${page + 1} / $length");
    } else {
      return const Text("");
    }
  }
}

class ArticlePage extends StatefulWidget {
  const ArticlePage({
    super.key,
    required this.articleID,
    required this.showWebView,
  });
  final String articleID;
  final bool showWebView;

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  Future<Article>? article;

  @override
  Widget build(BuildContext context) {
    article ??= context.read<DataProvider>().getArticleWithContent(
      widget.articleID,
    );
    return FutureBuilder<Article>(
      key: ValueKey("future_${widget.articleID}"),
      future: article,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          if (widget.showWebView) {
            return ArticleWebWidget(
              key: ValueKey(snapshot.data!.url),
              url: snapshot.data!.url,
            );
          } else {
            return ArticleTextWidget(
              key: ValueKey("text_${snapshot.data!.articleID}"),
              url: snapshot.data!.url,
              title: snapshot.data!.title,
              content: snapshot.data!.content,
              timePublished: snapshot.data!.published,
              subName: context
                  .read<DataProvider>()
                  .subscriptions[snapshot.data!.subID]!
                  .title,
              iconUrl: context.read<DataProvider>().getIconUrl(
                context
                    .read<DataProvider>()
                    .subscriptions[snapshot.data!.subID]!
                    .iconUrl,
              ),
            );
          }
        } else {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
      },
    );
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
    return Column(
      children: [
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
    required this.timePublished,
  });
  final String url;
  final String title;
  final String content;
  final String? iconUrl;
  final String subName;
  final int timePublished;
  final ScrollController scrollController = ScrollController();

  void showLinkMenu(BuildContext context, String link, String? imgUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: ListTile(
            title: Text(link),
            trailing:
                imgExtensions.any((ext) => link.toLowerCase().endsWith(ext))
                ? ArticleImage(imageUrl: link)
                : imgUrl != null
                ? ArticleImage(imageUrl: imgUrl)
                : null,
          ),
          titlePadding: EdgeInsetsGeometry.only(top: 8.0),
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.hardEdge,
          children: [
            const Divider(),
            ListTile(
              dense: true,
              title: Text("Open in browser"),
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
                return ListTile(
                  dense: true,
                  title: Text("Share Link"),
                  trailing: Icon(
                    (Platform.isIOS || Platform.isMacOS)
                        ? CupertinoIcons.share
                        : Icons.share,
                  ),
                  onTap: () {
                    shareLink(context, link, null);
                  },
                );
              },
            ),
            ...(imgUrl == null
                ? []
                : [
                    const Divider(),
                    ListTile(
                      dense: true,
                      title: Text("Preview Image"),
                      trailing: const Icon(Icons.image_outlined),
                      onTap: () {
                        Navigator.pop(context);
                        showImage(context, imgUrl, null, null);
                      },
                    ),
                    ListTile(
                      dense: true,
                      title: Text("Open image in browser"),
                      trailing: const Icon(Icons.image_search),
                      onTap: () {
                        Navigator.pop(context);
                        launchUrl(Uri.parse(imgUrl));
                      },
                    ),
                    ListTile(
                      dense: true,
                      title: Text("Share image link"),
                      trailing: Icon(
                        (Platform.isIOS || Platform.isMacOS)
                            ? CupertinoIcons.share
                            : Icons.share,
                      ),
                      onTap: () {
                        shareLink(context, imgUrl, null);
                      },
                    ),
                  ]),
          ],
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
    TextStyle urlStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary,
      decoration: TextDecoration.underline,
    );
    return AnimatedDefaultTextStyle(
      style: TextStyle(
        fontFamily: context.select<Preferences, String>((a) => a.font),
        // fontFamilyFallback: [formattingSetting.fonts[0]],
        fontSize: context.select<Preferences, double>((a) => a.fontSize),
        wordSpacing: context.select<Preferences, double>((a) => a.wordSpacing),
        height: context.select<Preferences, double>((a) => a.lineHeight),
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
                                double? size = DefaultTextStyle.of(
                                  context,
                                ).style.fontSize;
                                return ArticleImage(
                                  imageUrl: iconUrl ?? "",
                                  height: size,
                                  width: size,
                                  onError: (error) =>
                                      Icon(Icons.error, size: size),
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
                      String href = element.attributes["href"]!;
                      return InlineCustomWidget(
                        child: GestureDetector(
                          onTap: () {
                            launchUrl(Uri.parse(href));
                          },
                          onLongPress: () {
                            showLinkMenu(context, href, imgUrl);
                          },
                          child:
                              imgWidget ?? Text(element.text, style: urlStyle),
                        ),
                      );
                    } else if (element.localName == "img" &&
                        element.attributes["src"] != null) {
                      String src = element.attributes["src"]!;
                      double? width = double.tryParse(
                        element.attributes["width"] ?? "",
                      );
                      double? height = double.tryParse(
                        element.attributes["height"] ?? "",
                      );
                      return InlineCustomWidget(
                        child: GestureDetector(
                          onTap: () {
                            showImage(context, src, width, height);
                          },
                          onLongPress: () {
                            showLinkMenu(context, src, src);
                          },
                          child: ArticleImage(
                            imageUrl: src,
                            width: width,
                            height: height,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
                SliverPadding(
                  padding: EdgeInsetsGeometry.only(
                    bottom:
                        (MediaQuery.maybePaddingOf(context)?.bottom ?? 0.0) +
                        16.0,
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

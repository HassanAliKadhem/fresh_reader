import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fresh_reader/widget/image_viewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../api/api.dart';
import '../api/data_types.dart';
import '../util/formatting_setting.dart';
import '../widget/blur_bar.dart';

class ArticleView extends StatefulWidget {
  const ArticleView({
    super.key,
    required this.index,
    required this.articleIDs,
  });
  final int? index;
  final Set<String>? articleIDs;
  @override
  State<ArticleView> createState() => _ArticleViewState();
}

ValueNotifier<Article?> currentArticleNotifier = ValueNotifier<Article?>(null);

class _ArticleViewState extends State<ArticleView> {
  bool showWebView = false;
  final FormattingSetting formattingSetting = FormattingSetting();
  late final PageController _pageController =
      PageController(initialPage: widget.index ?? 0);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Api.of(context).filteredIndex != null &&
        _pageController.hasClients &&
        Api.of(context).filteredIndex != _pageController.page!.toInt()) {
      Future.microtask(() {
        _pageController.jumpToPage(Api.of(context).filteredIndex!);
      });
    }
  }

  void _onPageChanged(int page) {
    Api.of(context).filteredIndex = page;
    currentArticleNotifier.value =
        Api.of(context).filteredArticles![widget.articleIDs?.elementAt(page)];
    Api.of(context).setRead(currentArticleNotifier.value!.id,
        currentArticleNotifier.value!.subID, true);
    currentArticleNotifier.value!.read = true;
  }

  void _onShare(BuildContext context) {
    if (currentArticleNotifier.value != null) {
      try {
        Share.shareUri(Uri.parse(currentArticleNotifier.value!.url));
      } catch (e) {
        final box = context.findRenderObject() as RenderBox?;
        Share.share(
          currentArticleNotifier.value!.url,
          subject: currentArticleNotifier.value!.title,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        );
        debugPrint(e.toString());
      }
    }
  }

  List<Widget> bottomButtons() {
    return [
      SetUnreadButton(
        articleNotifier: currentArticleNotifier,
      ),
      SetStarButton(
        articleNotifier: currentArticleNotifier,
      ),
      Builder(builder: (context) {
        return IconButton(
          onPressed: () {
            _onShare(context);
          },
          tooltip: "Share",
          icon: const Icon(
            Icons.share,
          ),
        );
      }),
      IconButton(
        onPressed: () {
          if (currentArticleNotifier.value != null) {
            launchUrl(
              Uri.parse(currentArticleNotifier.value!.url),
              mode: LaunchMode.inAppBrowserView,
            );
          }
        },
        tooltip: "Open In Browser",
        icon: const Icon(
          Icons.open_in_browser,
        ),
      ),
      IconButton(
        onPressed: () {
          setState(() {
            showWebView = !showWebView;
          });
        },
        tooltip: showWebView ? "Article View" : "Web View",
        icon: Icon(
          showWebView ? Icons.article : Icons.public,
        ),
      ),
      Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.text_format),
            tooltip: "Text Formatting",
            onPressed: showWebView
                ? null
                : () {
                    showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      builder: (context) {
                        return FormattingSheet(
                            formattingSetting: formattingSetting);
                      },
                      elevation: 1,
                    );
                  },
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ArticleCount(
          currentArticleNotifier: currentArticleNotifier,
          articleIDS: widget.articleIDs ?? {},
        ),
        actions:
            screenSizeOf(context) == ScreenSize.small ? null : bottomButtons(),
        flexibleSpace: const BlurBar(hasBorder: false),
      ),
      extendBodyBehindAppBar: !showWebView,
      extendBody: !showWebView,
      bottomNavigationBar: screenSizeOf(context) == ScreenSize.small
          ? BlurBar(
              child: SafeArea(
                child: IconButtonTheme(
                  data: const IconButtonThemeData(
                    style: ButtonStyle(
                      padding: WidgetStatePropertyAll(
                        EdgeInsets.all(12.0),
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: bottomButtons(),
                  ),
                ),
              ),
            )
          : null,
      body: widget.index != null && widget.articleIDs != null
          ? PageView.builder(
              allowImplicitScrolling: true,
              controller: _pageController,
              onPageChanged: (value) => _onPageChanged(value),
              itemCount: widget.articleIDs!.length,
              itemBuilder: (context, index) {
                return FutureBuilder(
                  future: Api.of(context)
                      .db!
                      .loadArticle(widget.articleIDs!.elementAt(index), true),
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      return ArticlePage(
                        key: ValueKey("${snapshot.data}$showWebView"),
                        article: snapshot.data!,
                        showWebView: showWebView,
                        formattingSetting: formattingSetting,
                      );
                    } else {
                      return const Center(
                        child: SizedBox(
                          height: 48,
                          width: 48,
                          child: FittedBox(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            )
          : const SizedBox(),
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
              "${articleIDS.toList().indexOf(value.id) + 1} / ${articleIDS.length}");
        } else {
          return Text("1 / ${articleIDS.length}");
        }
      },
    );
  }
}

class FormattingSheet extends StatelessWidget {
  const FormattingSheet({
    super.key,
    required this.formattingSetting,
  });

  final FormattingSetting formattingSetting;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: formattingSetting,
        builder: (context, child) {
          return DraggableScrollableSheet(
            expand: false,
            builder: (context, scrollController) => ListView(
              controller: scrollController,
              children: [
                const ListTile(
                  title: Text(
                    "Text Formatting",
                    textScaler: TextScaler.linear(1.25),
                  ),
                ),
                ListTile(
                  title: const Text("Font Size"),
                  subtitle: Slider.adaptive(
                    value: formattingSetting.fontSize,
                    min: 10,
                    max: 30,
                    divisions: 20,
                    label: formattingSetting.fontSize.toString(),
                    onChanged: (value) {
                      formattingSetting.setSize(value);
                    },
                  ),
                ),
                ListTile(
                  title: const Text("Line Height"),
                  subtitle: Slider.adaptive(
                    value: formattingSetting.lineHeight,
                    min: 1.0,
                    max: 2.0,
                    divisions: 10,
                    label: formattingSetting.lineHeight.toString(),
                    onChanged: (value) {
                      formattingSetting.setLineHeight(value);
                    },
                  ),
                ),
                ListTile(
                  title: const Text("Word Spacing"),
                  subtitle: Slider.adaptive(
                    value: formattingSetting.wordSpacing,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: formattingSetting.wordSpacing.toString(),
                    onChanged: (value) {
                      formattingSetting.setSpacing(value);
                    },
                  ),
                ),
                const ListTile(
                  title: Text("Font"),
                ),
                ...formattingSetting.fonts.map((font) => RadioListTile.adaptive(
                      groupValue: formattingSetting.font,
                      value: font,
                      dense: true,
                      title: Text(font),
                      onChanged: (value) {
                        formattingSetting.setFontFamily(font);
                      },
                    ))
              ],
            ),
          );
        });
  }
}

class ArticlePage extends StatefulWidget {
  const ArticlePage({
    super.key,
    required this.article,
    required this.showWebView,
    required this.formattingSetting,
  });

  final Article article;
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
        feedTitle: Api.of(context).subs[widget.article.subID]?.title,
        timePublished: widget.article.published,
        subName: Api.of(context).subs[widget.article.subID]?.title ?? "",
        iconUrl: Api.of(context).getIconUrl(widget.article.subID),
        formattingSetting: widget.formattingSetting,
      );
    }
  }
}

class SetUnreadButton extends StatefulWidget {
  const SetUnreadButton({super.key, required this.articleNotifier});
  final ValueNotifier<Article?> articleNotifier;

  @override
  State<SetUnreadButton> createState() => _SetUnreadButtonState();
}

class _SetUnreadButtonState extends State<SetUnreadButton> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.articleNotifier,
      builder: (context, value, child) {
        bool isRead = value?.read ?? true;
        return IconButton(
          onPressed: () {
            if (value != null) {
              value.read = !isRead;
              setState(() {
                Api.of(context).setRead(value.id, value.subID, !isRead);
              });
            }
          },
          tooltip: isRead ? "Set Unread" : "Set Read",
          icon: Icon(
            isRead ? Icons.circle_outlined : Icons.circle_rounded,
          ),
        );
      },
    );
  }
}

class SetStarButton extends StatefulWidget {
  const SetStarButton({super.key, required this.articleNotifier});
  final ValueNotifier<Article?> articleNotifier;

  @override
  State<SetStarButton> createState() => _SetStarButtonState();
}

class _SetStarButtonState extends State<SetStarButton> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.articleNotifier,
      builder: (context, value, child) {
        bool isStarred = value?.starred ?? false;
        return IconButton(
          onPressed: () {
            value!.starred = !isStarred;
            setState(() {
              Api.of(context).setStarred(value.id, value.subID, !isStarred);
            });
          },
          tooltip: isStarred ? "UnFavorite" : "Favorite",
          icon: Icon(isStarred ? Icons.star : Icons.star_border),
        );
      },
    );
  }
}

class ArticleWebWidget extends StatelessWidget {
  ArticleWebWidget({super.key, required this.url});
  final String url;
  late final WebViewController webViewController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse(url));

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

  void showImage(BuildContext context, String title, String url) {
    showDialog(
      context: context,
      builder: (context) {
        return ImageViewer(
          image: CachedNetworkImage(
            imageUrl: url,
          ),
          text: title,
          url: url,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String articleContent = content.replaceAll("<a", "<a class=\"link\"");
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
                if (getFirstImage(content) != null)
                  Container(
                    foregroundDecoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                          Colors.black,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.7, 0.85, 1],
                      ),
                    ),
                    child: GestureDetector(
                        onTap: () =>
                            showImage(context, "", getFirstImage(content)!),
                        child: CachedNetworkImage(
                            imageUrl: getFirstImage(content)!)),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: kToolbarHeight + 24),
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
                              title,
                              maxLines: 2,
                              textScaler: const TextScaler.linear(1.5),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                shadows: <Shadow>[
                                  Shadow(
                                    offset: Offset.zero,
                                    blurRadius: 5.0,
                                    color: Colors.black87,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "${getRelativeDate(timePublished)}, ${DateTime.fromMillisecondsSinceEpoch(timePublished * 1000).toString().split(".").first}",
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
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.start,
                children: [
                  CachedNetworkImage(
                    height: 48,
                    width: 48,
                    imageUrl: iconUrl ?? "",
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                  Text(
                    "  $subName",
                    textScaler: const TextScaler.linear(1.3),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: HtmlWidget(
                articleContent,
                buildAsync: true,
                enableCaching: true,
                // renderMode: ListViewMode(
                //   padding: EdgeInsets.only(
                //     left: 16.0,
                //     right: 16.0,
                //     top: MediaQuery.of(context).padding.top + 16.0,
                //     bottom: MediaQuery.of(context).padding.bottom + 16.0,
                //   ),
                // ),
                onErrorBuilder: (context, element, error) {
                  return Placeholder(
                    child: Text(error.toString()),
                  );
                },
                onTapImage: (p0) {
                  if (p0.sources.isNotEmpty) {
                    showImage(
                        context,
                        "${p0.alt != null ? "${p0.alt}, " : ""}${p0.title}",
                        p0.sources.first.url);
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
                          // if (isImg) {
                          //   showImage(
                          //       context,
                          //       "${element.attributes["alt"] != null ? "${element.attributes["alt"]}, " : ""}${element.text}",
                          //       element.attributes["href"]!);
                          // } else {
                          showLinkMenu(context, element.attributes["href"]!);
                          // }
                        },
                        onTap: () {
                          // if (isImg) {
                          //   showImage(
                          //       context,
                          //       "${element.attributes["alt"] != null ? "${element.attributes["alt"]}, " : ""}${element.text}",
                          //       element.attributes["href"]!);
                          // } else {
                          launchUrl(Uri.parse(element.attributes["href"]!));
                          // }
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

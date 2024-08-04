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
import '../util/formatting_setting.dart';
import '../widget/blur_bar.dart';

class ArticleView extends StatefulWidget {
  const ArticleView({
    super.key,
    required this.index,
    required this.articleIDs,
  });
  final int index;
  final Set<String> articleIDs;
  @override
  State<ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  bool showWebView = false;
  final FormattingSetting formattingSetting = FormattingSetting();
  ValueNotifier<Article?> currentArticleNotifier =
      ValueNotifier<Article?>(null);

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

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => _onPageChanged(Api.of(context).filteredIndex!),
    );
  }

  void _onPageChanged(int page) {
    Api.of(context)
        .db!
        .loadArticle(widget.articleIDs.elementAt(page))
        .then((article) {
      currentArticleNotifier.value = article;
      Api.of(context).setRead(article.id, article.subID, true);
      currentArticleNotifier.value!.read = true;
    });
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
          articleIDS: widget.articleIDs,
        ),
        actions:
            screenSizeOf(context) == ScreenSize.small ? null : bottomButtons(),
        flexibleSpace: const BlurBar(),
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
      body: PageView.builder(
        allowImplicitScrolling: true,
        controller: PageController(initialPage: widget.index),
        onPageChanged: (value) => _onPageChanged(value),
        itemCount: widget.articleIDs.length,
        itemBuilder: (context, index) {
          return FutureBuilder(
            future: Api.of(context)
                .db!
                .loadArticle(widget.articleIDs.elementAt(index)),
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
      ),
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
                ...formattingSetting.fonts
                    .map((font) => RadioListTile.adaptive(
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
  void showLinkMenu(BuildContext context, String link) {
    showDialog(
      context: context,
      builder: (context) {
        Widget? image;
        if (link.endsWith(".JPG") ||
            link.endsWith(".jpg") ||
            link.endsWith(".jpeg") ||
            link.endsWith(".png")) {
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

  void showImage(BuildContext context, ImageMetadata imageMetaData) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black38,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: imageMetaData.sources.first.url,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            bottomNavigationBar: BlurBar(
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          "${imageMetaData.title ?? ""}${(imageMetaData.alt != null && imageMetaData.alt != "") ? "\n${imageMetaData.alt!}" : ""}"),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Share.shareUri(
                          Uri.parse(imageMetaData.sources.first.url));
                    },
                    icon: const Icon(Icons.share),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  WebViewController webViewController = WebViewController();

  @override
  Widget build(BuildContext context) {
    if (widget.showWebView) {
      webViewController.loadRequest(Uri.parse(widget.article.url));
      webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
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
    } else {
      String content = '''
          <a class="link" href="${widget.article.url}">${widget.article.title}</a>
          <p>
          <img height="16" width="16" src="${Api.of(context).getIconUrl(widget.article.subID)}"/> ${Api.of(context).subs[widget.article.subID]?.title}<br>
          ${getRelativeDate(widget.article.published)}, ${DateTime.fromMillisecondsSinceEpoch(widget.article.published * 1000).toString().split(".").first}
          </p>
          <hr style="color: grey;">
          ${widget.article.content.replaceAll("<a", "<a class=\"link\"")}
          ''';
      return ListenableBuilder(
        listenable: widget.formattingSetting,
        builder: (context, child) {
          return AnimatedDefaultTextStyle(
            style: TextStyle(
              fontFamily: widget.formattingSetting.font,
              fontSize: widget.formattingSetting.fontSize,
              wordSpacing: widget.formattingSetting.wordSpacing,
              height: widget.formattingSetting.lineHeight,
            ),
            duration: const Duration(milliseconds: 100),
            child: child!,
          );
        },
        child: SelectionArea(
          child: HtmlWidget(
            content,
            buildAsync: true,
            enableCaching: true,
            onTapImage: (p0) {
              showImage(context, p0);
            },
            renderMode: ListViewMode(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: MediaQuery.of(context).padding.top + 16.0,
                bottom: MediaQuery.of(context).padding.bottom + 16.0,
              ),
            ),
            onErrorBuilder: (context, element, error) {
              return Placeholder(
                child: Text(error.toString()),
              );
            },
            customWidgetBuilder: (element) {
              if (element.classes.contains("link")) {
                return InlineCustomWidget(
                  child: GestureDetector(
                    onLongPress: () {
                      if (element.attributes["href"] != null) {
                        showLinkMenu(context, element.attributes["href"]!);
                      } else {
                        debugPrint(element.attributes.toString());
                        debugPrint(element.text.toString());
                        debugPrint("No link found");
                      }
                    },
                    onTap: () {
                      if (element.attributes["href"] != null) {
                        launchUrl(Uri.parse(element.attributes["href"]!));
                      } else {
                        debugPrint(element.attributes.toString());
                        debugPrint(element.text.toString());
                        debugPrint("No link found");
                      }
                    },
                    child: Text(
                      element.text,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ),
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

import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api.dart';
import 'bionic.dart';
import 'data_types.dart';

class FormattingSetting extends ChangeNotifier {
  double fontSize = 14.0;
  double wordSpacing = 0.0;
  double lineHeight = 1.5;
  String font = Platform.isAndroid ? "Roboto" : "SF UI Text";
  List<String> fonts = [
    Platform.isAndroid ? "Roboto" : "SF UI Text",
    "Courier",
  ];
  bool isBionic = false;

  void setSize(double newSize) {
    fontSize = newSize;
    notifyListeners();
  }

  void setSpacing(double newSpacing) {
    wordSpacing = newSpacing;
    notifyListeners();
  }

  void setLineHeight(double newHeight) {
    lineHeight = newHeight;
    notifyListeners();
  }

  void setFontFamily(String newFont) {
    font = newFont;
    notifyListeners();
  }

  void setIsBionic(bool newIs) {
    isBionic = newIs;
    notifyListeners();
  }
}

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
  bool showWebView = false;
  final FormattingSetting formattingSetting = FormattingSetting();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index);
    _pageController.addListener(_onPageChanged);
    articleId.value = widget.articles[widget.index].id;
    index.value = widget.index;
  }

  void _onShare(BuildContext context) {
    try {
      Share.shareUri(Uri.parse(widget.articles[index.value].urls.first));
    } catch (e) {
      final box = context.findRenderObject() as RenderBox?;
      Share.share(
        widget.articles[index.value].urls.first,
        subject: widget.articles[index.value].title,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    }
  }

  void _onPageChanged() {
    if (_pageController.page?.round() == _pageController.page &&
        _pageController.page != null) {
      Api.of(context)
          .setRead(widget.articles[_pageController.page!.round()].id, true);
      // setState(() {
      articleId.value = widget.articles[_pageController.page!.round()].id;
      index.value = _pageController.page!.round();
      // });
    }
  }

  List<Widget> bottomButtons() {
    return [
      const UnreadButton(),
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
          launchUrl(
            Uri.parse(widget.articles[index.value].urls.first),
            mode: LaunchMode.inAppBrowserView,
          );
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
                        return ListenableBuilder(
                            listenable: formattingSetting,
                            builder: (context, child) {
                              return DraggableScrollableSheet(
                                expand: false,
                                builder: (context, scrollController) =>
                                    ListView(
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
                                        label: formattingSetting.fontSize
                                            .toString(),
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
                                        label: formattingSetting.lineHeight
                                            .toString(),
                                        onChanged: (value) {
                                          formattingSetting
                                              .setLineHeight(value);
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
                                        label: formattingSetting.wordSpacing
                                            .toString(),
                                        onChanged: (value) {
                                          formattingSetting.setSpacing(value);
                                        },
                                      ),
                                    ),
                                    SwitchListTile.adaptive(
                                      title: const Text("Use Bionic Reading"),
                                      value: formattingSetting.isBionic,
                                      onChanged: (value) =>
                                          formattingSetting.setIsBionic(value),
                                    ),
                                    const ListTile(
                                      title: Text("font"),
                                    ),
                                    ...formattingSetting.fonts
                                        .map((font) => RadioListTile.adaptive(
                                              groupValue:
                                                  formattingSetting.font,
                                              value: font,
                                              dense: true,
                                              title: Text(font),
                                              onChanged: (value) {
                                                formattingSetting
                                                    .setFontFamily(font);
                                              },
                                            ))
                                        .toList()
                                  ],
                                ),
                              );
                            });
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
        title: TitleCounter(length: widget.articles.length),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Theme.of(context).canvasColor.withAlpha(64),
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      // extendBody: true,
      persistentFooterAlignment: AlignmentDirectional.topCenter,
      persistentFooterButtons: bottomButtons(),
      body: ListenableBuilder(
        listenable: formattingSetting,
        builder: (context, child) {
          return AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              wordSpacing: formattingSetting.wordSpacing,
              fontSize: formattingSetting.fontSize,
              height: formattingSetting.lineHeight,
              fontFamily: formattingSetting.font,
            ),
            child: PageView.builder(
              controller: _pageController,
              // onPageChanged: (value) => _onPageChanged(context, value),

              itemCount: widget.articles.length,
              itemBuilder: (context, index) {
                return ArticlePage(
                  article: widget.articles[index],
                  showWebView: showWebView,
                  isBionic: formattingSetting.isBionic,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ArticlePage extends StatelessWidget {
  const ArticlePage({
    super.key,
    required this.article,
    required this.showWebView,
    required this.isBionic,
  });

  final Article article;
  final bool showWebView;
  final bool isBionic;

  @override
  Widget build(BuildContext context) {
    if (showWebView) {
      WebViewController controller = WebViewController();
      controller.loadRequest(Uri.parse(article.urls.first));
      controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      return WebViewWidget(
          controller: controller,
          gestureRecognizers: <Factory<VerticalDragGestureRecognizer>>{
            Factory<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer())
          });
    } else {
      String content =
          "<h2>${article.title}</h2><p>${Api.of(context).subs[article.feedId]?.title}<br>${getRelativeDate(article.published)}, ${DateTime.fromMillisecondsSinceEpoch(article.published * 1000)}</p>${article.content}";
      return SelectionArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: HtmlWidget(
                isBionic ? getBionicContent(content) : content,
                renderMode: const ColumnMode(),
                onTapUrl: (url) {
                  launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.inAppBrowserView,
                  );
                  return true;
                },
              ),
            ),
          ],
        ),
      );
    }
  }
}

ValueNotifier<int> index = ValueNotifier<int>(0);

class TitleCounter extends StatelessWidget {
  const TitleCounter({
    super.key,
    required this.length,
  });

  final int length;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: index,
        builder: (context, value, child) {
          return Text("${value + 1} / $length");
        });
  }
}

ValueNotifier<String> articleId = ValueNotifier<String>("");

class UnreadButton extends StatefulWidget {
  const UnreadButton({super.key});

  @override
  State<UnreadButton> createState() => _UnreadButtonState();
}

class _UnreadButtonState extends State<UnreadButton> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: articleId,
      builder: (context, id, child) {
        return IconButton(
          onPressed: () {
            Api.of(context).setRead(id, !Api.of(context).isRead(id));
            setState(() {});
          },
          tooltip: Api.of(context).isRead(id) ? "Set Unread" : "Set Read",
          icon: Icon(
            Api.of(context).isRead(id)
                ? Icons.circle_outlined
                : Icons.circle_rounded,
          ),
        );
      },
    );
  }
}

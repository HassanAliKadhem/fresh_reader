import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fresh_reader/util/formatting_setting.dart';
import 'package:fresh_reader/view/html_view.dart';
import 'package:fresh_reader/widget/blur_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api.dart';
import '../api/data_types.dart';

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
  bool showWebView = false;
  final FormattingSetting formattingSetting = FormattingSetting();
  late ValueNotifier<int> pageIndexNotifier = ValueNotifier<int>(widget.index);

  void _onShare(BuildContext context) {
    try {
      Share.shareUri(
          Uri.parse(widget.articles[pageIndexNotifier.value].urls.first));
    } catch (e) {
      final box = context.findRenderObject() as RenderBox?;
      Share.share(
        widget.articles[pageIndexNotifier.value].urls.first,
        subject: widget.articles[pageIndexNotifier.value].title,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
      debugPrint(e.toString());
    }
  }

  void _onPageChanged(int page) {
    pageIndexNotifier.value = page;
    Api.of(context).setRead(widget.articles[page].id, true);
  }

  List<Widget> bottomButtons() {
    return [
      SetUnreadButton(
        indexNotifier: pageIndexNotifier,
        articles: widget.articles,
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
          launchUrl(
            Uri.parse(widget.articles[pageIndexNotifier.value].urls.first),
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
          pageIndexNotifier: pageIndexNotifier,
          count: widget.articles.length,
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: bottomButtons(),
                ),
              ),
            )
          : null,
      body: PageView.builder(
        controller: PageController(initialPage: widget.index),
        onPageChanged: (value) => _onPageChanged(value),
        itemCount: widget.articles.length,
        itemBuilder: (context, index) {
          return ArticlePage(
            article: widget.articles[index],
            showWebView: showWebView,
            formattingSetting: formattingSetting,
          );
        },
      ),
    );
  }
}

class ArticleCount extends StatelessWidget {
  const ArticleCount({
    super.key,
    required this.pageIndexNotifier,
    required this.count,
  });

  final ValueNotifier<int> pageIndexNotifier;
  final int count;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: pageIndexNotifier,
      builder: (context, value, child) {
        return Text("${value + 1} / $count");
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
                    .toList()
              ],
            ),
          );
        });
  }
}

class ArticlePage extends StatelessWidget {
  const ArticlePage({
    super.key,
    required this.article,
    required this.showWebView,
    required this.formattingSetting,
  });

  final Article article;
  final bool showWebView;
  final FormattingSetting formattingSetting;

  void showLinkMenu(BuildContext context, String link, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: ListTile(
            title: Text(title),
            subtitle: Text(link),
          ),
          contentPadding: EdgeInsets.all(16.0),
          children: [
            const Divider(),
            ListTile(
                onTap: () {
                  launchUrl(Uri.parse(link));
                },
                title: const Text("Open in browser")),
            ListTile(
                onTap: () {
                  try {
                    Share.shareUri(Uri.parse(link));
                  } catch (e) {
                    final box = context.findRenderObject() as RenderBox?;
                    Share.share(
                      link,
                      subject: title,
                      sharePositionOrigin:
                          box!.localToGlobal(Offset.zero) & box.size,
                    );
                    debugPrint(e.toString());
                  }
                },
                title: const Text("Share")),
          ],
        );
      },
    );
  }

  WidgetSpan LinkSpan(var element, BuildContext context) {
    return WidgetSpan(
      child: GestureDetector(
        onTap: () {
          launchUrl(Uri.parse(element.attributes["href"]!));
        },
        onLongPress: () {
          showLinkMenu(context, element.attributes["href"]!, element.text);
        },
        child: Text(
          element.text,
          style: TextStyle(
              decoration: TextDecoration.underline,
              color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showWebView) {
      WebViewController controller = WebViewController();
      controller.loadRequest(Uri.parse(article.urls.first));
      controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      controller.setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          launchUrl(Uri.parse(request.url));
          return NavigationDecision.prevent;
        },
      ));
      return WebViewWidget(
          controller: controller,
          gestureRecognizers: <Factory<VerticalDragGestureRecognizer>>{
            Factory<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer(),
            ),
          });
    } else {
      String content =
          "<a href=\"${article.url}\">${article.title}</a><p>${Api.of(context).subs[article.feedId]?.title}<br>${getRelativeDate(article.published)}, ${DateTime.fromMillisecondsSinceEpoch(article.published * 1000)}</p>${article.content}";
      // print(content);
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: HtmlView(
              html: content,
              onLinkTap: (p0) {
                launchUrl(Uri.parse(p0));
              },
              onLinkLongPress: (p0) {
                showLinkMenu(context, p0, article.title);
              },
            ),
          ),
        ],
      );
      return ListenableBuilder(
          listenable: formattingSetting,
          child: SelectionArea(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: HtmlWidget(
                    content,
                    renderMode: const ColumnMode(),
                    onLoadingBuilder: (context, element, loadingProgress) {
                      return CircularProgressIndicator.adaptive(
                        value: loadingProgress,
                      );
                    },
                    // enableCaching: true,
                    onTapUrl: (p0) {
                      launchUrl(Uri.parse(p0));
                      return true;
                    },
                  ),
                ),
              ],
            ),
          ),
          builder: (context, child) {
            return AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                wordSpacing: formattingSetting.wordSpacing,
                fontSize: formattingSetting.fontSize,
                height: formattingSetting.lineHeight,
                fontFamily: formattingSetting.font,
              ),
              child: child!,
            );
          });
    }
  }
}

class SetUnreadButton extends StatefulWidget {
  const SetUnreadButton(
      {super.key, required this.indexNotifier, required this.articles});
  final ValueNotifier<int> indexNotifier;
  final List<Article> articles;

  @override
  State<SetUnreadButton> createState() => _SetUnreadButtonState();
}

class _SetUnreadButtonState extends State<SetUnreadButton> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.indexNotifier,
      builder: (context, value, child) {
        bool isRead = Api.of(context).isRead(widget.articles[value].id);
        return IconButton(
          onPressed: () {
            setState(() {
              Api.of(context).setRead(widget.articles[value].id, !isRead);
            });
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

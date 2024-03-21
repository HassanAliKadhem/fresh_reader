import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fresh_reader/util/formatting_setting.dart';
import 'package:fresh_reader/widget/blur_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api.dart';
import '../util/bionic.dart';
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
  late PageController _pageController;
  bool showWebView = false;
  final FormattingSetting formattingSetting = FormattingSetting();
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index);
    _pageController.addListener(_onPageChanged);
    pageIndex = widget.index;
  }

  void _onShare(BuildContext context) {
    try {
      Share.shareUri(Uri.parse(widget.articles[pageIndex].urls.first));
    } catch (e) {
      final box = context.findRenderObject() as RenderBox?;
      Share.share(
        widget.articles[pageIndex].urls.first,
        subject: widget.articles[pageIndex].title,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
      debugPrint(e.toString());
    }
  }

  void _onPageChanged() {
    if (_pageController.page != null &&
        _pageController.page?.round() == _pageController.page) {
      Api.of(context)
          .setRead(widget.articles[_pageController.page!.round()].id, true);
      setState(() {
        pageIndex = _pageController.page!.round();
      });
    }
  }

  List<Widget> bottomButtons() {
    bool isRead = Api.of(context).isRead(widget.articles[pageIndex].id);
    return [
      IconButton(
        onPressed: () {
          Api.of(context).setRead(widget.articles[pageIndex].id, !isRead);
          setState(() {});
        },
        tooltip: isRead ? "Set Unread" : "Set Read",
        icon: Icon(
          isRead ? Icons.circle_outlined : Icons.circle_rounded,
        ),
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
            Uri.parse(widget.articles[pageIndex].urls.first),
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
          title: Text("${pageIndex + 1} / ${widget.articles.length}"),
          flexibleSpace: const BlurBar()),
      extendBodyBehindAppBar: !showWebView,
      extendBody: !showWebView,
      bottomNavigationBar: BlurBar(
        child: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: bottomButtons(),
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        // onPageChanged: (value) => _onPageChanged(context, value),
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
                SwitchListTile.adaptive(
                  title: const Text("Use Bionic Reading ?"),
                  value: formattingSetting.isBionic,
                  onChanged: (value) => formattingSetting.setIsBionic(value),
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
      return ListenableBuilder(
          listenable: formattingSetting,
          child: SelectionArea(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: HtmlWidget(
                    formattingSetting.isBionic
                        ? getBionicContent(content)
                        : content,
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

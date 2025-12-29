import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../api/data.dart';
import '../api/preferences.dart';
import '../util/share.dart';
import '../widget/transparent_container.dart';

class ArticleBottomButtons extends StatefulWidget {
  const ArticleBottomButtons({super.key});

  @override
  State<ArticleBottomButtons> createState() => _ArticleBottomButtonsState();
}

class _ArticleBottomButtonsState extends State<ArticleBottomButtons> {
  Future<(String, String)> getUrlTitle(String articleID) async {
    var res = await context.read<DataProvider>().getArticleWithContent(
      articleID,
    );
    return (res.title, res.url);
  }

  @override
  Widget build(BuildContext context) {
    int? index = context.select<DataProvider, int?>((a) => a.selectedIndex);
    if (index == null ||
        context.select<DataProvider, bool>((d) => d.searchResults == null)) {
      return Container();
    }
    String? articleID = context
        .read<DataProvider>()
        .searchResults
        ?.elementAtOrNull(index);
    if (!context.select<DataProvider, bool>(
      (a) => a.articlesMetaData.containsKey(articleID),
    )) {
      return Container();
    }
    var (_, subID, isRead, isStarred) = context
        .select<DataProvider, (int, String, bool, bool)>(
          (a) => a.articlesMetaData[articleID]!,
        );
    return TransparentContainer(
      hasBorder: false,
      child: SafeArea(
        minimum: EdgeInsets.only(top: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                if (articleID != null) {
                  context.read<DataProvider>().setRead(
                    articleID,
                    subID,
                    !isRead,
                  );
                }
              },
              icon: Icon(isRead ? Icons.circle_outlined : Icons.circle),
              tooltip: "Read",
            ),
            IconButton(
              onPressed: () {
                if (articleID != null) {
                  context.read<DataProvider>().setStarred(
                    articleID,
                    subID,
                    !isStarred,
                  );
                }
              },
              icon: Icon(
                isStarred ? Icons.star_rounded : Icons.star_border_rounded,
              ),
              tooltip: "Star",
            ),
            IconButton(
              onPressed: () {
                if (articleID != null) {
                  try {
                    getUrlTitle(articleID).then((res) {
                      launchUrl(
                        Uri.parse(res.$2),
                        mode: LaunchMode.inAppBrowserView,
                      );
                    });
                  } catch (e) {
                    debugPrint(e.toString());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString(), maxLines: 3)),
                    );
                  }
                }
              },
              icon: Icon(Icons.open_in_browser_rounded),
              tooltip: "Browser",
            ),
            Builder(
              builder: (context) {
                return IconButton(
                  onPressed: () {
                    if (articleID != null) {
                      getUrlTitle(articleID).then((res) {
                        if (context.mounted) {
                          shareLink(context, res.$2, res.$1);
                        }
                      });
                    }
                  },
                  icon: Icon(
                    (Platform.isIOS || Platform.isMacOS)
                        ? CupertinoIcons.share
                        : Icons.share_rounded,
                  ),
                  tooltip: "Share",
                );
              },
            ),
            IconButton(
              onPressed: () {
                showDialog(
                  barrierDismissible: true,
                  barrierColor: Colors.transparent,
                  context: context,
                  builder: (context) {
                    return FormattingDialog();
                  },
                ).then((_) {
                  setState(() {});
                });
              },
              icon: Icon(
                (Platform.isIOS || Platform.isMacOS)
                    ? CupertinoIcons.textformat
                    : Icons.text_format_rounded,
              ),
              tooltip: "Text formatting",
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleWebViewButtons extends StatefulWidget {
  const ArticleWebViewButtons({super.key, required this.webViewController});
  final WebViewController webViewController;

  @override
  State<ArticleWebViewButtons> createState() => _ArticleWebViewButtonsState();
}

class _ArticleWebViewButtonsState extends State<ArticleWebViewButtons> {
  int progress = 0;

  @override
  void initState() {
    super.initState();
    widget.webViewController.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (newProgress) {
          if (mounted) {
            setState(() {
              progress = newProgress;
            });
          }
        },
        onNavigationRequest: (request) {
          setState(() {});
          return NavigationDecision.navigate;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 2,
          child: progress == 100
              ? LinearProgressIndicator(value: progress / 100.0)
              : null,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FutureBuilder(
              future: widget.webViewController.canGoBack(),
              builder: (context, snapshot) {
                return IconButton(
                  onPressed: snapshot.data == true
                      ? () {
                          widget.webViewController.goBack();
                        }
                      : null,
                  icon: Icon(
                    (Platform.isIOS || Platform.isMacOS)
                        ? CupertinoIcons.back
                        : Icons.arrow_back,
                  ),
                );
              },
            ),
            FutureBuilder(
              future: widget.webViewController.canGoForward(),
              builder: (context, snapshot) {
                return IconButton(
                  onPressed: snapshot.data == true
                      ? () {
                          widget.webViewController.goForward();
                        }
                      : null,
                  icon: Icon(
                    (Platform.isIOS || Platform.isMacOS)
                        ? CupertinoIcons.forward
                        : Icons.arrow_forward,
                  ),
                );
              },
            ),
            IconButton(
              onPressed: () {
                widget.webViewController.reload();
              },
              icon: Icon(
                (Platform.isIOS || Platform.isMacOS)
                    ? CupertinoIcons.refresh
                    : Icons.refresh,
              ),
            ),
            Builder(
              builder: (context) {
                return IconButton(
                  onPressed: () {
                    widget.webViewController.currentUrl().then((url) async {
                      widget.webViewController.getTitle().then((title) {
                        if (url != null) {
                          if (context.mounted) {
                            shareLink(context, url, title);
                          } else {
                            debugPrint("Context not mounted");
                          }
                        }
                      });
                    });
                  },
                  icon: Icon(
                    (Platform.isIOS || Platform.isMacOS)
                        ? CupertinoIcons.share_solid
                        : Icons.share_outlined,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class FormattingDialog extends StatelessWidget {
  const FormattingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      alignment: Alignment.bottomRight,
      scrollable: true,
      contentPadding: EdgeInsets.all(12.0),
      insetPadding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom,
        top: 16.0,
        right: 16.0,
        left: 16.0,
      ),
      // title: Text("Formatting settings"),
      content: ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: 400.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text("Formatting Settings"),
              trailing: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
              ),
              contentPadding: EdgeInsetsDirectional.only(start: 16.0),
            ),
            ListTile(
              leading: Icon(Icons.font_download),
              title: Text("Font"),
              dense: true,
            ),
            (Platform.isIOS || Platform.isMacOS)
                ? CupertinoSlidingSegmentedControl(
                    groupValue: context.select<Preferences, String>(
                      (a) => a.font,
                    ),
                    thumbColor: Theme.of(context).colorScheme.onPrimary,
                    onValueChanged: (value) {
                      if (value != null) {
                        context.read<Preferences>().setFontFamily(value);
                      }
                    },
                    children: context.read<Preferences>().fonts.asMap().map(
                      (i, font) => MapEntry(
                        font,
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            font.replaceFirst(".", ""),
                            style: TextStyle(fontFamily: font),
                          ),
                        ),
                      ),
                    ),
                    proportionalWidth: true,
                  )
                : SegmentedButton<String>(
                    segments: context
                        .read<Preferences>()
                        .fonts
                        .map(
                          (font) => ButtonSegment(
                            value: font,
                            label: Text(
                              font.replaceFirst(".", ""),
                              style: TextStyle(fontFamily: font),
                            ),
                          ),
                        )
                        .toList(),
                    selected: {
                      context.select<Preferences, String>((a) => a.font),
                    },
                    onSelectionChanged: (Set<String> newSelection) {
                      if (newSelection.isNotEmpty) {
                        context.read<Preferences>().setFontFamily(
                          newSelection.first,
                        );
                      }
                    },
                    showSelectedIcon: false,
                    multiSelectionEnabled: false,
                  ),
            const SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  [
                        [
                          Icon(
                            (Platform.isIOS || Platform.isMacOS)
                                ? CupertinoIcons.textformat_size
                                : Icons.format_size,
                          ),
                          Text("Size"),
                          Slider.adaptive(
                            value: context.select<Preferences, double>(
                              (a) => a.fontSize,
                            ),
                            label: context
                                .select<Preferences, double>((a) => a.fontSize)
                                .toString(),
                            min: 10.0,
                            max: 30.0,
                            onChanged: (v) {
                              context.read<Preferences>().setSize(v);
                            },
                          ),
                        ],
                        [
                          Icon(
                            (Platform.isIOS || Platform.isMacOS)
                                ? CupertinoIcons.textformat_size
                                : Icons.format_size,
                          ),
                          Text("Line"),
                          Slider.adaptive(
                            value: context.select<Preferences, double>(
                              (a) => a.lineHeight,
                            ),
                            label: context
                                .select<Preferences, double>(
                                  (a) => a.lineHeight,
                                )
                                .toString(),
                            min: 1.0,
                            max: 2.0,
                            onChanged: (v) {
                              context.read<Preferences>().setLineHeight(v);
                            },
                          ),
                        ],
                        [
                          Icon(Icons.space_bar),
                          Text("Word"),
                          Slider.adaptive(
                            value: context.select<Preferences, double>(
                              (a) => a.wordSpacing,
                            ),
                            label: context
                                .select<Preferences, double>(
                                  (a) => a.wordSpacing,
                                )
                                .toString(),
                            min: 0.0,
                            max: 10.0,
                            onChanged: (v) {
                              context.read<Preferences>().setSpacing(v);
                            },
                          ),
                        ],
                      ]
                      .map(
                        (entry) => Padding(
                          padding: EdgeInsetsGeometry.only(top: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 60.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [entry[0], entry[1]],
                                ),
                              ),
                              Expanded(child: entry[2]),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}

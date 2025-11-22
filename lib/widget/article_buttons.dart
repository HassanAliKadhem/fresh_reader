import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../api/data_types.dart';
import '../api/provider.dart';
import '../util/formatting_setting.dart';
import '../widget/transparent_container.dart';

class ArticleBottomButtons extends StatefulWidget {
  const ArticleBottomButtons({super.key, required this.articleNotifier});
  final ValueNotifier<Article?> articleNotifier;

  @override
  State<ArticleBottomButtons> createState() => _ArticleBottomButtonsState();
}

class _ArticleBottomButtonsState extends State<ArticleBottomButtons> {
  @override
  Widget build(BuildContext context) {
    return TransparentContainer(
      hasBorder: false,
      child: SafeArea(
        minimum: EdgeInsets.only(top: 8.0),
        child: ValueListenableBuilder(
          valueListenable: widget.articleNotifier,
          builder: (context, value, child) {
            bool isRead = value?.read ?? false;
            bool isStarred = value?.starred ?? false;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    if (value != null) {
                      setState(() {
                        Api.of(
                          context,
                        ).setRead(value.articleID, value.subID, !isRead);
                        value.read = !isRead;
                      });
                    }
                  },
                  icon: Icon(isRead ? Icons.circle_outlined : Icons.circle),
                  tooltip: "Read",
                ),
                IconButton(
                  onPressed: () {
                    if (value != null) {
                      setState(() {
                        value.starred = !isStarred;
                        Api.of(
                          context,
                        ).setStarred(value.articleID, value.subID, !isStarred);
                      });
                    }
                  },
                  icon: Icon(
                    isStarred ? Icons.star_rounded : Icons.star_border_rounded,
                  ),
                  tooltip: "Star",
                ),
                IconButton(
                  onPressed: () {
                    if (widget.articleNotifier.value != null) {
                      try {
                        launchUrl(
                          Uri.parse(widget.articleNotifier.value!.url),
                          mode: LaunchMode.inAppBrowserView,
                        );
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
                        if (widget.articleNotifier.value != null) {
                          try {
                            final box =
                                context.findRenderObject() as RenderBox?;
                            SharePlus.instance.share(
                              ShareParams(
                                uri: Uri.parse(
                                  widget.articleNotifier.value!.url,
                                ),
                                subject: widget.articleNotifier.value!.title,
                                sharePositionOrigin:
                                    box!.localToGlobal(Offset.zero) & box.size,
                              ),
                            );
                          } catch (e) {
                            debugPrint(e.toString());
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString(), maxLines: 3),
                              ),
                            );
                          }
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
            );
          },
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
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FutureBuilder(
            future: widget.webViewController.canGoBack(),
            builder: (context, snapshot) {
              return IconButton(
                onPressed:
                    snapshot.data == true
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
                onPressed:
                    snapshot.data == true
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
                    if (url != null) {
                      try {
                        if (context.mounted) {
                          final box = context.findRenderObject() as RenderBox?;
                          SharePlus.instance.share(
                            ShareParams(
                              uri: Uri.parse(url),
                              subject:
                                  (await widget.webViewController.getTitle()),
                              sharePositionOrigin:
                                  box!.localToGlobal(Offset.zero) & box.size,
                            ),
                          );
                        } else {
                          debugPrint("Context not mounted");
                        }
                      } catch (e) {
                        debugPrint(e.toString());
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString(), maxLines: 3)),
                          );
                        } else {
                          debugPrint("Context not mounted");
                        }
                      }
                    }
                  });
                },
                icon: Icon(
                  (Platform.isIOS || Platform.isMacOS)
                      ? CupertinoIcons.share
                      : Icons.share,
                ),
              );
            },
          ),
        ],
      ),
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
              leading: Icon(Icons.font_download),
              title: Text("Font"),
              trailing: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
              ),
              contentPadding: EdgeInsetsDirectional.only(start: 16.0),
            ),
            (Platform.isIOS || Platform.isMacOS)
                ? CupertinoSlidingSegmentedControl(
                  groupValue: Preferences.of(context).font,
                  thumbColor: Theme.of(context).colorScheme.onPrimary,
                  onValueChanged: (value) {
                    if (value != null) {
                      Preferences.of(context).setFontFamily(value);
                    }
                  },
                  children: Preferences.of(context).fonts.asMap().map(
                    (i, font) => MapEntry(
                      font,
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(font.replaceFirst(".", "")),
                      ),
                    ),
                  ),
                )
                : SegmentedButton<String>(
                  segments:
                      Preferences.of(context).fonts
                          .map(
                            (font) => ButtonSegment(
                              value: font,
                              label: Text(font.replaceFirst(".", "")),
                            ),
                          )
                          .toList(),
                  selected: {Preferences.of(context).font},
                  onSelectionChanged: (Set<String> newSelection) {
                    if (newSelection.isNotEmpty) {
                      Preferences.of(context).setFontFamily(newSelection.first);
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
                            value: Preferences.of(context).fontSize,
                            label: Preferences.of(context).fontSize.toString(),
                            min: 10.0,
                            max: 30.0,
                            onChanged: (v) {
                              Preferences.of(context).setSize(v);
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
                            value: Preferences.of(context).lineHeight,
                            label: Preferences.of(context).lineHeight.toString(),
                            min: 1.0,
                            max: 2.0,
                            onChanged: (v) {
                              Preferences.of(context).setLineHeight(v);
                            },
                          ),
                        ],
                        [
                          Icon(Icons.space_bar),
                          Text("Word"),
                          Slider.adaptive(
                            value: Preferences.of(context).wordSpacing,
                            label:
                                Preferences.of(context).wordSpacing.toString(),
                            min: 0.0,
                            max: 10.0,
                            onChanged: (v) {
                              Preferences.of(context).setSpacing(v);
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

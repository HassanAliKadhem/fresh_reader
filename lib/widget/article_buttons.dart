import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../api/api.dart';
import '../api/data_types.dart';
import '../util/formatting_setting.dart';
import '../widget/transparent_container.dart';

class ArticleBottomButtons extends StatefulWidget {
  const ArticleBottomButtons({
    super.key,
    required this.articleNotifier,
    required this.formattingSetting,
  });
  final ValueNotifier<Article?> articleNotifier;
  final FormattingSetting formattingSetting;

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
                        value.read = !isRead;
                        Api.of(
                          context,
                        ).setRead(value.articleID, value.subID, !isRead);
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
                            child: FormattingBottomSheet(
                              formattingSetting: widget.formattingSetting,
                            ),
                          ),
                        );
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
                      } catch (e) {
                        debugPrint(e.toString());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString(), maxLines: 3)),
                        );
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

class FormattingBottomSheet extends StatefulWidget {
  const FormattingBottomSheet({super.key, required this.formattingSetting});
  final FormattingSetting formattingSetting;

  @override
  State<FormattingBottomSheet> createState() => _FormattingBottomSheetState();
}

class _FormattingBottomSheetState extends State<FormattingBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.font_download),
          title: Text("Font"),
          dense: true,
        ),
        (Platform.isIOS || Platform.isMacOS)
            ? CupertinoSlidingSegmentedControl(
              groupValue: widget.formattingSetting.font,
              thumbColor: Theme.of(context).colorScheme.onPrimary,
              onValueChanged: (value) {
                if (value != null) {
                  setState(() {
                    widget.formattingSetting.setFontFamily(value);
                  });
                }
              },
              children: widget.formattingSetting.fonts.asMap().map(
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
                  widget.formattingSetting.fonts
                      .map(
                        (font) => ButtonSegment(
                          value: font,
                          label: Text(font.replaceFirst(".", "")),
                        ),
                      )
                      .toList(),
              selected: {widget.formattingSetting.font},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  widget.formattingSetting.setFontFamily(newSelection.first);
                });
              },
              showSelectedIcon: false,
              multiSelectionEnabled: false,
            ),

        Table(
          columnWidths: {0: FlexColumnWidth(1), 1: FlexColumnWidth(3)},
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
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
                        value: widget.formattingSetting.fontSize,
                        label: widget.formattingSetting.fontSize.toString(),
                        min: 10.0,
                        max: 30.0,
                        onChanged: (v) {
                          setState(() {
                            widget.formattingSetting.setSize(v);
                          });
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
                        value: widget.formattingSetting.lineHeight,
                        label: widget.formattingSetting.lineHeight.toString(),
                        min: 1.0,
                        max: 2.0,
                        onChanged: (v) {
                          setState(() {
                            widget.formattingSetting.setLineHeight(v);
                          });
                        },
                      ),
                    ],
                    [
                      Icon(Icons.space_bar),
                      Text("Word"),
                      Slider.adaptive(
                        value: widget.formattingSetting.wordSpacing,
                        label: widget.formattingSetting.wordSpacing.toString(),
                        min: 0.0,
                        max: 10.0,
                        onChanged: (v) {
                          setState(() {
                            widget.formattingSetting.setSpacing(v);
                          });
                        },
                      ),
                    ],
                  ]
                  .map(
                    (entry) => TableRow(
                      children: [
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.bottom,
                          child: Padding(
                            padding: EdgeInsetsGeometry.only(top: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [entry[0], entry[1]],
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.bottom,
                          child: entry[2],
                        ),
                      ],
                    ),
                  )
                  .toList(),
        ),
        // SizedBox(height: 8.0),
        // Row(
        //   children: [
        //     Column(
        //       children: [
        //         Icon(
        //           (Platform.isIOS || Platform.isMacOS)
        //               ? CupertinoIcons.textformat_size
        //               : Icons.format_size,
        //         ),
        //         Text("Font size"),
        //       ],
        //     ),
        //     Expanded(
        //       child: Slider.adaptive(
        //         value: widget.formattingSetting.fontSize,
        //         label: widget.formattingSetting.fontSize.toString(),
        //         min: 10.0,
        //         max: 30.0,
        //         onChanged: (v) {
        //           setState(() {
        //             widget.formattingSetting.setSize(v);
        //           });
        //         },
        //       ),
        //     ),
        //   ],
        // ),
        // SizedBox(height: 8.0),
        // ListTile(
        //   leading: Icon(
        //     (Platform.isIOS || Platform.isMacOS)
        //         ? CupertinoIcons.textformat_size
        //         : Icons.format_size,
        //   ),
        //   title: Text("Font size"),
        // ),
        // Slider.adaptive(
        //   value: widget.formattingSetting.fontSize,
        //   label: widget.formattingSetting.fontSize.toString(),
        //   min: 10.0,
        //   max: 30.0,
        //   onChanged: (v) {
        //     setState(() {
        //       widget.formattingSetting.setSize(v);
        //     });
        //   },
        // ),

        // ListTile(
        //   leading: Icon(Icons.format_line_spacing),
        //   title: Text("Line spacing"),
        // ),
        // Slider.adaptive(
        //   value: widget.formattingSetting.lineHeight,
        //   label: widget.formattingSetting.lineHeight.toString(),
        //   min: 1.0,
        //   max: 2.0,
        //   onChanged: (v) {
        //     setState(() {
        //       widget.formattingSetting.setLineHeight(v);
        //     });
        //   },
        // ),
        // ListTile(leading: Icon(Icons.space_bar), title: Text("Word Spacing")),
        // Slider.adaptive(
        //   value: widget.formattingSetting.wordSpacing,
        //   label: widget.formattingSetting.wordSpacing.toString(),
        //   min: 0.0,
        //   max: 10.0,
        //   onChanged: (v) {
        //     setState(() {
        //       widget.formattingSetting.setSpacing(v);
        //     });
        //   },
        // ),
        SizedBox(height: 16.0),
      ],
    );
  }
}

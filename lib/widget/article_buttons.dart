import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api.dart';
import '../api/data_types.dart';
import '../util/formatting_setting.dart';
import 'blur_bar.dart';

class ArticleBottomButtons extends StatefulWidget {
  const ArticleBottomButtons({
    super.key,
    required this.articleNotifier,
    required this.formattingSetting,
    required this.showWebView,
    required this.changeShowWebView,
  });
  final ValueNotifier<Article?> articleNotifier;
  final bool showWebView;
  final Function() changeShowWebView;
  final FormattingSetting formattingSetting;

  @override
  State<ArticleBottomButtons> createState() => _ArticleBottomButtonsState();
}

class _ArticleBottomButtonsState extends State<ArticleBottomButtons> {
  @override
  Widget build(BuildContext context) {
    return BlurBar(
      child: SafeArea(
        minimum: EdgeInsets.all(8.0),
        child: ValueListenableBuilder(
          valueListenable: widget.articleNotifier,
          builder: (context, value, child) {
            bool isRead = value?.read ?? true;
            bool isStarred = value?.starred ?? false;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isRead ? Icons.circle_outlined : Icons.circle),
                      Text("Read"),
                    ],
                  ),
                ),
                TextButton(
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isStarred
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                      ),
                      Text("Star"),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (widget.articleNotifier.value != null) {
                      try {
                        final box = context.findRenderObject() as RenderBox?;
                        SharePlus.instance.share(
                          ShareParams(
                            uri: Uri.parse(widget.articleNotifier.value!.url),
                            subject: widget.articleNotifier.value!.title,
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
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        (Platform.isIOS || Platform.isMacOS)
                            ? CupertinoIcons.share
                            : Icons.share_rounded,
                      ),
                      Text("Share"),
                    ],
                  ),
                ),
                TextButton(
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        (Platform.isIOS || Platform.isMacOS)
                            ? CupertinoIcons.globe
                            : Icons.public_rounded,
                      ),
                      Text("Browser"),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => widget.changeShowWebView(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.showWebView
                            ? Icons.article_rounded
                            : Icons.article_outlined,
                      ),
                      Text("Web View"),
                    ],
                  ),
                ),
                // FormattingButton(
                //   formattingSetting: widget.formattingSetting,
                //   showWebView: widget.showWebView,
                // ),
              ],
            );
          },
        ),
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
    return SafeArea(
      minimum: EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: Icon(Icons.font_download), title: Text("Font")),
          SegmentedButton<String>(
            segments:
                widget.formattingSetting.fonts
                    .map(
                      (font) => ButtonSegment(value: font, label: Text(font)),
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

          ListTile(
            leading: Icon(
              (Platform.isIOS || Platform.isMacOS)
                  ? CupertinoIcons.textformat_size
                  : Icons.format_size,
            ),
            title: Text("Font size"),
          ),
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

          ListTile(
            leading: Icon(Icons.format_line_spacing),
            title: Text("Line spacing"),
          ),
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

          ListTile(leading: Icon(Icons.space_bar), title: Text("Word spacing")),
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
          SizedBox(height: 24.0),
        ],
      ),
    );
  }
}

final IconData arrowUp =
    (Platform.isIOS || Platform.isMacOS)
        ? CupertinoIcons.chevron_up
        : Icons.keyboard_arrow_up;
final IconData arrowDown =
    (Platform.isIOS || Platform.isMacOS)
        ? CupertinoIcons.chevron_down
        : Icons.keyboard_arrow_down;

class FormattingButton extends StatelessWidget {
  const FormattingButton({
    super.key,
    required this.showWebView,
    required this.formattingSetting,
  });
  final bool showWebView;
  final FormattingSetting formattingSetting;

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder:
          (context) => [
            const PullDownMenuTitle(title: Text('Font')),
            ...formattingSetting.fonts.map(
              (font) => PullDownMenuItem.selectable(
                onTap: () {
                  formattingSetting.setFontFamily(font);
                },
                selected: formattingSetting.font == font,
                title: font,
              ),
            ),
            const PullDownMenuTitle(title: Text('Font Options')),
            PullDownMenuActionsRow.medium(
              items: [
                PullDownMenuItem(
                  onTap: null,
                  enabled: false,
                  title: 'Size',
                  icon:
                      (Platform.isIOS || Platform.isMacOS)
                          ? CupertinoIcons.textformat_size
                          : Icons.format_size,
                ),
                PullDownMenuItem(
                  onTap: () {},
                  tapHandler: (context, onTap) {
                    formattingSetting.setSize(
                      max(10, min(formattingSetting.fontSize + 2, 30)),
                    );
                  },
                  title: 'Increase',
                  icon: arrowUp,
                ),
                PullDownMenuItem(
                  onTap: () {},
                  tapHandler: (context, onTap) {
                    formattingSetting.setSize(
                      max(10, min(formattingSetting.fontSize - 2, 30)),
                    );
                  },
                  title: 'Decrease',
                  icon: arrowDown,
                ),
              ],
            ),
            PullDownMenuActionsRow.medium(
              items: [
                PullDownMenuItem(
                  onTap: null,
                  enabled: false,
                  title: 'Line Height',
                  icon: Icons.format_line_spacing,
                ),
                PullDownMenuItem(
                  onTap: () {},
                  tapHandler: (context, onTap) {
                    formattingSetting.setLineHeight(
                      max(1.0, min(formattingSetting.lineHeight + 0.2, 2.0)),
                    );
                  },
                  title: 'Increase',
                  icon: arrowUp,
                ),
                PullDownMenuItem(
                  onTap: () {},
                  tapHandler: (context, onTap) {
                    formattingSetting.setLineHeight(
                      max(1.0, min(formattingSetting.lineHeight - 0.2, 2.0)),
                    );
                  },
                  title: 'Decrease',
                  icon: arrowDown,
                ),
              ],
            ),
            PullDownMenuActionsRow.medium(
              items: [
                PullDownMenuItem(
                  onTap: null,
                  enabled: false,
                  title: 'Spacing',
                  icon: Icons.space_bar,
                ),
                PullDownMenuItem(
                  onTap: () {},
                  tapHandler: (context, onTap) {
                    formattingSetting.setSpacing(
                      max(0, min(formattingSetting.wordSpacing + 2, 10)),
                    );
                  },
                  title: 'Increase',
                  icon: arrowUp,
                ),
                PullDownMenuItem(
                  onTap: () {},
                  tapHandler: (context, onTap) {
                    formattingSetting.setSpacing(
                      max(0, min(formattingSetting.wordSpacing - 2, 10)),
                    );
                  },
                  title: 'Decrease',
                  icon: arrowDown,
                ),
              ],
            ),
            // PullDownMenuItem.selectable(
            //   onTap: () {
            //     widget.formattingSetting
            //         .setIsBionic(!widget.formattingSetting.isBionic);
            //   },
            //   selected: widget.formattingSetting.isBionic,
            //   title: 'Use Bionic Reading',
            // ),
          ],
      buttonBuilder:
          (context, showMenu) => IconButton(
            onPressed: showWebView ? null : showMenu,
            icon: Icon(
              (Platform.isIOS || Platform.isMacOS)
                  ? CupertinoIcons.textformat
                  : Icons.text_format_rounded,
            ),
          ),
    );
  }
}

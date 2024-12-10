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
                  InkWell(
                    onTap: () {
                      if (value != null) {
                        value.read = !isRead;
                        setState(() {
                          Api.of(context)
                              .setRead(value.id, value.subID, !isRead);
                        });
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isRead
                              ? Icons.check_circle_outline_outlined
                              : Icons.circle_outlined,
                        ),
                        //Text(isRead ? "Unread" : "Read"),
                        Text("Read"),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      value!.starred = !isStarred;
                      setState(() {
                        Api.of(context)
                            .setStarred(value.id, value.subID, !isStarred);
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isStarred ? Icons.star : Icons.star_border),
                        // Text(isStarred ? "UnStar" : "Star"),
                        Text("Star"),
                      ],
                    ),
                  ),
                  Builder(builder: (context) {
                    return InkWell(
                      onTap: () {
                        if (widget.articleNotifier.value != null) {
                          final box = context.findRenderObject() as RenderBox?;
                          Share.share(
                            widget.articleNotifier.value!.url,
                            subject: widget.articleNotifier.value!.title,
                            sharePositionOrigin:
                                box!.localToGlobal(Offset.zero) & box.size,
                          );
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Platform.isAndroid
                                ? Icons.share_outlined
                                : CupertinoIcons.share,
                          ),
                          Text("Share"),
                        ],
                      ),
                    );
                  }),
                  InkWell(
                    onTap: () {
                      if (widget.articleNotifier.value != null) {
                        launchUrl(
                          Uri.parse(widget.articleNotifier.value!.url),
                          mode: LaunchMode.inAppBrowserView,
                        );
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Platform.isAndroid
                              ? Icons.public
                              : CupertinoIcons.globe,
                        ),
                        Text("Browser"),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => widget.changeShowWebView(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.showWebView
                              ? Icons.article_outlined
                              : Icons.web,
                        ),
                        Text(widget.showWebView ? "Text View" : "Web View")
                      ],
                    ),
                  ),
                  PullDownButton(
                    itemBuilder: (context) => [
                      const PullDownMenuTitle(title: Text('Font')),
                      ...widget.formattingSetting.fonts
                          .map((font) => PullDownMenuItem.selectable(
                                onTap: () {
                                  widget.formattingSetting.setFontFamily(font);
                                },
                                selected: widget.formattingSetting.font == font,
                                title: font,
                              )),
                      const PullDownMenuTitle(title: Text('Font Options')),
                      PullDownMenuActionsRow.medium(
                        items: [
                          PullDownMenuItem(
                            onTap: null,
                            enabled: false,
                            title: 'Size',
                            icon: Icons.format_size,
                          ),
                          PullDownMenuItem(
                            onTap: () {},
                            tapHandler: (context, onTap) {
                              widget.formattingSetting.setSize(max(
                                  10,
                                  min(widget.formattingSetting.fontSize + 2,
                                      30)));
                            },
                            title: 'Increase',
                            icon: CupertinoIcons.arrow_up,
                          ),
                          PullDownMenuItem(
                            onTap: () {},
                            tapHandler: (context, onTap) {
                              widget.formattingSetting.setSize(max(
                                  10,
                                  min(widget.formattingSetting.fontSize - 2,
                                      30)));
                            },
                            title: 'Decrease',
                            icon: CupertinoIcons.arrow_down,
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
                              widget.formattingSetting.setLineHeight(max(
                                  1.0,
                                  min(widget.formattingSetting.lineHeight + 0.2,
                                      2.0)));
                            },
                            title: 'Increase',
                            icon: CupertinoIcons.arrow_up,
                          ),
                          PullDownMenuItem(
                            onTap: () {},
                            tapHandler: (context, onTap) {
                              widget.formattingSetting.setLineHeight(max(
                                  1.0,
                                  min(widget.formattingSetting.lineHeight - 0.2,
                                      2.0)));
                            },
                            title: 'Decrease',
                            icon: CupertinoIcons.arrow_down,
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
                              widget.formattingSetting.setSpacing(max(
                                  0,
                                  min(widget.formattingSetting.wordSpacing + 2,
                                      10)));
                            },
                            title: 'Increase',
                            icon: CupertinoIcons.arrow_up,
                          ),
                          PullDownMenuItem(
                            onTap: () {},
                            tapHandler: (context, onTap) {
                              widget.formattingSetting.setSpacing(max(
                                  0,
                                  min(widget.formattingSetting.wordSpacing - 2,
                                      10)));
                            },
                            title: 'Decrease',
                            icon: CupertinoIcons.arrow_down,
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
                    buttonBuilder: (context, showMenu) => Opacity(
                      opacity: widget.showWebView ? 0.5 : 1.0,
                      child: InkWell(
                        onTap: widget.showWebView ? null : showMenu,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.text_format_outlined),
                            Text("Formatting"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}

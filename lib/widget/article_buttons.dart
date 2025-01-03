import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fresh_reader/main.dart';
import 'package:fresh_reader/view/article_list.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/database.dart';
import '../util/formatting_setting.dart';
import 'blur_bar.dart';

class ArticleBottomButtons extends StatefulWidget {
  const ArticleBottomButtons({
    super.key,
    required this.formattingSetting,
    required this.showWebView,
    required this.changeShowWebView,
  });
  final bool showWebView;
  final Function() changeShowWebView;
  final FormattingSetting formattingSetting;

  @override
  State<ArticleBottomButtons> createState() => _ArticleBottomButtonsState();
}

class _ArticleBottomButtonsState extends State<ArticleBottomButtons> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: articleIndex,
        builder: (context, child) {
          if (articleIndex.value == null) {
            return Container();
          }
          return StreamBuilder<ArticleData>(
              stream: (database.select(database.article)
                    ..where(
                      (tbl) => tbl.id
                          .equals(currentArticles[articleIndex.value!].$1.id),
                    ))
                  .watchSingle(),
              builder: (context, articleSnapshot) {
                if (!articleSnapshot.hasData) return Container();
                return BlurBar(
                  child: SafeArea(
                    minimum: EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            database.update(database.article).replace(
                                articleSnapshot.data!.copyWith(
                                    read: !articleSnapshot.data!.read));
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                articleSnapshot.data!.read
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.circle,
                              ),
                              Text("Read"),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            database.update(database.article).replace(
                                articleSnapshot.data!.copyWith(
                                    starred: !articleSnapshot.data!.starred));
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(articleSnapshot.data!.starred
                                  ? Icons.star
                                  : Icons.star_border),
                              Text("Star"),
                            ],
                          ),
                        ),
                        Builder(builder: (context) {
                          return InkWell(
                            onTap: () {
                              final box =
                                  context.findRenderObject() as RenderBox?;
                              Share.share(
                                articleSnapshot.data!.url,
                                subject: articleSnapshot.data!.title,
                                sharePositionOrigin:
                                    box!.localToGlobal(Offset.zero) & box.size,
                              );
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
                            launchUrl(
                              Uri.parse(articleSnapshot.data!.url),
                              mode: LaunchMode.inAppBrowserView,
                            );
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
                              Text(
                                  widget.showWebView ? "Text View" : "Web View")
                            ],
                          ),
                        ),
                        // FormatButton(
                        //     formattingSetting: widget.formattingSetting,
                        //     showWebView: widget.showWebView),
                      ],
                    ),
                  ),
                );
              });
        });
  }
}

class FormatButton extends StatelessWidget {
  const FormatButton({
    super.key,
    required this.formattingSetting,
    required this.showWebView,
  });
  final bool showWebView;
  final FormattingSetting formattingSetting;

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        const PullDownMenuTitle(title: Text('Font')),
        ...formattingSetting.fonts.map((font) => PullDownMenuItem.selectable(
              onTap: () {
                formattingSetting.setFontFamily(font);
              },
              selected: formattingSetting.font == font,
              title: font,
            )),
        // const PullDownMenuTitle(title: Text('Bionic Reading')),
        // PullDownMenuItem.selectable(
        //   onTap: () {
        //     formattingSetting.setIsBionic(formattingSetting.isBionic);
        //   },
        //   selected: formattingSetting.isBionic,
        //   title: 'Use Bionic Reading',
        // ),
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
                formattingSetting
                    .setSize(max(10, min(formattingSetting.fontSize + 2, 30)));
              },
              title: 'Increase',
              icon: CupertinoIcons.arrow_up,
            ),
            PullDownMenuItem(
              onTap: () {},
              tapHandler: (context, onTap) {
                formattingSetting
                    .setSize(max(10, min(formattingSetting.fontSize - 2, 30)));
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
                formattingSetting.setLineHeight(
                    max(1.0, min(formattingSetting.lineHeight + 0.2, 2.0)));
              },
              title: 'Increase',
              icon: CupertinoIcons.arrow_up,
            ),
            PullDownMenuItem(
              onTap: () {},
              tapHandler: (context, onTap) {
                formattingSetting.setLineHeight(
                    max(1.0, min(formattingSetting.lineHeight - 0.2, 2.0)));
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
                formattingSetting.setSpacing(
                    max(0, min(formattingSetting.wordSpacing + 2, 10)));
              },
              title: 'Increase',
              icon: CupertinoIcons.arrow_up,
            ),
            PullDownMenuItem(
              onTap: () {},
              tapHandler: (context, onTap) {
                formattingSetting.setSpacing(
                    max(0, min(formattingSetting.wordSpacing - 2, 10)));
              },
              title: 'Decrease',
              icon: CupertinoIcons.arrow_down,
            ),
          ],
        ),
      ],
      buttonBuilder: (context, showMenu) => IconButton(
        onPressed: showWebView ? null : showMenu,
        // label: Text("Format"),
        icon: const Icon(Icons.text_format_outlined),
      ),
    );
  }
}

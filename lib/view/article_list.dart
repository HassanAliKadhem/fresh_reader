import 'dart:io';

import 'package:anchor_scroll_controller/anchor_scroll_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fresh_reader/util/date.dart';
import 'package:provider/provider.dart';

import '../api/api.dart';
import '../api/data_types.dart';
import '../main.dart';
import '../util/screen_size.dart';
import '../widget/article_tile.dart';
import '../widget/transparent_container.dart';

class ArticleList extends StatefulWidget {
  const ArticleList({super.key});

  @override
  State<ArticleList> createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  final TextEditingController _searchController = TextEditingController();
  final AnchorScrollController _scrollController = AnchorScrollController(
    anchorOffset: kToolbarHeight * 2.5,
  );
  int lastIndex = 0;

  void search(String? text) {
    context.read<Api>().searchFilteredArticles(text);
  }

  @override
  void initState() {
    super.initState();
    context.read<Api>().listController = _scrollController;
  }

  @override
  Widget build(BuildContext context) {
    List<String>? searchResults = context.select<Api, List<String>?>(
      (a) => a.searchResults,
    );
    return Scaffold(
      backgroundColor: Color.alphaBlend(
        Colors.black.withAlpha(24),
        Theme.of(context).scaffoldBackgroundColor,
      ),
      appBar: AppBar(
        flexibleSpace: const TransparentContainer(hasBorder: false),
        title: (Platform.isIOS || Platform.isMacOS)
            ? CupertinoSearchTextField(
                controller: _searchController,
                onChanged: (value) {
                  search(value);
                },
                onSuffixTap: () {
                  _searchController.clear();
                  search(null);
                },
                padding: const EdgeInsets.all(12.0),
                placeholder:
                    "Search ${context.select<Api, String?>((value) => value.filteredTitle)?.split("/").last ?? ""}",
              )
            : SearchBar(
                hintText:
                    "Search ${context.select<Api, String?>((value) => value.filteredTitle)?.split("/").last ?? ""}",
                controller: _searchController,
                textInputAction: TextInputAction.search,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.search),
                ),
                constraints: BoxConstraints(minHeight: 42.0),
                elevation: WidgetStatePropertyAll(0.0),
                trailing: _searchController.text != ""
                    ? [
                        IconButton(
                          onPressed: () {
                            _searchController.clear();
                            search(null);
                          },
                          icon: const Icon(Icons.clear),
                        ),
                      ]
                    : null,
                onChanged: (value) {
                  search(value);
                },
              ),
        leading: screenSizeOf(context) == ScreenSize.big
            ? IconButton(
                onPressed: () {
                  isExpanded.value = !isExpanded.value;
                },
                icon: Icon(CupertinoIcons.fullscreen),
              )
            : null,
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: TransparentContainer(
        hasBorder: false,
        child: SizedBox(height: MediaQuery.paddingOf(context).bottom),
      ),
      body:
          context.select<Api, String?>((value) => value.filteredTitle) ==
                  null ||
              searchResults == null
          ? const SizedBox()
          : Scrollbar(
              controller: _scrollController,
              child: ListView.separated(
                key: const PageStorageKey(0),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: searchResults.length,
                controller: _scrollController,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    String date = getFormattedDate(
                      context
                          .read<Api>()
                          .articlesMetaData[searchResults[index]]!
                          .$1,
                    ).split(", ")[1].split(" ")[0];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        separator(date),
                        AnchorItemWrapper(
                          index: index,
                          key: ValueKey("list-$index"),
                          controller: _scrollController,
                          child: ArticleTile(
                            articleID: searchResults[index],
                            index: index,
                          ),
                        ),
                      ],
                    );
                  }
                  return AnchorItemWrapper(
                    index: index,
                    key: ValueKey("list-$index"),
                    controller: _scrollController,
                    child: ArticleTile(
                      articleID: searchResults[index],
                      index: index,
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  int? previous = context
                      .read<Api>()
                      .articlesMetaData[searchResults[index]]
                      ?.$1;
                  if (previous != null) {
                    String previousDate = getFormattedDate(
                      previous,
                    ).split(", ")[1].split(" ")[0];
                    int? next = context
                        .read<Api>()
                        .articlesMetaData[searchResults.elementAtOrNull(
                          index + 1,
                        )]
                        ?.$1;
                    if (next != null) {
                      String nextDate = getFormattedDate(
                        next,
                      ).split(", ")[1].split(" ")[0];
                      if (nextDate != previousDate) {
                        return separator(nextDate);
                      }
                    }
                  }

                  return Container();
                },
              ),
            ),
    );
  }

  Widget separator(String date) {
    double? height = Theme.of(context).textTheme.bodyLarge?.height;
    return Text(
      "  $date",
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        height: height != null ? height * 1.5 : null,
      ),
    );
  }
}

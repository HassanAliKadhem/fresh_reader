import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fresh_reader/view/settings_view.dart';

import 'api/api.dart';
import 'api/data_types.dart';
import 'view/article_list.dart';
import 'view/article_view.dart';
import 'view/feed_list.dart';

ApiData _apiData = ApiData();
dynamic mainLoadError;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [
      SystemUiOverlay.top,
    ],
  ).then((_) {
    _apiData.load().then((_) {
      runApp(const MyApp());
    });
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Api(
      notifier: _apiData,
      child: MaterialApp(
        title: 'FreshReader',
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          appBarTheme: const AppBarTheme(
            // backgroundColor: Colors.deepPurple,
            backgroundColor: Colors.transparent,
            scrolledUnderElevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              systemStatusBarContrastEnforced: false,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarDividerColor: Colors.transparent,
              systemNavigationBarContrastEnforced: false,
              systemNavigationBarIconBrightness: Brightness.light,
            ),
          ),
          useMaterial3: true,
        ),
        home: const HomeWidget(),
      ),
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({
    super.key,
  });

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

class _HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _navigatorKey.currentState!.maybePop();
          }
        },
        child: Navigator(
          key: _navigatorKey,
          onDidRemovePage: (page) {
            if (page.name == "/article") {
              setState(() {
                Api.of(context).filteredIndex = null;
              });
            } else if (page.name == "/list") {
              setState(() {
                Api.of(context).filteredIndex = null;
                Api.of(context).filteredArticleIDs = null;
              });
            }
          },
          pages: [
            MaterialPage(
              name: "/",
              child: screenSizeOf(context) == ScreenSize.small
                  ? FeedList(onSelect: _onChooseFeed)
                  : Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: FeedList(onSelect: _onChooseFeed),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          flex: 2,
                          child: ArticleList(
                            onSelect: _onChooseArticle,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        if (screenSizeOf(context) == ScreenSize.big)
                          Expanded(
                            flex: 3,
                            child: ArticleView(
                              key: ValueKey(Api.of(context).filteredTitle),
                              index: Api.of(context).filteredIndex,
                              articleIDs: Api.of(context).filteredArticleIDs,
                            ),
                          ),
                      ],
                    ),
            ),
            if (Api.of(context).server == "" && Api.of(context).justBooted)
              const MaterialPage(
                name: "/settings",
                child: SettingsView(),
              ),
            if (screenSizeOf(context) == ScreenSize.small &&
                Api.of(context).filteredArticleIDs != null)
              MaterialPage(
                name: "/list",
                child: ArticleList(onSelect: _onChooseArticle),
              ),
            if (screenSizeOf(context) != ScreenSize.big &&
                Api.of(context).filteredIndex != null)
              MaterialPage(
                name: "/article",
                child: ArticleView(
                  index: Api.of(context).filteredIndex ?? 0,
                  articleIDs: Api.of(context).filteredArticleIDs ?? {},
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onChooseFeed(String? column, String? value) {
    currentArticleNotifier.value = null;
    Api.of(context)
        .getFilteredArticles(Api.of(context).getShowAll(), column, value)
        .then((_) {
      setState(() {});
    });
  }

  void _onChooseArticle(int index, String articleID) {
    setState(() {});
  }
}

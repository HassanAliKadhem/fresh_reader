import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fresh_reader/view/article_list.dart';
import 'package:fresh_reader/view/article_view.dart';

import 'api/api.dart';
import 'api/data_types.dart';
import 'view/feed_list.dart';

ApiData _apiData = ApiData();

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
  final ApiData apiData = ApiData()..load();

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

class _HomeWidgetState extends State<HomeWidget> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !await _navigatorKey.currentState!.maybePop();
      },
      child: Navigator(
        key: _navigatorKey,
        onPopPage: (route, result) {
          if (route.settings.name == "/article") {
            setState(() {
              Api.of(context).filteredIndex = null;
            });
          } else if (route.settings.name == "/list") {
            setState(() {
              Api.of(context).filteredIndex = null;
              Api.of(context).filteredArticleIDs = null;
            });
          }
          return route.didPop(result);
        },
        pages: [
          MaterialPage(
            name: "/",
            child: screenSizeOf(context) == ScreenSize.small
                ? FeedList(
                    title: "FreshReader",
                    onSelect: _onChooseFeed,
                  )
                : Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: FeedList(
                          title: 'FreshReader',
                          onSelect: _onChooseFeed,
                        ),
                      ),
                      Expanded(
                        flex:
                            screenSizeOf(context) == ScreenSize.medium ? 3 : 7,
                        child: ArticleList(onSelect: _onChooseArticle),
                      ),
                    ],
                  ),
          ),
          if (screenSizeOf(context) == ScreenSize.small &&
              Api.of(context).filteredArticleIDs != null)
            MaterialPage(
              name: "/list",
              child: ArticleList(onSelect: _onChooseArticle),
            ),
          if (Api.of(context).filteredIndex != null &&
              Api.of(context).filteredIndex != null)
            MaterialPage(
              name: "/article",
              child: ArticleView(
                index: Api.of(context).filteredIndex!,
                articleIDs: Api.of(context).filteredArticleIDs!,
              ),
            ),
        ],
      ),
    );
  }

  void _onChooseFeed(String? column, String? value) {
    Api.of(context)
        .getFilteredArticles(Api.of(context).getShowAll(), column, value)
        .then((_) {
      setState(() {});
    });
  }

  void _onChooseArticle(int index, String articleID) {
    Api.of(context).filteredIndex = index;
    // Api.of(context).setRead(articleID, true);
    setState(() {});
  }
}

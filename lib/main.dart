import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fresh_reader/view/settings_view.dart';
import 'package:sqflite/sqflite.dart';

import 'api/api.dart';
import 'api/data_types.dart';
import 'api/database.dart';
import 'view/article_list.dart';
import 'view/article_view.dart';
import 'view/feed_list.dart';

late ApiData _apiData;
late Database database;

dynamic mainLoadError;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  getDatabase().then((db) {
    database = db;
    database.query("Account").then((accounts) {
      _apiData = ApiData(
        accounts.isEmpty ? null : Account.fromMap(accounts[0]),
      );
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
          useMaterial3: true,
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
          listTileTheme: ListTileThemeData(selectedTileColor: Colors.white10),
        ),
        home: const HomeWidget(),
      ),
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

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
              Api.of(context).filteredIndex = null;
            } else if (page.name == "/list") {
              Api.of(context).filteredIndex = null;
              Api.of(context).filteredArticleIDs = null;
            }
          },
          pages: [
            MaterialPage(
              name: "/",
              child:
                  screenSizeOf(context) == ScreenSize.small
                      ? FeedList(onSelect: _onChooseFeed)
                      : Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: FeedList(onSelect: _onChooseFeed),
                          ),
                          const Expanded(flex: 2, child: ArticleList()),
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
            if (Api.of(context).account == null && Api.of(context).justBooted)
              const MaterialPage(name: "/settings", child: SettingsView()),
            if (screenSizeOf(context) == ScreenSize.small &&
                Api.of(context).filteredArticleIDs != null)
              const MaterialPage(name: "/list", child: ArticleList()),
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

  void _onChooseFeed(String? column, String? value, String title) {
    Api.of(context)
        .getFilteredArticles(Api.of(context).showAll, column, value, title)
        .then((_) {
          setState(() {});
        });
  }
}

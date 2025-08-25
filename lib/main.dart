import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import 'api/api.dart';
import 'api/data_types.dart';
import 'api/database.dart';
import 'util/formatting_setting.dart';
import 'view/settings_view.dart';
import 'view/article_list.dart';
import 'view/article_view.dart';
import 'view/feed_list.dart';

late Database database;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  getDatabase().then((db) {
    database = db;
    database.query("Account").then((accounts) {
      Account? acc;
      if (accounts.isNotEmpty) {
        try {
          acc = Account.fromMap(accounts.first);
        } catch (e, stack) {
          debugPrint(e.toString());
          debugPrintStack(stackTrace: stack);
        }
      } else {
        debugPrint("No accounts found");
      }
      runApp(MyApp(apiData: ApiData(acc)));
    });
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.apiData});
  final ApiData apiData;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Api(
      notifier: widget.apiData,
      child: Formatting(
        notifier: FormattingSetting(),
        child: MaterialApp(
          title: 'Fresh Reader',
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData(
            cupertinoOverrideTheme: CupertinoThemeData(
              primaryColor: Colors.deepPurple,
              brightness: Brightness.dark,
              textTheme: CupertinoTextThemeData(
                primaryColor: Colors.grey.shade600,
              ),
            ),
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            appBarTheme: const AppBarTheme(
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
            sliderTheme: SliderThemeData(year2023: false),
            progressIndicatorTheme: ProgressIndicatorThemeData(year2023: false),
          ),
          home: const HomeWidget(),
        ),
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
final ValueNotifier<bool> isExpanded = ValueNotifier<bool>(false);

class _HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
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
            Api.of(context).selectedIndex = null;
          } else if (page.name == "/list") {
            Api.of(context).selectedIndex = null;
            Api.of(context).filteredArticleIDs = null;
          }
        },
        pages: [
          MaterialPage(
            name: "/",
            child:
                screenSizeOf(context) != ScreenSize.big
                    ? FeedList(onSelect: _onChooseFeed)
                    : Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        SizedBox(
                          width: (MediaQuery.sizeOf(context).width / 4),
                          child: FeedList(onSelect: _onChooseFeed),
                        ),
                        Row(
                          children: [
                            ValueListenableBuilder(
                              valueListenable: isExpanded,
                              builder: (context, value, child) {
                                return AnimatedSize(
                                  duration: Duration(milliseconds: 400),
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                    width:
                                        (screenSizeOf(context) ==
                                                    ScreenSize.big &&
                                                value)
                                            ? 0.0
                                            : (MediaQuery.sizeOf(
                                                  context,
                                                ).width /
                                                4),
                                  ),
                                );
                              },
                            ),
                            // VerticalDivider(width: 1.0),
                            const Expanded(flex: 2, child: ArticleList()),
                            // VerticalDivider(width: 1.0),
                            if (screenSizeOf(context) == ScreenSize.big)
                              Expanded(
                                flex: 3,
                                child: ArticleView(
                                  key: ValueKey(Api.of(context).filteredTitle),
                                  index: Api.of(context).selectedIndex,
                                  articleIDs:
                                      Api.of(context).searchResults?.toSet(),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
          ),
          if (Api.of(context).account == null && Api.of(context).justBooted)
            screenSizeOf(context) == ScreenSize.big
                ? const MaterialPage(
                  name: "/settings",
                  fullscreenDialog: true,
                  child: SettingsDialog(),
                )
                : const MaterialPage(name: "/settings", child: SettingsPage()),
          if (screenSizeOf(context) == ScreenSize.medium &&
              Api.of(context).filteredArticleIDs != null)
            MaterialPage(
              child: Row(
                children: [
                  const Expanded(flex: 2, child: ArticleList()),
                  // VerticalDivider(width: 1),
                  Expanded(
                    flex: 3,
                    child: ArticleView(
                      key: ValueKey(Api.of(context).filteredTitle),
                      index: Api.of(context).selectedIndex,
                      articleIDs: Api.of(context).searchResults?.toSet(),
                    ),
                  ),
                ],
              ),
            ),
          if (screenSizeOf(context) == ScreenSize.small &&
              Api.of(context).filteredArticleIDs != null)
            const MaterialPage(name: "/list", child: ArticleList()),
          if (screenSizeOf(context) == ScreenSize.small &&
              Api.of(context).selectedIndex != null)
            MaterialPage(
              name: "/article",
              child: ArticleView(
                index: Api.of(context).selectedIndex ?? 0,
                articleIDs: Api.of(context).searchResults?.toSet(),
              ),
            ),
        ],
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

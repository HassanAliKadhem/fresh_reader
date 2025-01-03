import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fresh_reader/api/api.dart';

import 'api/database.dart';
import 'api/filter.dart';
import 'util/screen_size.dart';
import 'view/article_list.dart';
import 'view/article_view.dart';
import 'view/feed_list.dart';

late final AppDatabase database;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  database = AppDatabase();
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [
      SystemUiOverlay.top,
    ],
  );
  if ((await database.select(database.settings).get()).isEmpty) {
    await database.into(database.settings).insert(SettingsCompanion.insert());
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
          listTileTheme: ListTileThemeData(
            selectedTileColor: Colors.white10,
          )),
      home: const HomeWidget(),
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
final ValueNotifier<int?> articleIndex = ValueNotifier<int?>(null);

class _HomeWidgetState extends State<HomeWidget> {
  AccountData? account;
  ArticleListType? filterType;
  int? filterValue;
  bool showAll = false;
  bool showArticleView = false;

  void _onChooseAccount(AccountData accountData) {
    setState(() {
      account = accountData;
      (database.update(database.settings)
            ..where(
              (tbl) => tbl.id.equals(1),
            ))
          .write(SettingsCompanion.insert(accountId: Value(accountData.id)));
      filterType = null;
      filterValue = null;
      articleIndex.value = null;
    });
  }

  void _onChooseShowAll(bool newValue) {
    setState(() {
      articleIndex.value = null;
      showAll = newValue;
    });
  }

  void _onChooseFeed(ArticleListType? type, int? value) {
    setState(() {
      articleIndex.value = null;
      filterType = type;
      filterValue = value;
    });
  }

  @override
  void initState() {
    super.initState();
    articleIndex.addListener(
      () {
        if (articleIndex.value == null && showArticleView) {
          setState(() {
            showArticleView = false;
          });
        } else if (articleIndex.value != null && !showArticleView) {
          setState(() {
            showArticleView = true;
          });
        }
      },
    );

    database.select(database.settings).getSingle().then((settings) {
      if (settings.accountId != null) {
        (database.select(database.account)
              ..where((tbl) => tbl.id.equals(settings.accountId!)))
            .getSingle()
            .then(
          (newAccount) {
            _onChooseAccount(newAccount);
          },
        );
      }
    });
  }

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
        child: StreamBuilder<List<AccountData>>(
            stream: (database.select(database.account)
                  ..where((tbl) =>
                      tbl.id.equals(account != null ? account!.id : -1)))
                .watch(),
            builder: (context, snapshot) {
              return Filter(
                key: ValueKey(account?.hashCode),
                filterType: filterType,
                filterValue: filterValue,
                showAll: showAll,
                changeShowAll: _onChooseShowAll,
                onSelectFeed: _onChooseFeed,
                onSelectAccount: _onChooseAccount,
                api: snapshot.hasData && snapshot.data!.isNotEmpty
                    ? ApiData(snapshot.data![0])
                    : null,
                child: Navigator(
                  key: _navigatorKey,
                  onDidRemovePage: (page) {
                    if (page.name == "/article") {
                      articleIndex.value = null;
                    } else if (page.name == "/list") {
                      setState(() {
                        articleIndex.value = null;
                        _onChooseFeed(null, null);
                      });
                    }
                  },
                  pages: [
                    MaterialPage(
                      name: "/",
                      child: screenSizeOf(context) == ScreenSize.small
                          ? FeedList()
                          : Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: FeedList(),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: ArticleList(
                                      filterType: filterType,
                                      filterValue: filterValue,
                                      showAll: showAll,
                                      key: ValueKey(
                                          "$showAll-$filterType-$filterValue")),
                                ),
                                if (screenSizeOf(context) == ScreenSize.big)
                                  Expanded(
                                    flex: 3,
                                    child: showArticleView
                                        ? ArticleView(
                                            key: ValueKey(filterValue))
                                        : Container(),
                                  ),
                              ],
                            ),
                    ),
                    if (screenSizeOf(context) == ScreenSize.small &&
                        filterType != null)
                      MaterialPage(
                        name: "/list",
                        child: ArticleList(
                            filterType: filterType,
                            filterValue: filterValue,
                            showAll: showAll,
                            key: ValueKey("$showAll-$filterType-$filterValue")),
                      ),
                    if (screenSizeOf(context) != ScreenSize.big &&
                        showArticleView &&
                        filterType != null)
                      MaterialPage(
                        name: "/article",
                        child: ArticleView(key: ValueKey(filterValue)),
                      ),
                    // if (Api.of(context).server == "" && Api.of(context).justBooted)
                    //   const MaterialPage(
                    //     name: "/settings",
                    //     child: SettingsView(),
                    //   ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}

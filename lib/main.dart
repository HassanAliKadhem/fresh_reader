import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:provider/provider.dart';

import 'api/data.dart';
import 'api/database.dart';
import 'api/preferences.dart';
import 'util/screen_size.dart';
import 'view/article_list.dart';
import 'view/article_view.dart';
import 'view/feed_list.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  getDatabase()
      .then((db) async {
        StorageSqlite database = StorageSqlite(db);
        Preferences pref = Preferences(database);
        DataProvider data = DataProvider(database);
        await pref.load();
        data.setShowAll(pref.showAll);
        runApp(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<DataProvider>(create: (context) => data),
              ChangeNotifierProvider<Preferences>(create: (context) => pref),
            ],
            child: MyApp(),
          ),
        );
      })
      .catchError((error) {
        // show error if can't open database
        debugPrint(error.toString());
        runApp(
          MaterialApp(
            home: Scaffold(body: Center(child: Text(error.toString()))),
          ),
        );
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
    Color? surfaceColor =
        context.select<Preferences, bool>(
          (a) => a.themeIndex == 1 || a.themeIndex == 3,
        )
        ? Colors.black
        : null;
    ThemeMode themeMode = [
      ThemeMode.dark,
      ThemeMode.dark,
      ThemeMode.system,
      ThemeMode.system,
      ThemeMode.light,
    ][context.select<Preferences, int>((a) => a.themeIndex)];
    bool useDynamicColor = context.select<Preferences, bool>(
      (a) => a.themeDynamic,
    );
    Color seedColor = Color(
      context.select<Preferences, int>((a) => a.themeColor),
    );
    ColorScheme fallbackDarkScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    ColorScheme fallbackLightScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
    );
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'Fresh Reader',
          themeMode: themeMode,
          theme: withM3ETheme(
            ThemeData(
              cupertinoOverrideTheme: CupertinoThemeData(
                primaryColor: seedColor,
                brightness: Brightness.light,
                textTheme: CupertinoTextThemeData(
                  primaryColor: Colors.grey.shade600,
                ),
              ),
              useMaterial3: true,
              colorScheme: (useDynamicColor
                  ? lightDynamic?.harmonized() ?? fallbackLightScheme
                  : fallbackLightScheme),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                scrolledUnderElevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  systemStatusBarContrastEnforced: false,
                  statusBarIconBrightness: Brightness.dark,
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarDividerColor: Colors.transparent,
                  systemNavigationBarContrastEnforced: false,
                  systemNavigationBarIconBrightness: Brightness.dark,
                ),
              ),
              listTileTheme: ListTileThemeData(
                selectedTileColor: Colors.white70,
              ),
              sliderTheme: SliderThemeData(year2023: false),
              progressIndicatorTheme: ProgressIndicatorThemeData(
                year2023: false,
              ),
            ),
          ),
          darkTheme: withM3ETheme(
            ThemeData(
              cupertinoOverrideTheme: CupertinoThemeData(
                primaryColor: seedColor,
                brightness: Brightness.dark,
                textTheme: CupertinoTextThemeData(
                  primaryColor: Colors.grey.shade600,
                ),
              ),
              useMaterial3: true,
              colorScheme:
                  (useDynamicColor
                          ? darkDynamic?.harmonized() ?? fallbackDarkScheme
                          : fallbackDarkScheme)
                      .copyWith(surface: surfaceColor),
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
              listTileTheme: ListTileThemeData(
                selectedTileColor: Colors.white10,
              ),
              sliderTheme: SliderThemeData(year2023: false),
              progressIndicatorTheme: ProgressIndicatorThemeData(
                year2023: false,
              ),
            ),
          ),
          home: const HomeWidget(),
        );
      },
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
    String? filteredTitle = context.select<DataProvider, String?>(
      (a) => a.filteredTitle,
    );
    bool isIndexSelected = context.select<DataProvider, bool>(
      (a) => a.selectedIndex != null,
    );
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
            context.read<DataProvider>().setSelectedIndex(null, null, true);
          } else if (page.name == "/list") {
            context.read<DataProvider>().setSelectedIndex(null, null, true);
            context.read<DataProvider>().clearFiltered();
          }
        },
        pages: [
          MaterialPage(
            name: "/",
            child: screenSizeOf(context) != ScreenSize.big
                ? const FeedList()
                : Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      SizedBox(
                        width: (MediaQuery.sizeOf(context).width / 4),
                        child: const FeedList(),
                      ),
                      Row(
                        children: [
                          ValueListenableBuilder(
                            valueListenable: isExpanded,
                            builder: (context, value, child) {
                              return AnimatedSize(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width:
                                      (screenSizeOf(context) ==
                                              ScreenSize.big &&
                                          value)
                                      ? 0.0
                                      : (MediaQuery.sizeOf(context).width / 4),
                                ),
                              );
                            },
                          ),
                          // VerticalDivider(width: 1.0),
                          Expanded(
                            flex: 2,
                            child: ArticleList(key: ValueKey(filteredTitle)),
                          ),
                          // VerticalDivider(width: 1.0),
                          if (screenSizeOf(context) == ScreenSize.big)
                            Expanded(
                              flex: 3,
                              child: isIndexSelected
                                  ? articleView()
                                  : const Scaffold(
                                      body: Center(
                                        child: Text("Please select an article"),
                                      ),
                                    ),
                            ),
                        ],
                      ),
                    ],
                  ),
          ),
          if (screenSizeOf(context) == ScreenSize.medium &&
              filteredTitle != null)
            MaterialPage(
              child: Row(
                children: [
                  const Expanded(flex: 2, child: ArticleList()),
                  // VerticalDivider(width: 1),
                  Expanded(
                    flex: 3,
                    child: isIndexSelected
                        ? articleView()
                        : const Scaffold(
                            body: Center(
                              child: Text("Please select an article"),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          if (screenSizeOf(context) == ScreenSize.small &&
              filteredTitle != null)
            const MaterialPage(name: "/list", child: ArticleList()),
          if (screenSizeOf(context) == ScreenSize.small && isIndexSelected)
            MaterialPage(name: "/article", child: articleView()),
        ],
      ),
    );
  }

  Widget articleView() {
    Set<String>? ids = context
        .select<DataProvider, List<String>?>((a) => a.searchResults)
        ?.toSet();
    return ArticleView(
      key: ValueKey(ids),
      index: context.read<DataProvider>().selectedIndex,
      articleIDs: ids,
    );
  }
}

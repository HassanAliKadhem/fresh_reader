import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'api/api.dart';
import 'api/database.dart';
import 'util/formatting_setting.dart';
import 'util/screen_size.dart';
import 'view/article_list.dart';
import 'view/article_view.dart';
import 'view/feed_list.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  getDatabase()
      .then((db) {
        DB database = DB(db);
        runApp(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<Api>(create: (context) => Api(database)),
              ChangeNotifierProvider<Preferences>(
                create: (context) => Preferences(database),
              ),
            ],
            child: MyApp(),
          ),
        );
      })
      .catchError((error) {
        // show error if can't open database
        debugPrint(error.toString());
        runApp(MaterialApp(home: Center(child: Text(error.toString()))));
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
    return MaterialApp(
      title: 'Fresh Reader',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        cupertinoOverrideTheme: CupertinoThemeData(
          primaryColor: Colors.deepPurple,
          brightness: Brightness.dark,
          textTheme: CupertinoTextThemeData(primaryColor: Colors.grey.shade600),
        ),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
          surface:
              [null, Colors.black][context.select<Preferences, int>(
                (a) => a.themeIndex,
              )], // for AMOLED black
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
            context.read<Api>().setSelectedIndex(null, null, true);
          } else if (page.name == "/list") {
            context.read<Api>().setSelectedIndex(null, null, true);
            context.read<Api>().filteredArticleIDs = null;
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
                                duration: Duration(milliseconds: 400),
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
                          const Expanded(flex: 2, child: ArticleList()),
                          // VerticalDivider(width: 1.0),
                          if (screenSizeOf(context) == ScreenSize.big)
                            Expanded(
                              flex: 3,
                              child:
                                  context.select<Api, bool>(
                                    (a) => a.selectedIndex != null,
                                  )
                                  ? articleView()
                                  : Scaffold(
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
              context.select<Api, Set<String>?>((a) => a.filteredArticleIDs) !=
                  null)
            MaterialPage(
              child: Row(
                children: [
                  const Expanded(flex: 2, child: ArticleList()),

                  // VerticalDivider(width: 1),
                  Expanded(
                    flex: 3,
                    child:
                        context.select<Api, bool>(
                          (a) => a.selectedIndex != null,
                        )
                        ? articleView()
                        : Scaffold(
                            body: Center(
                              child: Text("Please select an article"),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          if (screenSizeOf(context) == ScreenSize.small &&
              context.select<Api, Set<String>?>((a) => a.filteredArticleIDs) !=
                  null)
            const MaterialPage(name: "/list", child: ArticleList()),
          if (screenSizeOf(context) == ScreenSize.small &&
              context.select<Api, bool>((a) => a.selectedIndex != null))
            MaterialPage(name: "/article", child: articleView()),
        ],
      ),
    );
  }

  Widget articleView() {
    return ArticleView(
      key: ValueKey(context.select<Api, String?>((a) => a.filteredTitle)),
      index: context.read<Api>().selectedIndex,
      articleIDs: context
          .select<Api, List<String>?>((a) => a.searchResults)
          ?.toSet(),
    );
  }
}

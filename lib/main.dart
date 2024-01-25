import 'package:flutter/material.dart';

import 'api.dart';
import 'feed_list.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Api(
      notifier: ApiData()..storageLoad(),
      child: MaterialApp(
        title: 'FreshReader',
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          appBarTheme: const AppBarTheme(backgroundColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const FeedList(title: 'FreshReader'),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fresh_reader/api.dart';
import 'package:fresh_reader/feed_list.dart';

Api api = Api();

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreshReader',
      scrollBehavior: const CupertinoScrollBehavior(),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder(
          future: api.test(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FeedList(title: 'FreshReader', api: api);
            } else {
              return Scaffold(
                appBar: AppBar(
                  title: const Text("FreshReader"),
                ),
                  body: const Center(
                child: CircularProgressIndicator.adaptive(),
              ));
            }
          }),
    );
  }
}

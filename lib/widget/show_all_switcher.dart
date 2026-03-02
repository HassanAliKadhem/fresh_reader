import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/data.dart';

class ShowAllSwitcherWidget extends StatelessWidget {
  const ShowAllSwitcherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    bool showAll = context.select<DataProvider, bool>((a) => a.showAll);
    return PopupMenuButton<bool>(
      initialValue: showAll,
      icon: Icon(showAll ? Icons.circle_outlined : Icons.circle),
      itemBuilder: (context) {
        return [
          PopupMenuItem<bool>(
            value: true,
            child: Row(
              mainAxisSize: .min,
              spacing: 8.0,
              children: [Icon(Icons.circle_outlined), Text("All Articles")],
            ),
          ),
          PopupMenuItem<bool>(
            value: false,
            child: Row(
              mainAxisSize: .min,
              spacing: 8.0,
              children: [Icon(Icons.circle), Text("Only Unread")],
            ),
          ),
        ];
      },
      onSelected: (show) {
        context.read<DataProvider>().setShowAll(show);
      },
    );
  }
}

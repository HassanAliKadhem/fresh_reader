import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/data.dart';
import '../api/preferences.dart';

class ShowAllSwitcherWidget extends StatelessWidget {
  const ShowAllSwitcherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    bool showAll = context.select<DataProvider, bool>((a) => a.showAll);
    return PopupMenuButton<bool>(
      initialValue: showAll,
      icon: Icon(showAll ? Icons.radio_button_off : Icons.radio_button_on),
      itemBuilder: (context) {
        return [
          PopupMenuItem<bool>(
            value: true,
            child: Row(
              mainAxisSize: .min,
              spacing: 8.0,
              children: [Icon(Icons.radio_button_off), Text("All Articles")],
            ),
          ),
          PopupMenuItem<bool>(
            value: false,
            child: Row(
              mainAxisSize: .min,
              spacing: 8.0,
              children: [Icon(Icons.radio_button_on), Text("Only Unread")],
            ),
          ),
        ];
      },
      onSelected: (show) {
        context.read<DataProvider>().setShowAll(show);
        context.read<Preferences>().setShowAll(show);
      },
    );
  }
}

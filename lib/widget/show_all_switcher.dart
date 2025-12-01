import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api.dart';

class ShowAllSwitcherWidget extends StatelessWidget {
  const ShowAllSwitcherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    bool showAll = context.select<Api, bool>((a) => a.showAll);
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          onPressed: () {
            context.read<Api>().setShowAll(true);
          },
          trailingIcon: Icon(Icons.circle_outlined),
          child: Text("All Articles"),
        ),
        MenuItemButton(
          onPressed: () {
            context.read<Api>().setShowAll(false);
          },
          trailingIcon: Icon(Icons.circle),
          child: Text("Only Unread"),
        ),
      ],
      builder: (_, MenuController controller, Widget? child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: Icon(showAll ? Icons.circle_outlined : Icons.circle),
        );
      },
    );
  }
}

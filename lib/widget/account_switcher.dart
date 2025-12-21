import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/data.dart';
import '../view/settings_view.dart';

class AccountSwitcherWidget extends StatelessWidget {
  const AccountSwitcherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<DataProvider>().getAccounts(),
      builder: (context, accountSnapshot) {
        if (!accountSnapshot.hasData) {
          return CircularProgressIndicator.adaptive();
        }
        return MenuAnchor(
          menuChildren: accountSnapshot.data!.isEmpty
              ? [
                  MenuItemButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return SettingsPage();
                        },
                      );
                    },
                    trailingIcon: Icon(Icons.add),
                    child: Text("Click here to add account"),
                  ),
                ]
              : accountSnapshot.data!
                    .map(
                      (account) => MenuItemButton(
                        onPressed: () {
                          context.read<DataProvider>().changeAccount(account);
                        },
                        leadingIcon: Icon(
                          context.read<DataProvider>().accountID == account.id
                              ? Icons.check
                              : null,
                        ),
                        child: Text("${account.username}: ${account.provider}"),
                      ),
                    )
                    .toList(),
          builder: (_, MenuController controller, Widget? child) {
            return IconButton(
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              icon: const Icon(Icons.account_circle),
            );
          },
        );
      },
    );
  }
}

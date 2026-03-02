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
        return PopupMenuButton<int?>(
          initialValue: context.read<DataProvider>().accountID,
          icon: Icon(Icons.account_circle),
          itemBuilder: (context) {
            return accountSnapshot.data!.isEmpty
                ? [
                    PopupMenuItem<int?>(
                      value: null,
                      child: Text("Add new account"),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return SettingsPage();
                          },
                        );
                      },
                    ),
                  ]
                : accountSnapshot.data!
                      .map(
                        (item) => PopupMenuItem<int?>(
                          value: item.id,
                          // child: Text("${item.username} : ${item.provider}"),
                          child: Text(item.username),
                          onTap: () {
                            context.read<DataProvider>().changeAccount(item);
                          },
                        ),
                      )
                      .toList();
          },
        );
      },
    );
  }
}

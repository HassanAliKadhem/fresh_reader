import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/data.dart';
import '../api/data_types.dart';
import 'adaptive_text_field.dart';

class AccountDetails extends StatelessWidget {
  const AccountDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.watch<DataProvider>().getAccounts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return LinearProgressIndicator();
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: snapshot.data!.map((acc) {
            return AccountCard(account: acc);
          }).toList(),
        );
      },
    );
  }
}

class AccountCard extends StatefulWidget {
  const AccountCard({super.key, required this.account});
  final Account account;

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  late Account account = widget.account;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(8.0),
      child: ExpansionTile(
        key: PageStorageKey('accountTile_${account.id}'),
        shape: const Border(),
        title: Text("${account.provider}: ${account.username}"),
        subtitle: Text(account.serverUrl.toString()),
        children: [
          ListTile(
            title: Text("Edit account"),
            trailing: Icon(Icons.edit),
            onTap: () {
              showAdaptiveDialog(
                context: context,
                builder: (context) {
                  return AddAccountDialog(oldAccount: account);
                },
              ).then((onValue) {
                if (onValue != null && onValue is Account) {
                  if (context.mounted &&
                      onValue.id == context.read<DataProvider>().accountID) {
                    context.read<DataProvider>().changeAccount(onValue);
                  } else {
                    debugPrint("Context not mounted");
                    setState(() {
                      account = onValue;
                    });
                  }
                }
              });
            },
          ),
          ListTile(
            title: const Text("Delete Data or Account"),
            trailing: Icon(Icons.delete),
            onTap: () async {
              showAdaptiveDialog(
                context: context,
                builder: (context) {
                  return AlertDialog.adaptive(
                    title: const Text("Are you sure?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, "account");
                        },
                        child: Text(
                          "Delete Account",
                          style: TextStyle(color: Colors.red[300]),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, "data");
                        },
                        child: Text(
                          "Delete only data",
                          style: TextStyle(color: Colors.red[300]),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                    ],
                  );
                },
              ).then((value) {
                if (context.mounted) {
                  if (value == "account") {
                    context.read<DataProvider>().deleteAccount(account.id);
                  } else if (value == "data") {
                    context.read<DataProvider>().deleteAccountData(account.id);
                  }
                }
                setState(() {});
              });
            },
          ),
          ListTile(
            title: FutureBuilder(
              future: context.read<DataProvider>().db.loadArticleMetaData(
                account.id,
              ),
              builder: (context, asyncSnapshot) {
                return Text(
                  "Total articles: ${asyncSnapshot.data?.length ?? 0}, Unread: ${asyncSnapshot.data?.values.where((a) => !a.$3).length ?? 0}",
                );
              },
            ),
            subtitle: FutureBuilder(
              future: Future.wait([
                context.read<DataProvider>().db.loadAllCategory(account.id),
                context.read<DataProvider>().db.loadAllSubs(account.id),
              ]),
              builder: (context, asyncSnapshot) {
                return Text(
                  "categories: ${asyncSnapshot.data?[0].length ?? 0}, subscriptions: ${asyncSnapshot.data?[1].length ?? 0}",
                );
              },
            ),
          ),
          ListTile(
            title: const Text("Last sync articles time"),
            subtitle: Text(
              DateTime.fromMillisecondsSinceEpoch(
                account.updatedArticleTime * 1000,
              ).toString(),
            ),
            onTap: () {
              showDatePicker(
                context: context,
                firstDate: DateTime(0),
                lastDate: DateTime.now(),
                initialDate: DateTime.fromMillisecondsSinceEpoch(
                  account.updatedArticleTime * 1000,
                ),
              ).then((value) {
                if (value != null) {
                  int newTime = (value.millisecondsSinceEpoch / 1000).floor();
                  context.read<DataProvider>().db.updateAccount(
                    account.copyWith(updatedArticleTime: newTime),
                  );
                  setState(() {
                    account.updatedArticleTime = newTime;
                  });
                }
              });
            },
          ),
          ListTile(
            title: const Text("Last sync starred time"),
            subtitle: Text(
              DateTime.fromMillisecondsSinceEpoch(
                account.updatedStarredTime * 1000,
              ).toString(),
            ),
            onTap: () {
              showDatePicker(
                context: context,
                firstDate: DateTime(0),
                lastDate: DateTime.now(),
                initialDate: DateTime.fromMillisecondsSinceEpoch(
                  account.updatedStarredTime * 1000,
                ),
              ).then((value) {
                if (value != null) {
                  int newTime = (value.millisecondsSinceEpoch / 1000).floor();
                  context.read<DataProvider>().db.updateAccount(
                    account.copyWith(updatedStarredTime: newTime),
                  );
                  setState(() {
                    account.updatedStarredTime = newTime;
                  });
                }
              });
            },
          ),
        ],
      ),
    );
  }
}

class AddAccountDialog extends StatefulWidget {
  const AddAccountDialog({super.key, this.oldAccount});
  final Account? oldAccount;

  @override
  State<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<AddAccountDialog> {
  late var newAccount = widget.oldAccount != null
      ? widget.oldAccount!
      : Account(0, "", "Freshrss", "", "", 0, 0);

  Future<int> _addAccount(Account accountToAdd) async {
    int index = -1;
    if (widget.oldAccount != null) {
      await context.read<DataProvider>().db.updateAccount(accountToAdd);
      index = accountToAdd.id;
    } else {
      index = await context.read<DataProvider>().db.addAccount(accountToAdd);
    }
    return index;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.oldAccount != null ? "Update Account" : "Add Account"),
      scrollable: true,
      content: Column(
        spacing: 8.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Provider"),
          RadioGroup(
            groupValue: newAccount.provider,
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  newAccount = newAccount.copyWith(provider: value);
                });
              }
            },
            child: Column(
              children: [
                RadioListTile.adaptive(
                  title: const Text('Freshrss'),
                  value: "Freshrss",
                ),
                // RadioListTile.adaptive(
                //   title: const Text('InoReader'),
                //   value: "InoReader",
                // ),
              ],
            ),
          ),
          Text("Connection details"),
          AdaptiveTextField(
            label: "Server Url",
            initialValue: newAccount.serverUrl,
            inputType: TextInputType.url,
            onChanged: (value) {
              newAccount = newAccount.copyWith(serverUrl: value);
            },
          ),
          AdaptiveTextField(
            label: "User Name",
            initialValue: newAccount.username,
            inputType: TextInputType.text,
            onChanged: (value) {
              newAccount = newAccount.copyWith(username: value);
            },
          ),
          AdaptiveTextField(
            label: "Password",
            initialValue: newAccount.password,
            obscureText: true,
            onChanged: (value) {
              newAccount = newAccount.copyWith(password: value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),
        FilledButton(
          onPressed: () async {
            int index = await _addAccount(newAccount);
            if (context.mounted) {
              Navigator.pop(context, newAccount.copyWith(id: index));
            } else {
              debugPrint("Context not mounted");
            }
          },
          child: Text(widget.oldAccount != null ? "Update" : "Add"),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fresh_reader/main.dart';
import 'package:fresh_reader/widget/adaptive_text_field.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api.dart';
import '../api/data_types.dart';
import '../api/database.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding:
          screenSizeOf(context) != ScreenSize.big
              ? EdgeInsets.all(32.0)
              : EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width / 4,
                vertical: MediaQuery.sizeOf(context).height / 10,
              ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Accounts'),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text("Add new account"),
              onTap: () {
                showAdaptiveDialog(
                  context: context,
                  builder: (context) {
                    return AddAccountDialog();
                  },
                ).then((onValue) {
                  if (onValue != null && onValue is Account) {
                    Api.of(context).changeAccount(onValue);
                  }
                  setState(() {});
                });
              },
              trailing: Icon(Icons.add),
            ),
            FutureBuilder(
              future: database.query("Account"),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return CircularProgressIndicator.adaptive();
                }
                return Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: ExpansionTile(
                          shape: const Border(),
                          title: Text(
                            "${snapshot.data![index]["provider"]}: ${snapshot.data![index]["username"]}",
                          ),
                          subtitle: Text(
                            snapshot.data![index]["serverUrl"].toString(),
                          ),
                          children: [
                            ListTile(
                              title: Text("Edit account"),
                              trailing: Icon(Icons.edit),
                              onTap: () {
                                showAdaptiveDialog(
                                  context: context,
                                  builder: (context) {
                                    return AddAccountDialog(
                                      oldAccount: Account.fromMap(
                                        snapshot.data![index],
                                      ),
                                    );
                                  },
                                ).then((onValue) {
                                  // if (onValue != null &&
                                  //     onValue is AccountData) {
                                  //   widget.chooseAccount(onValue);
                                  // }
                                });
                              },
                            ),
                            FutureBuilder(
                              future: countAllArticles(
                                true,
                                snapshot.data![index]["id"] as int,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState !=
                                    ConnectionState.done) {
                                  return CircularProgressIndicator.adaptive();
                                }
                                return ListTile(
                                  title: Text(
                                    "Total articles: ${snapshot.data!.values.reduce((count, value) => count + value)}",
                                  ),
                                  // subtitle: Text(
                                  //     "categories: ${snapshot.data!.entries.map((entry) => entry.key.startsWith("feed/") ? 0 : 1).reduce((count, value) => count + value)}, subscriptions: ${snapshot.data!.entries.map((entry) => entry.key.startsWith("feed/") ? 1 : 0).reduce((count, value) => count + value)}"),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text("Last sync articles time"),
                              subtitle: Text(
                                DateTime.fromMillisecondsSinceEpoch(
                                  (snapshot.data![index]["updatedArticleTime"]
                                          as int) *
                                      1000,
                                ).toString(),
                              ),
                              onTap: () {
                                showDatePicker(
                                  context: context,
                                  firstDate: DateTime(0),
                                  lastDate: DateTime.now(),
                                  initialDate: DateTime.fromMillisecondsSinceEpoch(
                                    (snapshot.data![index]["updatedArticleTime"]
                                            as int) *
                                        1000,
                                  ),
                                ).then((value) {
                                  if (value != null) {
                                    database.update(
                                      "Account",
                                      {
                                        "updatedArticleTime":
                                            (value.millisecondsSinceEpoch /
                                                    1000)
                                                .floor(),
                                      },
                                      where: "id = ?",
                                      whereArgs: [snapshot.data![index]["id"]],
                                    );
                                    setState(() {});
                                  }
                                });
                              },
                            ),
                            ListTile(
                              title: const Text("Last sync starred time"),
                              subtitle: Text(
                                DateTime.fromMillisecondsSinceEpoch(
                                  (snapshot.data![index]["updatedStarredTime"]
                                          as int) *
                                      1000,
                                ).toString(),
                              ),
                              onTap: () {
                                showDatePicker(
                                  context: context,
                                  firstDate: DateTime(0),
                                  lastDate: DateTime.now(),
                                  initialDate: DateTime.fromMillisecondsSinceEpoch(
                                    (snapshot.data![index]["updatedStarredTime"]
                                            as int) *
                                        1000,
                                  ),
                                ).then((value) {
                                  if (value != null) {
                                    database.update(
                                      "Account",
                                      {
                                        "updatedStarredTime":
                                            (value.millisecondsSinceEpoch /
                                                    1000)
                                                .floor(),
                                      },
                                      where: "id = ?",
                                      whereArgs: [snapshot.data![index]["id"]],
                                    );
                                    setState(() {});
                                  }
                                });
                              },
                            ),
                            ListTile(
                              title: const Text("Delete Data or Account"),
                              onTap: () async {
                                showAdaptiveDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog.adaptive(
                                      title: const Text("Are you sure?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            int accountID =
                                                snapshot.data![index]["id"]
                                                    as int;
                                            // Filter.of(context).api.account.id;
                                            database.delete(
                                              "Article",
                                              where: "accountID = ?",
                                              whereArgs: [accountID],
                                            );
                                            database.delete(
                                              "Categories",
                                              where: "accountID = ?",
                                              whereArgs: [accountID],
                                            );
                                            database.delete(
                                              "Subscriptions",
                                              where: "accountID = ?",
                                              whereArgs: [accountID],
                                            );
                                            database.delete(
                                              "DelayedActions",
                                              where: "accountID = ?",
                                              whereArgs: [accountID],
                                            );
                                            database.delete(
                                              "Account",
                                              where: "id = ?",
                                              whereArgs: [accountID],
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Account Deleted",
                                                ),
                                              ),
                                            );
                                            Navigator.pop(context);
                                            if (Api.of(context).account?.id ==
                                                accountID) {
                                              database
                                                  .query(
                                                    "Account",
                                                    where: "id = ?",
                                                    whereArgs: [accountID],
                                                  )
                                                  .then((onValue) {
                                                    Api.of(
                                                      context,
                                                    ).changeAccount(
                                                      Account.fromMap(
                                                        onValue.first,
                                                      ),
                                                    );
                                                  });
                                            }
                                            setState(() {});
                                          },
                                          child: Text(
                                            "Delete Account",
                                            style: TextStyle(
                                              color: Colors.red[300],
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            int accountID =
                                                snapshot.data![index]["id"]
                                                    as int;
                                            // Filter.of(context).api.account.id;
                                            database.delete(
                                              "Articles",
                                              where: "accountID = ?",
                                              whereArgs: [accountID],
                                            );
                                            database.delete(
                                              "Categories",
                                              where: "accountID = ?",
                                              whereArgs: [accountID],
                                            );
                                            database.delete(
                                              "Subscriptions",
                                              where: "accountID = ?",
                                              whereArgs: [accountID],
                                            );
                                            database.delete(
                                              "DelayedActions",
                                              where: "accountID = ?",
                                              whereArgs: [accountID],
                                            );
                                            database.update(
                                              "Account",
                                              {
                                                "updatedStarredTime": 0,
                                                "updatedArticleTime": 0,
                                              },
                                              where: "id = ?",
                                              whereArgs: [accountID],
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text("Data Cleared"),
                                              ),
                                            );
                                            Navigator.pop(context);
                                            if (Api.of(context).account?.id ==
                                                accountID) {
                                              database
                                                  .query(
                                                    "Account",
                                                    where: "id = ?",
                                                    whereArgs: [accountID],
                                                  )
                                                  .then((onValue) {
                                                    Api.of(
                                                      context,
                                                    ).changeAccount(
                                                      Account.fromMap(
                                                        onValue.first,
                                                      ),
                                                    );
                                                  });
                                            }
                                            setState(() {});
                                          },
                                          child: Text(
                                            "Delete only data",
                                            style: TextStyle(
                                              color: Colors.red[300],
                                            ),
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
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const Divider(indent: 8.0, endIndent: 8.0),
            AboutListTile(
              applicationVersion: "1.2.1",
              aboutBoxChildren: [
                const ListTile(
                  title: Text("Made By"),
                  subtitle: Text("Hasan Kadhem"),
                ),
                ListTile(
                  title: const Text("Source Code"),
                  subtitle: const Text(
                    "https://github.com/HassanAliKadhem/fresh_reader",
                  ),
                  trailing: const Icon(Icons.open_in_browser),
                  onTap:
                      () => launchUrl(
                        Uri.parse(
                          "https://github.com/HassanAliKadhem/fresh_reader",
                        ),
                      ),
                ),
              ],
            ),
          ],
        ),
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
  late var newAccount =
      widget.oldAccount != null
          ? widget.oldAccount!
          : Account(0, "", "Freshrss", "", "", 0, 0);

  Future<int> addAccount(Account accountToAdd) async {
    int index = -1;
    if (widget.oldAccount != null) {
      database.update("Account", accountToAdd.toMap());
      index = accountToAdd.id;
    } else {
      index = await database.insert(
        "Account",
        accountToAdd.toMap()..remove("id"),
      );
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
          RadioListTile.adaptive(
            contentPadding: EdgeInsets.all(0.0),
            title: const Text('Freshrss'),
            value: "Freshrss",
            groupValue: newAccount.provider,
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  newAccount = newAccount.copyWith(provider: value);
                });
              }
            },
          ),
          // RadioListTile(
          //   title: const Text('InoReader'),
          //   value: "InoReader",
          //   groupValue: newAcount.serverUrl.value,
          //   onChanged: (String? value) {
          //     if (value != null) {
          //       setState(() {
          //         newAcount =
          //             newAcount.copyWith(serverUrl: drift.Value<String>(value));
          //       });
          //     }
          //   },
          // ),
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
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll<Color>(Colors.red),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            int index = await addAccount(newAccount);
            Navigator.pop(context, newAccount.copyWith(id: index));
          },
          child: Text(widget.oldAccount != null ? "Update" : "Add"),
        ),
      ],
    );
  }
}

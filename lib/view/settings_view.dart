import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:fresh_reader/api/database.dart';
import 'package:fresh_reader/main.dart';
import 'package:fresh_reader/widget/adaptive_text_field.dart';
import 'package:url_launcher/url_launcher.dart';

import '../util/screen_size.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({
    super.key,
    required this.currentAccount,
    required this.chooseAccount,
  });
  final int? currentAccount;
  final Function(AccountData) chooseAccount;
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: screenSizeOf(context) != ScreenSize.big
          ? EdgeInsets.all(32.0)
          : EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).width / 4,
              vertical: MediaQuery.sizeOf(context).height / 10),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Accounts'),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.close)),
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
                  if (onValue != null && onValue is AccountData) {
                    widget.chooseAccount(onValue);
                  }
                });
              },
              trailing: Icon(Icons.add),
            ),
            StreamBuilder<List<AccountData>>(
                stream: database.select(database.account).watch(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
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
                            title: Text(snapshot.data![index].provider),
                            subtitle: Text(snapshot.data![index].serverUrl),
                            children: [
                              ListTile(
                                title: Text("Edit account"),
                                trailing: Icon(Icons.edit),
                                onTap: () {
                                  showAdaptiveDialog(
                                    context: context,
                                    builder: (context) {
                                      return AddAccountDialog(
                                        oldAccount: snapshot.data![index],
                                      );
                                    },
                                  ).then((onValue) {
                                    if (onValue != null &&
                                        onValue is AccountData) {
                                      widget.chooseAccount(onValue);
                                    }
                                  });
                                },
                              ),
                              // ListTile(
                              //   title: const Text("Total articles"),
                              //   subtitle: Text("0"),
                              // ),
                              ListTile(
                                title: const Text("Last sync articles time"),
                                subtitle: Text(
                                    DateTime.fromMillisecondsSinceEpoch(snapshot
                                                .data![index]
                                                .updatedArticleTime *
                                            1000)
                                        .toString()),
                                onTap: () {
                                  showDatePicker(
                                    context: context,
                                    firstDate: DateTime(0),
                                    lastDate: DateTime.now(),
                                    initialDate:
                                        DateTime.fromMillisecondsSinceEpoch(
                                            snapshot.data![index]
                                                    .updatedArticleTime *
                                                1000),
                                  ).then((value) {
                                    if (value != null) {
                                      (database.update(database.account)
                                            ..where(
                                              (tbl) => tbl.id.equals(
                                                  snapshot.data![index].id),
                                            ))
                                          .write(AccountCompanion(
                                              updatedArticleTime: drift.Value(
                                                  (value.millisecondsSinceEpoch /
                                                          1000)
                                                      .floor())));
                                    }
                                  });
                                },
                              ),
                              ListTile(
                                title: const Text("Last sync starred time"),
                                subtitle: Text(
                                    DateTime.fromMillisecondsSinceEpoch(snapshot
                                                .data![index]
                                                .updatedStarredTime *
                                            1000)
                                        .toString()),
                                onTap: () {
                                  showDatePicker(
                                    context: context,
                                    firstDate: DateTime(0),
                                    lastDate: DateTime.now(),
                                    initialDate:
                                        DateTime.fromMillisecondsSinceEpoch(
                                            snapshot.data![index]
                                                    .updatedStarredTime *
                                                1000),
                                  ).then((value) {
                                    if (value != null) {
                                      (database.update(database.account)
                                            ..where(
                                              (tbl) => tbl.id.equals(
                                                  snapshot.data![index].id),
                                            ))
                                          .write(AccountCompanion(
                                              updatedStarredTime: drift.Value(
                                                  (value.millisecondsSinceEpoch /
                                                          1000)
                                                      .floor())));
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
                                                  snapshot.data![index].id;
                                              // Filter.of(context).api.account.id;
                                              database
                                                  .delete(database.article)
                                                  .where(
                                                    (tbl) => tbl.account
                                                        .equals(accountID),
                                                  );
                                              database
                                                  .delete(database.category)
                                                  .where(
                                                    (tbl) => tbl.account
                                                        .equals(accountID),
                                                  );
                                              database
                                                  .delete(database.subscription)
                                                  .where(
                                                    (tbl) => tbl.account
                                                        .equals(accountID),
                                                  );
                                              database
                                                  .delete(database.delayed)
                                                  .where(
                                                    (tbl) => tbl.account
                                                        .equals(accountID),
                                                  );
                                              database
                                                  .delete(database.account)
                                                  .where(
                                                    (tbl) => tbl.id
                                                        .equals(accountID),
                                                  );

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content:
                                                      Text("Account Deleted"),
                                                ),
                                              );
                                              Navigator.pop(context);
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
                                                  snapshot.data![index].id;
                                              database
                                                  .delete(database.article)
                                                  .where(
                                                    (tbl) => tbl.account
                                                        .equals(accountID),
                                                  );
                                              database
                                                  .delete(database.category)
                                                  .where(
                                                    (tbl) => tbl.account
                                                        .equals(accountID),
                                                  );
                                              database
                                                  .delete(database.subscription)
                                                  .where(
                                                    (tbl) => tbl.account
                                                        .equals(accountID),
                                                  );
                                              database
                                                  .delete(database.delayed)
                                                  .where(
                                                    (tbl) => tbl.account
                                                        .equals(accountID),
                                                  );
                                              (database.update(database.account)
                                                    ..where(
                                                      (tbl) => tbl.id.equals(
                                                          snapshot
                                                              .data![index].id),
                                                    ))
                                                  .write(AccountCompanion(
                                                updatedStarredTime:
                                                    drift.Value(0),
                                                updatedArticleTime:
                                                    drift.Value(0),
                                              ));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text("Data Cleared"),
                                                ),
                                              );
                                              Navigator.pop(context);
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
                                          )
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
                }),
            const Divider(
              indent: 8.0,
              endIndent: 8.0,
            ),
            AboutListTile(
              applicationVersion: "1.2.0",
              aboutBoxChildren: [
                const ListTile(
                  title: Text("Made By"),
                  subtitle: Text("Hasan Kadhem"),
                ),
                ListTile(
                  title: const Text("Source Code"),
                  subtitle: const Text(
                      "https://github.com/HassanAliKadhem/fresh_reader"),
                  trailing: const Icon(Icons.open_in_browser),
                  onTap: () => launchUrl(Uri.parse(
                      "https://github.com/HassanAliKadhem/fresh_reader")),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Future<dynamic> showValueChangerDialog({
  //   required BuildContext context,
  //   required String title,
  //   String currentValue = "",
  //   bool hide = false,
  // }) {
  //   String newValue = currentValue;
  //   TextEditingController textEditingController =
  //       TextEditingController(text: newValue);
  //   return showDialog<String?>(
  //     barrierDismissible: true,
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text(title),
  //         content: TextField(
  //           controller: textEditingController,
  //           obscureText: hide,
  //           onChanged: (value) => newValue = value,
  //         ),
  //         actions: [
  //           FilledButton(
  //               onPressed: () {
  //                 Navigator.pop(context, newValue);
  //               },
  //               child: const Text("Save")),
  //           TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //               },
  //               child: const Text("Cancel")),
  //         ],
  //       );
  //     },
  //   );
  // }
}

class AddAccountDialog extends StatefulWidget {
  const AddAccountDialog({super.key, this.oldAccount});
  final AccountData? oldAccount;

  @override
  State<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<AddAccountDialog> {
  late var newAccount = widget.oldAccount != null
      ? widget.oldAccount!.toCompanion(false)
      : AccountCompanion.insert(
          provider: "Freshrss",
          serverUrl: "",
          userName: "",
          password: "",
          updatedArticleTime: 0,
          updatedStarredTime: 0);

  Future<int> addAccount(AccountCompanion accountToAdd) async {
    int index = -1;
    if (widget.oldAccount != null) {
      database.update(database.account).replace(accountToAdd);
      index = accountToAdd.id.value;
    } else {
      index = await database.into(database.account).insert(accountToAdd);
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
            groupValue: newAccount.provider.value,
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  newAccount =
                      newAccount.copyWith(provider: drift.Value<String>(value));
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
            initialValue: newAccount.serverUrl.value,
            inputType: TextInputType.url,
            onChanged: (value) {
              newAccount =
                  newAccount.copyWith(serverUrl: drift.Value<String>(value));
            },
          ),
          AdaptiveTextField(
            label: "User Name",
            initialValue: newAccount.userName.value,
            inputType: TextInputType.text,
            onChanged: (value) {
              newAccount =
                  newAccount.copyWith(userName: drift.Value<String>(value));
            },
          ),
          AdaptiveTextField(
            label: "Password",
            initialValue: newAccount.password.value,
            obscureText: true,
            onChanged: (value) {
              newAccount =
                  newAccount.copyWith(password: drift.Value<String>(value));
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
            Navigator.pop(
                context,
                await (database.select(database.account)
                      ..where((acc) => acc.id.equals(index)))
                    .getSingle());
          },
          child: Text(widget.oldAccount != null ? "Update" : "Add"),
        ),
      ],
    );
  }
}

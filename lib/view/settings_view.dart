import 'package:flutter/material.dart';
import 'package:fresh_reader/main.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api.dart';
import '../api/data_types.dart';
import '../api/database.dart';
import '../widget/adaptive_text_field.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      insetPadding: EdgeInsets.symmetric(horizontal: 100.0, vertical: 50.0),
      child: SettingsPage(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: SingleChildScrollView(child: SettingsContent()),
    );
  }
}

class SettingsContent extends StatefulWidget {
  const SettingsContent({super.key});

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.account_circle),
          title: Text("Add new account"),
          trailing: Icon(Icons.add),
          dense: true,
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
        ),
        AccountDetails(),
        Divider(),
        ListTile(title: Text("Other settings"), dense: true),
        const ReadDurationTile(
          title: "Keep read articles",
          dbKey: "read_duration",
          values: durations,
        ),
        const ReadDurationTile(
          title: "Keep starred articles",
          dbKey: "star_duration",
          values: amounts,
        ),
        Divider(),
        AboutListTile(
          applicationVersion: "1.2.8",
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
    );
  }
}

class AccountDetails extends StatefulWidget {
  const AccountDetails({super.key});

  @override
  State<AccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAccountIds(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return CircularProgressIndicator.adaptive();
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children:
              snapshot.data!.map((id) {
                return AccountCard(id: id);
              }).toList(),
        );
      },
    );
  }
}

class AccountCard extends StatefulWidget {
  const AccountCard({super.key, required this.id});
  final int id;

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAccount(widget.id),
      builder: (context, asyncSnapshot) {
        if (!asyncSnapshot.hasData) {
          return Card(
            child:
                asyncSnapshot.connectionState == ConnectionState.done
                    ? Text(asyncSnapshot.error.toString())
                    : LinearProgressIndicator(),
          );
        }
        Account account = asyncSnapshot.data!;
        return Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.all(8.0),
          child: ExpansionTile(
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
                    // if (onValue != null &&
                    //     onValue is AccountData) {
                    //   widget.chooseAccount(onValue);
                    // }
                  });
                },
              ),
              FutureBuilder(
                future: countAllArticles(true, account.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return ListTile(
                      title: Text("Loading"),
                      subtitle: LinearProgressIndicator(),
                    );
                  }
                  return ListTile(
                    title: Text(
                      "Total articles: ${snapshot.data!.values.reduce((count, value) => count + value)}",
                    ),
                    subtitle: Text(
                      "categories: ${snapshot.data!.entries.map((entry) => entry.key.startsWith("feed/") ? 0 : 1).reduce((count, value) => count + value)}, subscriptions: ${snapshot.data!.entries.map((entry) => entry.key.startsWith("feed/") ? 1 : 0).reduce((count, value) => count + value)}",
                    ),
                  );
                },
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
                      database.update(
                        "Account",
                        {
                          "updatedArticleTime":
                              (value.millisecondsSinceEpoch / 1000).floor(),
                        },
                        where: "id = ?",
                        whereArgs: [account.id],
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
                      database.update(
                        "Account",
                        {
                          "updatedStarredTime":
                              (value.millisecondsSinceEpoch / 1000).floor(),
                        },
                        where: "id = ?",
                        whereArgs: [account.id],
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
                              deleteAccount(account.id).then((_) {
                                // ScaffoldMessenger.of(
                                //   context,
                                // ).showSnackBar(
                                //   const SnackBar(
                                //     content: Text("Account Deleted"),
                                //   ),
                                // );
                                setState(() {
                                  if (Api.of(context).account?.id ==
                                      account.id) {
                                    getAllAccounts(limit: 1).then((onValue) {
                                      Api.of(
                                        context,
                                      ).changeAccount(onValue.first);
                                    });
                                  }
                                });
                              });
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Delete Account",
                              style: TextStyle(color: Colors.red[300]),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              deleteAccountData(account.id).then((_) {
                                // ScaffoldMessenger.of(
                                //   context,
                                // ).showSnackBar(
                                //   const SnackBar(
                                //     content: Text("Data Cleared"),
                                //   ),
                                // );
                                setState(() {});
                              });
                              Navigator.pop(context);
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
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

const Map<int, String> durations = {
  -1: "Forever",
  1: "1 day",
  2: "2 days",
  7: "1 week",
  14: "2 weeks",
  31: "1 month",
  62: "2 months",
};

const Map<int, String> amounts = {
  -1: "Unlimited",
  100: "100",
  200: "200",
  500: "500",
  1000: "1000",
  2000: "2000",
  5000: "5000",
};

class ReadDurationTile extends StatefulWidget {
  const ReadDurationTile({
    super.key,
    required this.dbKey,
    required this.title,
    required this.values,
  });
  final String dbKey;
  final String title;
  final Map<int, String> values;

  @override
  State<ReadDurationTile> createState() => _ReadDurationTileState();
}

class _ReadDurationTileState extends State<ReadDurationTile> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getPreference(widget.dbKey),
      builder: (context, asyncSnapshot) {
        return ListTile(
          title: Text(widget.title),
          subtitle: Text(
            asyncSnapshot.data != null
                ? widget.values[int.tryParse(asyncSnapshot.data!)] ??
                    asyncSnapshot.data!
                : widget.values.values.first,
          ),
          onTap: () {
            showAdaptiveDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) {
                return AlertDialog(
                  scrollable: true,
                  title: Text(widget.title),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        widget.values.entries
                            .map(
                              (element) => RadioListTile.adaptive(
                                dense: true,
                                title: Text(element.value),
                                value: element.key.toString(),
                                groupValue: asyncSnapshot.data,
                                toggleable: true,
                                onChanged: (newVal) {
                                  if (newVal != null) {
                                    setState(() {
                                      setPreference(widget.dbKey, newVal);
                                    });
                                  }
                                  Navigator.pop(context);
                                },
                              ),
                            )
                            .toList(),
                  ),
                );
              },
            );
          },
        );
      },
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
      await updateAccount(accountToAdd);
      index = accountToAdd.id;
    } else {
      index = await addAccount(accountToAdd);
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
          // RadioListTile.adaptive(
          //   title: const Text('InoReader'),
          //   value: "InoReader",
          //   groupValue: newAccount.serverUrl.value,
          //   onChanged: (String? value) {
          //     if (value != null) {
          //       setState(() {
          //         newAccount =
          //             newAccount.copyWith(serverUrl: drift.Value<String>(value));
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
      // actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),
        FilledButton(
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

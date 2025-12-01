import 'package:flutter/material.dart';
import 'package:fresh_reader/util/formatting_setting.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api.dart';
import '../api/data_types.dart';
import '../widget/adaptive_text_field.dart';

const version = "1.2.14";

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
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SettingsContent(),
      ),
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
                if (context.mounted) {
                  context.read<Api>().changeAccount(onValue);
                } else {
                  debugPrint("Context not mounted");
                }
              }
              setState(() {});
            });
          },
        ),
        AccountDetails(),
        Divider(indent: 8.0, endIndent: 8.0),
        ListTile(title: Text("Other settings"), dense: true),
        CheckboxListTile.adaptive(
          title: Text("Set article as read when open"),
          value: context.select<Preferences, bool>((a) => a.markReadWhenOpen),
          onChanged: (val) {
            if (val != null) {
              context.read<Preferences>().setMarkReadWhenOpen(val);
            }
          },
        ),
        CheckboxListTile.adaptive(
          title: Text("Show last sync article category"),
          value: context.select<Preferences, bool>((a) => a.showLastSync),
          onChanged: (val) {
            if (val != null) {
              context.read<Preferences>().setShowLastSync(val);
            }
          },
        ),
        ListTile(title: Text("Theme"), dense: true),
        Card(
          child: RadioGroup<int>(
            onChanged: (val) {
              if (val != null) {
                context.read<Preferences>().setThemeIndex(val);
              }
            },
            groupValue: context.select<Preferences, int>((a) => a.themeIndex),
            child: Column(
              children: MyTheme.values
                  .map(
                    (t) => RadioListTile.adaptive(
                      value: t.index,
                      title: Text(
                        "${t.name[0].toUpperCase()}${t.name.substring(1)}",
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const ReadDurationTile(
          title: "Keep read articles",
          dbKey: "read_duration",
          values: durations,
        ),
        // const ReadDurationTile(
        //   title: "Keep starred articles",
        //   dbKey: "star_duration",
        //   values: amounts,
        // ),
        Divider(indent: 8.0, endIndent: 8.0),
        AboutListTile(
          applicationVersion: version,
          aboutBoxChildren: [
            const ListTile(
              title: Text("Made By"),
              subtitle: Text("Hasan Kadhem"),
              leading: Icon(Icons.person),
            ),
            const ListTile(
              title: Text("Made Using"),
              subtitle: Text("Flutter"),
              leading: FlutterLogo(),
            ),
            ListTile(
              title: const Text("Source Code"),
              subtitle: const Text(
                "https://github.com/HassanAliKadhem/fresh_reader",
              ),
              leading: Icon(Icons.code),
              trailing: const Icon(Icons.open_in_browser),
              onTap: () => launchUrl(
                Uri.parse("https://github.com/HassanAliKadhem/fresh_reader"),
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
      future: context.watch<Api>().getAccounts(),
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
                      onValue.id == context.read<Api>().account?.id) {
                    context.read<Api>().changeAccount(onValue);
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
                          Navigator.pop(context);
                          if (context.read<Api>().account?.id == account.id) {
                            context.read<Api>().clear();
                          }
                          context
                              .read<Api>()
                              .database
                              .deleteAccount(account.id)
                              .then((_) {
                                if (context.read<Api>().account?.id ==
                                    account.id) {
                                  context.read<Api>().getAccounts().then((
                                    onValue,
                                  ) {
                                    context.read<Api>().changeAccount(
                                      onValue.firstOrNull,
                                    );
                                    setState(() {});
                                  });
                                } else {
                                  context.read<Api>().changeAccount(
                                    context.read<Api>().account,
                                  );
                                  setState(() {});
                                }
                              });
                        },
                        child: Text(
                          "Delete Account",
                          style: TextStyle(color: Colors.red[300]),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if (context.read<Api>().account?.id == account.id) {
                            context.read<Api>().clear();
                          }
                          context
                              .read<Api>()
                              .database
                              .deleteAccountData(account.id)
                              .then((_) {
                                context
                                    .read<Api>()
                                    .database
                                    .getAccount(account.id)
                                    .then((onValue) {
                                      context.read<Api>().changeAccount(
                                        onValue,
                                      );
                                      setState(() {});
                                    });
                              });
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
          ListTile(
            title: FutureBuilder(
              future: context.read<Api>().database.loadArticleMetaData(
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
                context.read<Api>().database.loadAllCategory(account.id),
                context.read<Api>().database.loadAllSubs(account.id),
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
                  context.read<Api>().database.database.update(
                    "Account",
                    {"updatedArticleTime": newTime},
                    where: "id = ?",
                    whereArgs: [account.id],
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
                  context.read<Api>().database.database.update(
                    "Account",
                    {"updatedStarredTime": newTime},
                    where: "id = ?",
                    whereArgs: [account.id],
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
    int? value = widget.dbKey == "read_duration"
        ? context.select<Preferences, int?>((a) => a.readDuration)
        : context.select<Preferences, int?>((a) => a.starDuration);
    return ListTile(
      title: Text(widget.title),
      subtitle: Text(
        value != null
            ? widget.values[value] ?? value.toString()
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
              content: RadioGroup(
                groupValue: value,
                onChanged: (newVal) {
                  if (newVal != null) {
                    setState(() {
                      if (widget.dbKey == "read_duration") {
                        context.read<Preferences>().setReadDuration(newVal);
                      } else {
                        context.read<Preferences>().setStarDuration(newVal);
                      }
                    });
                  }
                  Navigator.pop(context);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.values.entries
                      .map(
                        (element) => RadioListTile.adaptive(
                          dense: true,
                          title: Text(element.value),
                          value: element.key,
                          toggleable: true,
                        ),
                      )
                      .toList(),
                ),
              ),
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
  late var newAccount = widget.oldAccount != null
      ? widget.oldAccount!
      : Account(0, "", "Freshrss", "", "", 0, 0);

  Future<int> _addAccount(Account accountToAdd) async {
    int index = -1;
    if (widget.oldAccount != null) {
      await context.read<Api>().database.updateAccount(accountToAdd);
      index = accountToAdd.id;
    } else {
      index = await context.read<Api>().database.addAccount(accountToAdd);
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

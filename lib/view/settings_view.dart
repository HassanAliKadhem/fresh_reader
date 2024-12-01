import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({
    super.key,
  });
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Server Url"),
            subtitle: Text(Api.of(context).server),
            onTap: () {
              showValueChangerDialog(
                context: context,
                title: "Server link",
                currentValue: Api.of(context).server,
              ).then((value) {
                if (value != null) {
                  Api.of(context).server = value;
                  Api.of(context).save();
                  setState(() {});
                }
              });
            },
          ),
          ListTile(
            title: const Text("Username"),
            subtitle: Text(Api.of(context).userName),
            onTap: () {
              showValueChangerDialog(
                context: context,
                title: "username",
                currentValue: Api.of(context).userName,
              ).then((value) {
                if (value != null) {
                  Api.of(context).userName = value;
                  Api.of(context).save();
                  setState(() {});
                }
              });
            },
          ),
          ListTile(
            title: const Text("Password"),
            subtitle: Text("*" * Api.of(context).password.length),
            onTap: () {
              showValueChangerDialog(
                context: context,
                title: "password",
                currentValue: Api.of(context).password,
                hide: true,
              ).then((value) {
                if (value != null) {
                  Api.of(context).password = value;
                  Api.of(context).save();
                  setState(() {});
                }
              });
            },
          ),
          const Divider(
            indent: 8.0,
            endIndent: 8.0,
          ),
          // if (kDebugMode)
          ExpansionTile(
            shape: const Border(),
            title: const Text("Developer options"),
            children: [
              ListTile(
                title: const Text("Last sync articles time"),
                subtitle: Text(DateTime.fromMillisecondsSinceEpoch(
                        Api.of(context).updatedArticleTime * 1000)
                    .toString()),
                onTap: () {
                  showDatePicker(
                    context: context,
                    firstDate: DateTime(0),
                    lastDate: DateTime.now(),
                    initialDate: DateTime.fromMillisecondsSinceEpoch(
                        Api.of(context).updatedArticleTime * 1000),
                  ).then((value) {
                    if (value != null) {
                      Api.of(context).updatedArticleTime =
                          (value.millisecondsSinceEpoch / 1000).floor();
                      setState(() {});
                    }
                  });
                },
              ),
              ListTile(
                title: const Text("Last sync starred time"),
                subtitle: Text(DateTime.fromMillisecondsSinceEpoch(
                        Api.of(context).updatedStarredTime * 1000)
                    .toString()),
                onTap: () {
                  showDatePicker(
                    context: context,
                    firstDate: DateTime(0),
                    lastDate: DateTime.now(),
                    initialDate: DateTime.fromMillisecondsSinceEpoch(
                        Api.of(context).updatedStarredTime * 1000),
                  ).then((value) {
                    if (value != null) {
                      Api.of(context).updatedStarredTime =
                          (value.millisecondsSinceEpoch / 1000).floor();
                      setState(() {});
                    }
                  });
                },
              ),
              ListTile(
                title: const Text("Total articles"),
                subtitle: FutureBuilder(
                  future: Api.of(context).db!.countAllArticles(true),
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      int allCount = 0;
                      for (var element in snapshot.data!.entries) {
                        if (element.key.startsWith("feed")) {
                          allCount += element.value;
                        }
                      }
                      return Text(allCount.toString());
                    }
                    return const Text("Please wait");
                  },
                ),
              ),
              ListTile(
                title: const Text("Delete Data"),
                onTap: () async {
                  showAdaptiveDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog.adaptive(
                        title: const Text("Are you sure?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Api.of(context).db!.db.execute(
                                  "Delete from Article; Delete from Category; Delete from Subscription; Delete from DelayedAction;");
                              Api.of(context).updatedArticleTime = 0;
                              Api.of(context).updatedStarredTime = 0;
                              Api.of(context).articleIDs = {};
                              Api.of(context).filteredIndex = null;
                              Api.of(context).filteredArticleIDs = null;
                              Api.of(context).delayedActions = {};
                              Api.of(context).save();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Data Cleared"),
                                ),
                              );
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Delete Everything",
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
                  ).then((_) {
                    setState(() {});
                  });
                },
              ),
            ],
          ),
          const Divider(
            indent: 8.0,
            endIndent: 8.0,
          ),
          AboutListTile(
            applicationVersion: "0.9.17",
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
    );
  }

  Future<dynamic> showValueChangerDialog({
    required BuildContext context,
    required String title,
    String currentValue = "",
    bool hide = false,
  }) {
    String newValue = currentValue;
    TextEditingController textEditingController =
        TextEditingController(text: newValue);
    return showDialog<String?>(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: textEditingController,
            obscureText: hide,
            onChanged: (value) => newValue = value,
          ),
          actions: [
            FilledButton(
                onPressed: () {
                  Navigator.pop(context, newValue);
                },
                child: const Text("Save")),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel")),
          ],
        );
      },
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/preferences.dart';
import '../util/theme.dart';

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
                          activeColor: Theme.of(context).colorScheme.primary,
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

class ShowLastSyncCheckTile extends StatelessWidget {
  const ShowLastSyncCheckTile({super.key});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile.adaptive(
      title: Text("Show last sync article category"),
      activeColor: Theme.of(context).colorScheme.primary,
      value: context.select<Preferences, bool>((a) => a.showLastSync),
      onChanged: (val) {
        if (val != null) {
          context.read<Preferences>().setShowLastSync(val);
        }
      },
    );
  }
}

class ReadWhenOpenCheckTile extends StatelessWidget {
  const ReadWhenOpenCheckTile({super.key});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile.adaptive(
      title: Text("Set article as read when open"),
      activeColor: Theme.of(context).colorScheme.primary,
      value: context.select<Preferences, bool>((a) => a.markReadWhenOpen),
      onChanged: (val) {
        if (val != null) {
          context.read<Preferences>().setMarkReadWhenOpen(val);
        }
      },
    );
  }
}

class OpenInBrowserCheckTile extends StatelessWidget {
  const OpenInBrowserCheckTile({super.key});

  @override
  Widget build(BuildContext context) {
    bool openInBrowser = context.select<Preferences, bool>(
      (a) => a.openInBrowser,
    );
    return Card(
      margin: const .all(12.0),
      child: Column(
        mainAxisSize: .min,
        children: [
          const ListTile(title: Text("Open links in"), dense: true),
          RadioGroup<bool>(
            onChanged: (val) {
              if (val != null) {
                context.read<Preferences>().setOpenInBrowser(val);
              }
            },
            groupValue: openInBrowser,
            child: Column(
              children: [
                RadioListTile.adaptive(
                  value: false,
                  activeColor: Theme.of(context).colorScheme.primary,
                  title: Text("InApp browser view"),
                ),
                RadioListTile.adaptive(
                  value: true,
                  activeColor: Theme.of(context).colorScheme.primary,
                  title: Text("Browser/App"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ThemeSwitcherCard extends StatelessWidget {
  const ThemeSwitcherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      children: [
        const ListTile(title: Text("Colors"), dense: true),
        if (!Platform.isIOS)
          SwitchListTile.adaptive(
            title: const Text("Use dynamic colors"),
            value: context.select<Preferences, bool>((a) => a.themeDynamic),
            onChanged: (value) {
              context.read<Preferences>().setThemeMode(value);
            },
          ),
        ListTile(
          title: const Text("Custom Color"),
          trailing: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: context.select<Preferences, int>((a) => a.themeColor),
              menuWidth: 80.0,
              elevation: 1,
              borderRadius: .circular(8.0),
              items: Colors.primaries
                  .map(
                    (color) => DropdownMenuItem<int>(
                      alignment: .center,
                      value: color.toARGB32(),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Card(
                          margin: EdgeInsets.only(top: 2.0),
                          color: color,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  context.read<Preferences>().setThemeColor(Color(value));
                }
              },
            ),
          ),
        ),
        const ListTile(title: Text("Theme Mode"), dense: true),
        RadioGroup<int>(
          onChanged: (val) {
            if (val != null) {
              context.read<Preferences>().setThemeIndex(val);
            }
          },
          groupValue: context.select<Preferences, int>((a) => a.themeIndex),
          child: Card(
            margin: const .all(12.0),
            child: Column(
              children: themes.entries
                  .map(
                    (t) => RadioListTile.adaptive(
                      value: t.value,
                      activeColor: Theme.of(context).colorScheme.primary,
                      title: Text(t.key),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

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
                  title: Text("InApp browser view"),
                ),
                RadioListTile.adaptive(value: true, title: Text("Browser/App")),
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
    return Card(
      child: Column(
        mainAxisSize: .min,
        children: [
          const ListTile(title: Text("Theme"), dense: true),
          RadioGroup<int>(
            onChanged: (val) {
              if (val != null) {
                context.read<Preferences>().setThemeIndex(val);
              }
            },
            groupValue: context.select<Preferences, int>((a) => a.themeIndex),
            child: Column(
              children: themes.entries
                  .map(
                    (t) => RadioListTile.adaptive(
                      value: t.value,
                      title: Text(t.key),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

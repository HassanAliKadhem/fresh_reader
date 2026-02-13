import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/data.dart';

class UnreadCount extends StatelessWidget {
  const UnreadCount(this.unread, {super.key});
  final int unread;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Text(unread.toString(), textScaler: const TextScaler.linear(1.15)),
    );
  }
}

class UnreadCounter extends StatelessWidget {
  const UnreadCounter(this.filter, {super.key});
  final bool Function(
    (int timeStampPublished, String subID, bool isRead, bool isStarred),
  )
  filter;

  @override
  Widget build(BuildContext context) {
    return UnreadCount(
      context.select<DataProvider, int>(
        (value) => value.articlesMetaData.values.where((a) => filter(a)).length,
      ),
    );
  }
}

class UnreadLastSync extends StatelessWidget {
  const UnreadLastSync({super.key});

  @override
  Widget build(BuildContext context) {
    return UnreadCount(
      context.select<DataProvider, int>(
        (data) => data.showAll
            ? data.lastSyncIDs.length
            : data.lastSyncIDs
                  .where((l) => !(data.articlesMetaData[l]?.$3 ?? true))
                  .length,
      ),
    );
  }
}

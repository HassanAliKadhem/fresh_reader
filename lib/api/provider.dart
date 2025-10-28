import 'package:flutter/material.dart';

import 'api.dart';

class Api extends InheritedNotifier<ApiData> {
  const Api({super.key, required super.child, required super.notifier});

  static ApiData of(BuildContext context) {
    assert(
      context.dependOnInheritedWidgetOfExactType<Api>() != null,
      "Api not found in current context",
    );
    return context.dependOnInheritedWidgetOfExactType<Api>()!.notifier!;
  }

  @override
  bool updateShouldNotify(covariant InheritedNotifier<ApiData> oldWidget) {
    return notifier != oldWidget.notifier;
  }
}

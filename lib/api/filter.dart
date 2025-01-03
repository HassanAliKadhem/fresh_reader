import 'package:flutter/widgets.dart';
import 'package:fresh_reader/api/database.dart';

import 'api.dart';

class Filter extends InheritedWidget {
  const Filter({
    super.key,
    required super.child,
    this.filterType,
    this.filterValue,
    required this.showAll,
    required this.changeShowAll,
    required this.onSelectFeed,
    required this.onSelectAccount,
    this.api,
  });
  final ArticleListType? filterType;
  final int? filterValue;
  final bool showAll;
  final Function(bool) changeShowAll;
  final Function(ArticleListType?, int?) onSelectFeed;
  final Function(AccountData) onSelectAccount;
  final ApiData? api;

  @override
  bool updateShouldNotify(covariant Filter oldWidget) {
    if (api?.account.id != oldWidget.api?.account.id) {
      return true;
    }
    if (filterType != oldWidget.filterType) {
      return true;
    }
    if (filterValue != oldWidget.filterValue) {
      return true;
    }
    return false;
  }

  static Filter of(BuildContext context) {
    final Filter? result = context.dependOnInheritedWidgetOfExactType<Filter>();
    assert(result != null, 'No Filter found in context');
    return result!;
  }
}

enum ArticleListType {
  all,
  starred,
  category,
  subscription,
}

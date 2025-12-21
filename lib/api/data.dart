import 'package:anchor_scroll_controller/anchor_scroll_controller.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';

import 'api.dart';
import 'data_types.dart';
import 'database.dart';

class DataProvider extends ChangeNotifier {
  ApiBase? api;
  int? accountID;
  StorageBase db;
  bool showAll = false;

  Map<String, Subscription> subscriptions = <String, Subscription>{};
  Map<String, Category> categories = <String, Category>{};
  List<String> lastSyncIDs = [];
  Set<String>? filteredArticleIDs;
  Map<String, (int, String, bool, bool)> articlesMetaData = {};
  List<String>? searchResults;
  String? filteredTitle;
  int? _selectedIndex;
  int? get selectedIndex => _selectedIndex;

  PageController? pageController;
  AnchorScrollController? listController;

  DataProvider(this.db) {
    db.getAllAccounts().then((accounts) {
      if (accounts.isNotEmpty) {
        try {
          api = getApi(accounts.first);
          accountID = accounts.first.id;
        } catch (e, stack) {
          debugPrint(e.toString());
          debugPrintStack(stackTrace: stack);
        }
      } else {
        debugPrint("No accounts found");
      }

      if (accountID != null) {
        db.loadAllSubs(accountID!).then((subs) {
          subscriptions = subs;
          db.loadAllCategory(accountID!).then((cats) {
            categories = cats;
            db.loadArticleMetaData(accountID!).then((meta) {
              articlesMetaData = meta;
              db.getLastSyncIDs(accountID!).then((lastIds) {
                lastSyncIDs = lastIds;
                notifyListeners();
              });
            });
          });
        });
      }
    });
  }

  void setSelectedIndex(int? i, bool? fromArticleView, [bool notify = true]) {
    _selectedIndex = i;
    if (fromArticleView == false &&
        i != null &&
        pageController?.hasClients == true) {
      pageController?.jumpToPage(i);
    } else if (fromArticleView == true &&
        i != null &&
        listController?.hasClients == true) {
      listController?.scrollToIndex(index: i, scrollSpeed: 0.5);
    }
    if (notify) {
      notifyListeners();
    }
  }

  void clearFiltered() {
    filteredArticleIDs = null;
    filteredTitle = null;
    notifyListeners();
  }

  void clear([bool clearMeta = true]) {
    filteredArticleIDs?.clear();
    setSelectedIndex(null, null);
    searchResults = [];
    if (clearMeta) {
      articlesMetaData = {};
    }
  }

  Future<List<Account>> getAccounts() async {
    return (await db.getAllAccounts());
  }

  Future<void> changeAccount(Account? acc) async {
    accountID = acc?.id;
    if (acc == null) {
      api = null;
    } else {
      api = getApi(acc);
    }
    clear();
    subscriptions = {};
    categories = {};
    if (accountID != null) {
      await Future.wait([
        db.loadAllSubs(accountID!).then((subs) {
          subscriptions = subs;
        }),
        db.loadArticleMetaData(accountID!).then((meta) {
          articlesMetaData = meta;
        }),
        db.loadAllCategory(accountID!).then((cats) {
          categories = cats;
        }),
        db.getLastSyncIDs(accountID!).then((lastIds) {
          lastSyncIDs = lastIds;
        }),
      ]).then((_) {
        notifyListeners();
      });
    }
  }

  Future<void> deleteAccount(int id) async {
    await db.deleteAccount(id);
    if (accountID == id) {
      clear();
      await changeAccount((await getAccounts()).firstOrNull);
    } else {
      var accounts = await getAccounts();
      for (var acc in accounts) {
        if (acc.id == accountID) {
          await changeAccount(acc);
          return;
        }
      }
    }
  }

  Future<void> deleteAccountData(int id) async {
    await db.deleteAccountData(id);
    if (accountID == id) {
      clear();
      await changeAccount((await db.getAccount(accountID!)));
    } else {
      var accounts = await getAccounts();
      for (var acc in accounts) {
        if (acc.id == accountID) {
          await changeAccount(acc);
          return;
        }
      }
    }
    notifyListeners();
  }

  void setShowAll(bool newValue) {
    showAll = newValue;
    clear(false);
    notifyListeners();
  }

  Stream<double> serverSync() async* {
    yield 0.0;
    if (accountID == null) {
      debugPrint("No account selected");
      throw "No account selected";
    }

    final delayedActions = await db.loadDelayedActions(accountID!);
    yield 0.1;
    debugPrint("delayed actions: ${delayedActions.length}");
    debugPrint(delayedActions.toString());
    if (delayedActions.isNotEmpty) {
      Map<String, String> articleSub = {};
      for (var element in delayedActions.keys) {
        await db.loadArticleSubID(element, accountID!).then((value) {
          if (value != null) {
            articleSub[element] = value;
          }
        });
      }
      Map<String, String> readIds = {};
      Map<String, String> unReadIds = {};
      Map<String, String> starIds = {};
      Map<String, String> unStarIds = {};

      for (var element in delayedActions.entries) {
        if (articleSub[element.key] != null) {
          if (element.value == DelayedAction.read) {
            readIds[element.key] = articleSub[element.key]!;
          } else if (element.value == DelayedAction.unread) {
            unReadIds[element.key] = articleSub[element.key]!;
          } else if (element.value == DelayedAction.star) {
            starIds[element.key] = articleSub[element.key]!;
          } else if (element.value == DelayedAction.unStar) {
            unStarIds[element.key] = articleSub[element.key]!;
          }
        }
      }
      if (readIds.isNotEmpty) {
        await _setServerRead(
          readIds.keys.toList(),
          readIds.values.toList(),
          true,
        ).then((done) {
          if (done) {
            db.deleteDelayedActions(
              readIds.map((key, value) => MapEntry(key, DelayedAction.read)),
              accountID!,
            );
          }
        });
      }
      if (unReadIds.isNotEmpty) {
        await _setServerRead(
          unReadIds.keys.toList(),
          unReadIds.values.toList(),
          false,
        ).then((done) {
          if (done) {
            db.deleteDelayedActions(
              unReadIds.map(
                (key, value) => MapEntry(key, DelayedAction.unread),
              ),
              accountID!,
            );
          }
        });
      }
      if (starIds.isNotEmpty) {
        await _setServerStar(
          starIds.keys.toList(),
          starIds.values.toList(),
          true,
        ).then((done) {
          if (done) {
            db.deleteDelayedActions(
              starIds.map((key, value) => MapEntry(key, DelayedAction.star)),
              accountID!,
            );
          }
        });
      }
      if (unStarIds.isNotEmpty) {
        await _setServerStar(
          unStarIds.keys.toList(),
          unStarIds.values.toList(),
          false,
        ).then((done) {
          if (done) {
            db.deleteDelayedActions(
              unStarIds.map(
                (key, value) => MapEntry(key, DelayedAction.unStar),
              ),
              accountID!,
            );
          }
        });
      }
      debugPrint("synced delayed actions: ${delayedActions.length}");
    } else {
      debugPrint("no delayed actions");
    }
    yield 0.3;
    await db.clearOld(accountID!);
    yield 0.4;
    // await getPreference("star_duration").then((count) {
    //   // get number of starred articles to keep
    //   debugPrint("starred count to keep: $count");
    //   if (count != null && count != "-1") {
    //     // TODO: add code to delete starred articles
    //     int num = int.parse(count);
    //     database
    //         .query(
    //           "articles",
    //           columns: ["id"],
    //           where: "accountID = ? and isRead = ? and isStarred = ?",
    //           whereArgs: [account!.id, "true", "true"],
    //         )
    //         .then((value) {
    //           if (num > value.length) {
    //             // database.execute("Delete from articles where rowid IN (?)");
    //             // database.delete("articles",
    //             //   where: "id in (?)",
    //             //   whereArgs: [
    //             //     value.map((elm) => elm.values.first).join(",")
    //             //   ],
    //             // );
    //             print("to delete: ${value.length - num}");
    //             print("starred: count {${value.length}}, $value");
    //             print("starred ids: ${value.map((elm) => elm.values.first).join(",")}");
    //           }
    //         });
    //   }
    // });

    // _getModifyAuth(auth)
    //     .then((value) => modifyAuth = value.body.replaceAll("\n", "")),
    await _getServerCategories();
    await _getSubscriptions();
    yield 0.5;
    await _getAllServerArticles();
    yield 0.8;
    await _getServerReadIds();
    await _getServerStarredArticles();
    await _getServerStarredIds();
    yield 0.9;
    articlesMetaData.clear();
    await db.loadArticleMetaData(accountID!).then((meta) {
      articlesMetaData = meta;
    });
    //https://github.com/FreshRSS/FreshRSS/issues/2566
    notifyListeners();
    yield 1.0;
  }

  Future<void> _getSubscriptions() async {
    if (api == null) {
      debugPrint("No Api loaded");
    } else {
      try {
        var subs = await api!.getServerSubscriptions();
        await db.insertSubscriptions(subs);
        for (var s in subs) {
          subscriptions[s.subID] = s;
        }
      } catch (e) {
        if (kDebugMode) {
          rethrow;
        }
        debugPrint(e.toString());
      }
    }
  }

  Future<void> _getServerCategories() async {
    if (api == null || accountID == null) {
      debugPrint("No Api or Account loaded");
    } else {
      try {
        var cats = await api!.getServerCategories();
        await db.insertCategories(cats, accountID!);
        for (var c in cats) {
          categories[c.catID] = c;
        }
      } catch (e) {
        if (kDebugMode) {
          rethrow;
        }
        debugPrint(e.toString());
      }
    }
  }

  Future<void> _getAllServerArticles() async {
    db.clearLastSyncTable(accountID!);
    if (api == null) {
      debugPrint("No Api loaded");
    } else {
      lastSyncIDs = [];
      await for (var res in api!.getAllServerArticles().handleError((onError) {
        debugPrint(onError.toString());
      })) {
        if (res.$1 != null) {
          db.updateAccount(api!.account.copyWith(updatedArticleTime: res.$1));
        }
        if (res.$2.isNotEmpty) {
          await db.insertArticles(res.$2);
          lastSyncIDs.addAll(
            res.$2.where((a) => !a.read).map((a) => a.articleID),
          );
        }
      }
    }
  }

  Future<void> _getServerReadIds() async {
    if (api == null || accountID == null) {
      debugPrint("No Api or Account loaded");
    } else {
      Set<String> ids = await api!.getServerReadIds();
      await db.syncArticlesRead(ids, accountID!);
    }
  }

  Future<void> _getServerStarredIds() async {
    if (api == null || accountID == null) {
      debugPrint("No Api or Account loaded");
    } else {
      var (int? updatedTime, Set<String> ids) = await api!
          .getServerStarredIds();
      await db.syncArticlesStar(ids, accountID!);
      if (updatedTime != null) {
        db.updateAccount(
          api!.account.copyWith(updatedStarredTime: updatedTime),
        );
      }
    }
  }

  Future<void> _getServerStarredArticles() async {
    if (api == null || accountID == null) {
      debugPrint("No Api or Account loaded");
    } else {
      List<Article> articles = await api!.getServerStarredArticles();
      await db.insertArticles(articles);
    }
  }

  Future<bool> _setServerRead(
    List<String> ids,
    List<String> subIDs,
    bool isRead,
  ) async {
    if (api == null || accountID == null) {
      debugPrint("No Api or Account loaded");
    } else {
      Map<String, DelayedAction> delayedActions = await api!.setServerRead(
        ids,
        subIDs,
        isRead,
      );
      if (delayedActions.isNotEmpty) {
        db.saveDelayedActions(delayedActions, accountID!);
        return false;
      }
    }
    return true;
  }

  Future<bool> _setServerStar(
    List<String> ids,
    List<String> subIDs,
    bool isStar,
  ) async {
    if (api == null || accountID == null) {
      debugPrint("No Api or Account loaded");
    } else {
      Map<String, DelayedAction> delayedActions = await api!.setServerStar(
        ids,
        subIDs,
        isStar,
      );
      if (delayedActions.isNotEmpty) {
        db.saveDelayedActions(delayedActions, accountID!);
        return false;
      }
    }
    return true;
  }

  void setRead(String id, String subID, bool isRead) {
    articlesMetaData.update(id, (val) => (val.$1, val.$2, isRead, val.$4));
    notifyListeners();

    _setServerRead([id], [subID], isRead);
    db.updateArticleRead(id, isRead, accountID!);
  }

  void setStarred(String id, String subID, bool isStarred) {
    articlesMetaData.update(id, (val) => (val.$1, val.$2, val.$3, isStarred));
    notifyListeners();

    _setServerStar([id], [subID], isStarred);
    db.updateArticleStar(id, isStarred, accountID!);
  }

  Future<void> searchFilteredArticles(String? searchTerm) async {
    if (accountID == null) {
      searchResults = [];
      return;
    }
    searchResults = await db.searchArticles(
      searchTerm,
      filteredArticleIDs,
      accountID!,
    );
    notifyListeners();
  }

  Future<void> getFilteredArticles(
    bool? showAll,
    String? filterColumn,
    String? filterValue,
    String title,
    int todaySecondsSinceEpoch,
  ) async {
    if (accountID == null) {
      debugPrint("No Account selected");
      return;
    }
    filteredArticleIDs = null;
    setSelectedIndex(null, null);
    filteredTitle = null;
    if (title == "lastSync") {
      await db.getLastSyncIDs(accountID!).then((value) {
        if (showAll == true) {
          filteredArticleIDs = value.toSet();
        } else {
          filteredArticleIDs = {};
          for (var id in value) {
            if (articlesMetaData[id]?.$3 == false) {
              filteredArticleIDs!.add(id);
            }
          }
        }
      });
    } else {
      await db
          .loadArticleIDs(
            showAll: showAll,
            filterColumn: filterColumn,
            filterValue: filterValue,
            accountID: accountID!,
            todaySecondsSinceEpoch: todaySecondsSinceEpoch,
          )
          .then((value) {
            filteredArticleIDs = value.keys.toSet();
          });
    }
    filteredTitle = title;
    searchResults = filteredArticleIDs?.toList();
    notifyListeners();
    if (listController?.hasClients == true) {
      listController?.jumpTo(0);
    }
  }

  Future<Article> getArticleWithContent(String articleID) {
    return db.loadArticleContent(articleID, accountID!);
  }

  String getIconUrl(String url) {
    url = url.replaceFirst(
      "http://localhost/FreshRss/p/",
      api?.account.serverUrl ?? "",
    );
    url = url.replaceFirst("api/greader.php", "");
    return url;
  }
}

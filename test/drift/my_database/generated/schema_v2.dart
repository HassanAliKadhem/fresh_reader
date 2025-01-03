// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';

class Account extends Table with TableInfo<Account, AccountData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Account(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
      'provider', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> serverUrl = GeneratedColumn<String>(
      'server_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
      'user_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
      'password', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<int> updatedArticleTime = GeneratedColumn<int>(
      'updated_article_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<int> updatedStarredTime = GeneratedColumn<int>(
      'updated_starred_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        provider,
        serverUrl,
        userName,
        password,
        updatedArticleTime,
        updatedStarredTime
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      provider: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider'])!,
      serverUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_url'])!,
      userName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_name'])!,
      password: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password'])!,
      updatedArticleTime: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}updated_article_time'])!,
      updatedStarredTime: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}updated_starred_time'])!,
    );
  }

  @override
  Account createAlias(String alias) {
    return Account(attachedDatabase, alias);
  }
}

class AccountData extends DataClass implements Insertable<AccountData> {
  final int id;
  final String provider;
  final String serverUrl;
  final String userName;
  final String password;
  final int updatedArticleTime;
  final int updatedStarredTime;
  const AccountData(
      {required this.id,
      required this.provider,
      required this.serverUrl,
      required this.userName,
      required this.password,
      required this.updatedArticleTime,
      required this.updatedStarredTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['provider'] = Variable<String>(provider);
    map['server_url'] = Variable<String>(serverUrl);
    map['user_name'] = Variable<String>(userName);
    map['password'] = Variable<String>(password);
    map['updated_article_time'] = Variable<int>(updatedArticleTime);
    map['updated_starred_time'] = Variable<int>(updatedStarredTime);
    return map;
  }

  AccountCompanion toCompanion(bool nullToAbsent) {
    return AccountCompanion(
      id: Value(id),
      provider: Value(provider),
      serverUrl: Value(serverUrl),
      userName: Value(userName),
      password: Value(password),
      updatedArticleTime: Value(updatedArticleTime),
      updatedStarredTime: Value(updatedStarredTime),
    );
  }

  factory AccountData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountData(
      id: serializer.fromJson<int>(json['id']),
      provider: serializer.fromJson<String>(json['provider']),
      serverUrl: serializer.fromJson<String>(json['serverUrl']),
      userName: serializer.fromJson<String>(json['userName']),
      password: serializer.fromJson<String>(json['password']),
      updatedArticleTime: serializer.fromJson<int>(json['updatedArticleTime']),
      updatedStarredTime: serializer.fromJson<int>(json['updatedStarredTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'provider': serializer.toJson<String>(provider),
      'serverUrl': serializer.toJson<String>(serverUrl),
      'userName': serializer.toJson<String>(userName),
      'password': serializer.toJson<String>(password),
      'updatedArticleTime': serializer.toJson<int>(updatedArticleTime),
      'updatedStarredTime': serializer.toJson<int>(updatedStarredTime),
    };
  }

  AccountData copyWith(
          {int? id,
          String? provider,
          String? serverUrl,
          String? userName,
          String? password,
          int? updatedArticleTime,
          int? updatedStarredTime}) =>
      AccountData(
        id: id ?? this.id,
        provider: provider ?? this.provider,
        serverUrl: serverUrl ?? this.serverUrl,
        userName: userName ?? this.userName,
        password: password ?? this.password,
        updatedArticleTime: updatedArticleTime ?? this.updatedArticleTime,
        updatedStarredTime: updatedStarredTime ?? this.updatedStarredTime,
      );
  AccountData copyWithCompanion(AccountCompanion data) {
    return AccountData(
      id: data.id.present ? data.id.value : this.id,
      provider: data.provider.present ? data.provider.value : this.provider,
      serverUrl: data.serverUrl.present ? data.serverUrl.value : this.serverUrl,
      userName: data.userName.present ? data.userName.value : this.userName,
      password: data.password.present ? data.password.value : this.password,
      updatedArticleTime: data.updatedArticleTime.present
          ? data.updatedArticleTime.value
          : this.updatedArticleTime,
      updatedStarredTime: data.updatedStarredTime.present
          ? data.updatedStarredTime.value
          : this.updatedStarredTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountData(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('serverUrl: $serverUrl, ')
          ..write('userName: $userName, ')
          ..write('password: $password, ')
          ..write('updatedArticleTime: $updatedArticleTime, ')
          ..write('updatedStarredTime: $updatedStarredTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, provider, serverUrl, userName, password,
      updatedArticleTime, updatedStarredTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountData &&
          other.id == this.id &&
          other.provider == this.provider &&
          other.serverUrl == this.serverUrl &&
          other.userName == this.userName &&
          other.password == this.password &&
          other.updatedArticleTime == this.updatedArticleTime &&
          other.updatedStarredTime == this.updatedStarredTime);
}

class AccountCompanion extends UpdateCompanion<AccountData> {
  final Value<int> id;
  final Value<String> provider;
  final Value<String> serverUrl;
  final Value<String> userName;
  final Value<String> password;
  final Value<int> updatedArticleTime;
  final Value<int> updatedStarredTime;
  const AccountCompanion({
    this.id = const Value.absent(),
    this.provider = const Value.absent(),
    this.serverUrl = const Value.absent(),
    this.userName = const Value.absent(),
    this.password = const Value.absent(),
    this.updatedArticleTime = const Value.absent(),
    this.updatedStarredTime = const Value.absent(),
  });
  AccountCompanion.insert({
    this.id = const Value.absent(),
    required String provider,
    required String serverUrl,
    required String userName,
    required String password,
    required int updatedArticleTime,
    required int updatedStarredTime,
  })  : provider = Value(provider),
        serverUrl = Value(serverUrl),
        userName = Value(userName),
        password = Value(password),
        updatedArticleTime = Value(updatedArticleTime),
        updatedStarredTime = Value(updatedStarredTime);
  static Insertable<AccountData> custom({
    Expression<int>? id,
    Expression<String>? provider,
    Expression<String>? serverUrl,
    Expression<String>? userName,
    Expression<String>? password,
    Expression<int>? updatedArticleTime,
    Expression<int>? updatedStarredTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (provider != null) 'provider': provider,
      if (serverUrl != null) 'server_url': serverUrl,
      if (userName != null) 'user_name': userName,
      if (password != null) 'password': password,
      if (updatedArticleTime != null)
        'updated_article_time': updatedArticleTime,
      if (updatedStarredTime != null)
        'updated_starred_time': updatedStarredTime,
    });
  }

  AccountCompanion copyWith(
      {Value<int>? id,
      Value<String>? provider,
      Value<String>? serverUrl,
      Value<String>? userName,
      Value<String>? password,
      Value<int>? updatedArticleTime,
      Value<int>? updatedStarredTime}) {
    return AccountCompanion(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      serverUrl: serverUrl ?? this.serverUrl,
      userName: userName ?? this.userName,
      password: password ?? this.password,
      updatedArticleTime: updatedArticleTime ?? this.updatedArticleTime,
      updatedStarredTime: updatedStarredTime ?? this.updatedStarredTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (serverUrl.present) {
      map['server_url'] = Variable<String>(serverUrl.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (updatedArticleTime.present) {
      map['updated_article_time'] = Variable<int>(updatedArticleTime.value);
    }
    if (updatedStarredTime.present) {
      map['updated_starred_time'] = Variable<int>(updatedStarredTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountCompanion(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('serverUrl: $serverUrl, ')
          ..write('userName: $userName, ')
          ..write('password: $password, ')
          ..write('updatedArticleTime: $updatedArticleTime, ')
          ..write('updatedStarredTime: $updatedStarredTime')
          ..write(')'))
        .toString();
  }
}

class Category extends Table with TableInfo<Category, CategoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Category(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> serverID = GeneratedColumn<String>(
      'server_i_d', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<int> account = GeneratedColumn<int>(
      'account', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES account (id)'));
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> catUrl = GeneratedColumn<String>(
      'cat_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, serverID, account, title, catUrl];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {serverID, account},
      ];
  @override
  CategoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverID: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_i_d'])!,
      account: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      catUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cat_url'])!,
    );
  }

  @override
  Category createAlias(String alias) {
    return Category(attachedDatabase, alias);
  }
}

class CategoryData extends DataClass implements Insertable<CategoryData> {
  final int id;
  final String serverID;
  final int account;
  final String title;
  final String catUrl;
  const CategoryData(
      {required this.id,
      required this.serverID,
      required this.account,
      required this.title,
      required this.catUrl});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['server_i_d'] = Variable<String>(serverID);
    map['account'] = Variable<int>(account);
    map['title'] = Variable<String>(title);
    map['cat_url'] = Variable<String>(catUrl);
    return map;
  }

  CategoryCompanion toCompanion(bool nullToAbsent) {
    return CategoryCompanion(
      id: Value(id),
      serverID: Value(serverID),
      account: Value(account),
      title: Value(title),
      catUrl: Value(catUrl),
    );
  }

  factory CategoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryData(
      id: serializer.fromJson<int>(json['id']),
      serverID: serializer.fromJson<String>(json['serverID']),
      account: serializer.fromJson<int>(json['account']),
      title: serializer.fromJson<String>(json['title']),
      catUrl: serializer.fromJson<String>(json['catUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverID': serializer.toJson<String>(serverID),
      'account': serializer.toJson<int>(account),
      'title': serializer.toJson<String>(title),
      'catUrl': serializer.toJson<String>(catUrl),
    };
  }

  CategoryData copyWith(
          {int? id,
          String? serverID,
          int? account,
          String? title,
          String? catUrl}) =>
      CategoryData(
        id: id ?? this.id,
        serverID: serverID ?? this.serverID,
        account: account ?? this.account,
        title: title ?? this.title,
        catUrl: catUrl ?? this.catUrl,
      );
  CategoryData copyWithCompanion(CategoryCompanion data) {
    return CategoryData(
      id: data.id.present ? data.id.value : this.id,
      serverID: data.serverID.present ? data.serverID.value : this.serverID,
      account: data.account.present ? data.account.value : this.account,
      title: data.title.present ? data.title.value : this.title,
      catUrl: data.catUrl.present ? data.catUrl.value : this.catUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryData(')
          ..write('id: $id, ')
          ..write('serverID: $serverID, ')
          ..write('account: $account, ')
          ..write('title: $title, ')
          ..write('catUrl: $catUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, serverID, account, title, catUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryData &&
          other.id == this.id &&
          other.serverID == this.serverID &&
          other.account == this.account &&
          other.title == this.title &&
          other.catUrl == this.catUrl);
}

class CategoryCompanion extends UpdateCompanion<CategoryData> {
  final Value<int> id;
  final Value<String> serverID;
  final Value<int> account;
  final Value<String> title;
  final Value<String> catUrl;
  const CategoryCompanion({
    this.id = const Value.absent(),
    this.serverID = const Value.absent(),
    this.account = const Value.absent(),
    this.title = const Value.absent(),
    this.catUrl = const Value.absent(),
  });
  CategoryCompanion.insert({
    this.id = const Value.absent(),
    required String serverID,
    required int account,
    required String title,
    required String catUrl,
  })  : serverID = Value(serverID),
        account = Value(account),
        title = Value(title),
        catUrl = Value(catUrl);
  static Insertable<CategoryData> custom({
    Expression<int>? id,
    Expression<String>? serverID,
    Expression<int>? account,
    Expression<String>? title,
    Expression<String>? catUrl,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverID != null) 'server_i_d': serverID,
      if (account != null) 'account': account,
      if (title != null) 'title': title,
      if (catUrl != null) 'cat_url': catUrl,
    });
  }

  CategoryCompanion copyWith(
      {Value<int>? id,
      Value<String>? serverID,
      Value<int>? account,
      Value<String>? title,
      Value<String>? catUrl}) {
    return CategoryCompanion(
      id: id ?? this.id,
      serverID: serverID ?? this.serverID,
      account: account ?? this.account,
      title: title ?? this.title,
      catUrl: catUrl ?? this.catUrl,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverID.present) {
      map['server_i_d'] = Variable<String>(serverID.value);
    }
    if (account.present) {
      map['account'] = Variable<int>(account.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (catUrl.present) {
      map['cat_url'] = Variable<String>(catUrl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryCompanion(')
          ..write('id: $id, ')
          ..write('serverID: $serverID, ')
          ..write('account: $account, ')
          ..write('title: $title, ')
          ..write('catUrl: $catUrl')
          ..write(')'))
        .toString();
  }
}

class Subscription extends Table
    with TableInfo<Subscription, SubscriptionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Subscription(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> serverID = GeneratedColumn<String>(
      'server_i_d', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<int> account = GeneratedColumn<int>(
      'account', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES account (id)'));
  late final GeneratedColumn<int> category = GeneratedColumn<int>(
      'category', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES category (id)'));
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> htmlUrl = GeneratedColumn<String>(
      'html_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> iconUrl = GeneratedColumn<String>(
      'icon_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, serverID, account, category, title, url, htmlUrl, iconUrl];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscription';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {serverID, account},
      ];
  @override
  SubscriptionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubscriptionData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverID: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_i_d'])!,
      account: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      htmlUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}html_url'])!,
      iconUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_url'])!,
    );
  }

  @override
  Subscription createAlias(String alias) {
    return Subscription(attachedDatabase, alias);
  }
}

class SubscriptionData extends DataClass
    implements Insertable<SubscriptionData> {
  final int id;
  final String serverID;
  final int account;
  final int? category;
  final String title;
  final String url;
  final String htmlUrl;
  final String iconUrl;
  const SubscriptionData(
      {required this.id,
      required this.serverID,
      required this.account,
      this.category,
      required this.title,
      required this.url,
      required this.htmlUrl,
      required this.iconUrl});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['server_i_d'] = Variable<String>(serverID);
    map['account'] = Variable<int>(account);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<int>(category);
    }
    map['title'] = Variable<String>(title);
    map['url'] = Variable<String>(url);
    map['html_url'] = Variable<String>(htmlUrl);
    map['icon_url'] = Variable<String>(iconUrl);
    return map;
  }

  SubscriptionCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionCompanion(
      id: Value(id),
      serverID: Value(serverID),
      account: Value(account),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      title: Value(title),
      url: Value(url),
      htmlUrl: Value(htmlUrl),
      iconUrl: Value(iconUrl),
    );
  }

  factory SubscriptionData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubscriptionData(
      id: serializer.fromJson<int>(json['id']),
      serverID: serializer.fromJson<String>(json['serverID']),
      account: serializer.fromJson<int>(json['account']),
      category: serializer.fromJson<int?>(json['category']),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String>(json['url']),
      htmlUrl: serializer.fromJson<String>(json['htmlUrl']),
      iconUrl: serializer.fromJson<String>(json['iconUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverID': serializer.toJson<String>(serverID),
      'account': serializer.toJson<int>(account),
      'category': serializer.toJson<int?>(category),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
      'htmlUrl': serializer.toJson<String>(htmlUrl),
      'iconUrl': serializer.toJson<String>(iconUrl),
    };
  }

  SubscriptionData copyWith(
          {int? id,
          String? serverID,
          int? account,
          Value<int?> category = const Value.absent(),
          String? title,
          String? url,
          String? htmlUrl,
          String? iconUrl}) =>
      SubscriptionData(
        id: id ?? this.id,
        serverID: serverID ?? this.serverID,
        account: account ?? this.account,
        category: category.present ? category.value : this.category,
        title: title ?? this.title,
        url: url ?? this.url,
        htmlUrl: htmlUrl ?? this.htmlUrl,
        iconUrl: iconUrl ?? this.iconUrl,
      );
  SubscriptionData copyWithCompanion(SubscriptionCompanion data) {
    return SubscriptionData(
      id: data.id.present ? data.id.value : this.id,
      serverID: data.serverID.present ? data.serverID.value : this.serverID,
      account: data.account.present ? data.account.value : this.account,
      category: data.category.present ? data.category.value : this.category,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      htmlUrl: data.htmlUrl.present ? data.htmlUrl.value : this.htmlUrl,
      iconUrl: data.iconUrl.present ? data.iconUrl.value : this.iconUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionData(')
          ..write('id: $id, ')
          ..write('serverID: $serverID, ')
          ..write('account: $account, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('htmlUrl: $htmlUrl, ')
          ..write('iconUrl: $iconUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, serverID, account, category, title, url, htmlUrl, iconUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscriptionData &&
          other.id == this.id &&
          other.serverID == this.serverID &&
          other.account == this.account &&
          other.category == this.category &&
          other.title == this.title &&
          other.url == this.url &&
          other.htmlUrl == this.htmlUrl &&
          other.iconUrl == this.iconUrl);
}

class SubscriptionCompanion extends UpdateCompanion<SubscriptionData> {
  final Value<int> id;
  final Value<String> serverID;
  final Value<int> account;
  final Value<int?> category;
  final Value<String> title;
  final Value<String> url;
  final Value<String> htmlUrl;
  final Value<String> iconUrl;
  const SubscriptionCompanion({
    this.id = const Value.absent(),
    this.serverID = const Value.absent(),
    this.account = const Value.absent(),
    this.category = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.htmlUrl = const Value.absent(),
    this.iconUrl = const Value.absent(),
  });
  SubscriptionCompanion.insert({
    this.id = const Value.absent(),
    required String serverID,
    required int account,
    this.category = const Value.absent(),
    required String title,
    required String url,
    required String htmlUrl,
    required String iconUrl,
  })  : serverID = Value(serverID),
        account = Value(account),
        title = Value(title),
        url = Value(url),
        htmlUrl = Value(htmlUrl),
        iconUrl = Value(iconUrl);
  static Insertable<SubscriptionData> custom({
    Expression<int>? id,
    Expression<String>? serverID,
    Expression<int>? account,
    Expression<int>? category,
    Expression<String>? title,
    Expression<String>? url,
    Expression<String>? htmlUrl,
    Expression<String>? iconUrl,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverID != null) 'server_i_d': serverID,
      if (account != null) 'account': account,
      if (category != null) 'category': category,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (htmlUrl != null) 'html_url': htmlUrl,
      if (iconUrl != null) 'icon_url': iconUrl,
    });
  }

  SubscriptionCompanion copyWith(
      {Value<int>? id,
      Value<String>? serverID,
      Value<int>? account,
      Value<int?>? category,
      Value<String>? title,
      Value<String>? url,
      Value<String>? htmlUrl,
      Value<String>? iconUrl}) {
    return SubscriptionCompanion(
      id: id ?? this.id,
      serverID: serverID ?? this.serverID,
      account: account ?? this.account,
      category: category ?? this.category,
      title: title ?? this.title,
      url: url ?? this.url,
      htmlUrl: htmlUrl ?? this.htmlUrl,
      iconUrl: iconUrl ?? this.iconUrl,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverID.present) {
      map['server_i_d'] = Variable<String>(serverID.value);
    }
    if (account.present) {
      map['account'] = Variable<int>(account.value);
    }
    if (category.present) {
      map['category'] = Variable<int>(category.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (htmlUrl.present) {
      map['html_url'] = Variable<String>(htmlUrl.value);
    }
    if (iconUrl.present) {
      map['icon_url'] = Variable<String>(iconUrl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionCompanion(')
          ..write('id: $id, ')
          ..write('serverID: $serverID, ')
          ..write('account: $account, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('htmlUrl: $htmlUrl, ')
          ..write('iconUrl: $iconUrl')
          ..write(')'))
        .toString();
  }
}

class Article extends Table with TableInfo<Article, ArticleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Article(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> serverID = GeneratedColumn<String>(
      'server_i_d', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<int> subscription = GeneratedColumn<int>(
      'subscription', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES subscription (id)'));
  late final GeneratedColumn<int> account = GeneratedColumn<int>(
      'account', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES account (id)'));
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
      'image', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<int> published = GeneratedColumn<int>(
      'published', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<bool> read = GeneratedColumn<bool>(
      'read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("read" IN (0, 1))'));
  late final GeneratedColumn<bool> starred = GeneratedColumn<bool>(
      'starred', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("starred" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverID,
        subscription,
        account,
        title,
        url,
        content,
        image,
        published,
        read,
        starred
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'article';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {serverID, account, subscription},
      ];
  @override
  ArticleData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArticleData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverID: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_i_d'])!,
      subscription: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subscription'])!,
      account: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      image: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image']),
      published: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}published'])!,
      read: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}read'])!,
      starred: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}starred'])!,
    );
  }

  @override
  Article createAlias(String alias) {
    return Article(attachedDatabase, alias);
  }
}

class ArticleData extends DataClass implements Insertable<ArticleData> {
  final int id;
  final String serverID;
  final int subscription;
  final int account;
  final String title;
  final String url;
  final String content;
  final String? image;
  final int published;
  final bool read;
  final bool starred;
  const ArticleData(
      {required this.id,
      required this.serverID,
      required this.subscription,
      required this.account,
      required this.title,
      required this.url,
      required this.content,
      this.image,
      required this.published,
      required this.read,
      required this.starred});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['server_i_d'] = Variable<String>(serverID);
    map['subscription'] = Variable<int>(subscription);
    map['account'] = Variable<int>(account);
    map['title'] = Variable<String>(title);
    map['url'] = Variable<String>(url);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || image != null) {
      map['image'] = Variable<String>(image);
    }
    map['published'] = Variable<int>(published);
    map['read'] = Variable<bool>(read);
    map['starred'] = Variable<bool>(starred);
    return map;
  }

  ArticleCompanion toCompanion(bool nullToAbsent) {
    return ArticleCompanion(
      id: Value(id),
      serverID: Value(serverID),
      subscription: Value(subscription),
      account: Value(account),
      title: Value(title),
      url: Value(url),
      content: Value(content),
      image:
          image == null && nullToAbsent ? const Value.absent() : Value(image),
      published: Value(published),
      read: Value(read),
      starred: Value(starred),
    );
  }

  factory ArticleData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArticleData(
      id: serializer.fromJson<int>(json['id']),
      serverID: serializer.fromJson<String>(json['serverID']),
      subscription: serializer.fromJson<int>(json['subscription']),
      account: serializer.fromJson<int>(json['account']),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String>(json['url']),
      content: serializer.fromJson<String>(json['content']),
      image: serializer.fromJson<String?>(json['image']),
      published: serializer.fromJson<int>(json['published']),
      read: serializer.fromJson<bool>(json['read']),
      starred: serializer.fromJson<bool>(json['starred']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverID': serializer.toJson<String>(serverID),
      'subscription': serializer.toJson<int>(subscription),
      'account': serializer.toJson<int>(account),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
      'content': serializer.toJson<String>(content),
      'image': serializer.toJson<String?>(image),
      'published': serializer.toJson<int>(published),
      'read': serializer.toJson<bool>(read),
      'starred': serializer.toJson<bool>(starred),
    };
  }

  ArticleData copyWith(
          {int? id,
          String? serverID,
          int? subscription,
          int? account,
          String? title,
          String? url,
          String? content,
          Value<String?> image = const Value.absent(),
          int? published,
          bool? read,
          bool? starred}) =>
      ArticleData(
        id: id ?? this.id,
        serverID: serverID ?? this.serverID,
        subscription: subscription ?? this.subscription,
        account: account ?? this.account,
        title: title ?? this.title,
        url: url ?? this.url,
        content: content ?? this.content,
        image: image.present ? image.value : this.image,
        published: published ?? this.published,
        read: read ?? this.read,
        starred: starred ?? this.starred,
      );
  ArticleData copyWithCompanion(ArticleCompanion data) {
    return ArticleData(
      id: data.id.present ? data.id.value : this.id,
      serverID: data.serverID.present ? data.serverID.value : this.serverID,
      subscription: data.subscription.present
          ? data.subscription.value
          : this.subscription,
      account: data.account.present ? data.account.value : this.account,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      content: data.content.present ? data.content.value : this.content,
      image: data.image.present ? data.image.value : this.image,
      published: data.published.present ? data.published.value : this.published,
      read: data.read.present ? data.read.value : this.read,
      starred: data.starred.present ? data.starred.value : this.starred,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArticleData(')
          ..write('id: $id, ')
          ..write('serverID: $serverID, ')
          ..write('subscription: $subscription, ')
          ..write('account: $account, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('content: $content, ')
          ..write('image: $image, ')
          ..write('published: $published, ')
          ..write('read: $read, ')
          ..write('starred: $starred')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, serverID, subscription, account, title,
      url, content, image, published, read, starred);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArticleData &&
          other.id == this.id &&
          other.serverID == this.serverID &&
          other.subscription == this.subscription &&
          other.account == this.account &&
          other.title == this.title &&
          other.url == this.url &&
          other.content == this.content &&
          other.image == this.image &&
          other.published == this.published &&
          other.read == this.read &&
          other.starred == this.starred);
}

class ArticleCompanion extends UpdateCompanion<ArticleData> {
  final Value<int> id;
  final Value<String> serverID;
  final Value<int> subscription;
  final Value<int> account;
  final Value<String> title;
  final Value<String> url;
  final Value<String> content;
  final Value<String?> image;
  final Value<int> published;
  final Value<bool> read;
  final Value<bool> starred;
  const ArticleCompanion({
    this.id = const Value.absent(),
    this.serverID = const Value.absent(),
    this.subscription = const Value.absent(),
    this.account = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.content = const Value.absent(),
    this.image = const Value.absent(),
    this.published = const Value.absent(),
    this.read = const Value.absent(),
    this.starred = const Value.absent(),
  });
  ArticleCompanion.insert({
    this.id = const Value.absent(),
    required String serverID,
    required int subscription,
    required int account,
    required String title,
    required String url,
    required String content,
    this.image = const Value.absent(),
    required int published,
    required bool read,
    required bool starred,
  })  : serverID = Value(serverID),
        subscription = Value(subscription),
        account = Value(account),
        title = Value(title),
        url = Value(url),
        content = Value(content),
        published = Value(published),
        read = Value(read),
        starred = Value(starred);
  static Insertable<ArticleData> custom({
    Expression<int>? id,
    Expression<String>? serverID,
    Expression<int>? subscription,
    Expression<int>? account,
    Expression<String>? title,
    Expression<String>? url,
    Expression<String>? content,
    Expression<String>? image,
    Expression<int>? published,
    Expression<bool>? read,
    Expression<bool>? starred,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverID != null) 'server_i_d': serverID,
      if (subscription != null) 'subscription': subscription,
      if (account != null) 'account': account,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (content != null) 'content': content,
      if (image != null) 'image': image,
      if (published != null) 'published': published,
      if (read != null) 'read': read,
      if (starred != null) 'starred': starred,
    });
  }

  ArticleCompanion copyWith(
      {Value<int>? id,
      Value<String>? serverID,
      Value<int>? subscription,
      Value<int>? account,
      Value<String>? title,
      Value<String>? url,
      Value<String>? content,
      Value<String?>? image,
      Value<int>? published,
      Value<bool>? read,
      Value<bool>? starred}) {
    return ArticleCompanion(
      id: id ?? this.id,
      serverID: serverID ?? this.serverID,
      subscription: subscription ?? this.subscription,
      account: account ?? this.account,
      title: title ?? this.title,
      url: url ?? this.url,
      content: content ?? this.content,
      image: image ?? this.image,
      published: published ?? this.published,
      read: read ?? this.read,
      starred: starred ?? this.starred,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverID.present) {
      map['server_i_d'] = Variable<String>(serverID.value);
    }
    if (subscription.present) {
      map['subscription'] = Variable<int>(subscription.value);
    }
    if (account.present) {
      map['account'] = Variable<int>(account.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (published.present) {
      map['published'] = Variable<int>(published.value);
    }
    if (read.present) {
      map['read'] = Variable<bool>(read.value);
    }
    if (starred.present) {
      map['starred'] = Variable<bool>(starred.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticleCompanion(')
          ..write('id: $id, ')
          ..write('serverID: $serverID, ')
          ..write('subscription: $subscription, ')
          ..write('account: $account, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('content: $content, ')
          ..write('image: $image, ')
          ..write('published: $published, ')
          ..write('read: $read, ')
          ..write('starred: $starred')
          ..write(')'))
        .toString();
  }
}

class Delayed extends Table with TableInfo<Delayed, DelayedData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Delayed(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<int> account = GeneratedColumn<int>(
      'account', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES account (id)'));
  late final GeneratedColumn<int> article = GeneratedColumn<int>(
      'article', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES article (id)'));
  late final GeneratedColumn<int> action = GeneratedColumn<int>(
      'action', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, account, article, action];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'delayed';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DelayedData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DelayedData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      account: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account'])!,
      article: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}article'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}action'])!,
    );
  }

  @override
  Delayed createAlias(String alias) {
    return Delayed(attachedDatabase, alias);
  }
}

class DelayedData extends DataClass implements Insertable<DelayedData> {
  final int id;
  final int account;
  final int article;
  final int action;
  const DelayedData(
      {required this.id,
      required this.account,
      required this.article,
      required this.action});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account'] = Variable<int>(account);
    map['article'] = Variable<int>(article);
    map['action'] = Variable<int>(action);
    return map;
  }

  DelayedCompanion toCompanion(bool nullToAbsent) {
    return DelayedCompanion(
      id: Value(id),
      account: Value(account),
      article: Value(article),
      action: Value(action),
    );
  }

  factory DelayedData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DelayedData(
      id: serializer.fromJson<int>(json['id']),
      account: serializer.fromJson<int>(json['account']),
      article: serializer.fromJson<int>(json['article']),
      action: serializer.fromJson<int>(json['action']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'account': serializer.toJson<int>(account),
      'article': serializer.toJson<int>(article),
      'action': serializer.toJson<int>(action),
    };
  }

  DelayedData copyWith({int? id, int? account, int? article, int? action}) =>
      DelayedData(
        id: id ?? this.id,
        account: account ?? this.account,
        article: article ?? this.article,
        action: action ?? this.action,
      );
  DelayedData copyWithCompanion(DelayedCompanion data) {
    return DelayedData(
      id: data.id.present ? data.id.value : this.id,
      account: data.account.present ? data.account.value : this.account,
      article: data.article.present ? data.article.value : this.article,
      action: data.action.present ? data.action.value : this.action,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DelayedData(')
          ..write('id: $id, ')
          ..write('account: $account, ')
          ..write('article: $article, ')
          ..write('action: $action')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, account, article, action);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DelayedData &&
          other.id == this.id &&
          other.account == this.account &&
          other.article == this.article &&
          other.action == this.action);
}

class DelayedCompanion extends UpdateCompanion<DelayedData> {
  final Value<int> id;
  final Value<int> account;
  final Value<int> article;
  final Value<int> action;
  const DelayedCompanion({
    this.id = const Value.absent(),
    this.account = const Value.absent(),
    this.article = const Value.absent(),
    this.action = const Value.absent(),
  });
  DelayedCompanion.insert({
    this.id = const Value.absent(),
    required int account,
    required int article,
    required int action,
  })  : account = Value(account),
        article = Value(article),
        action = Value(action);
  static Insertable<DelayedData> custom({
    Expression<int>? id,
    Expression<int>? account,
    Expression<int>? article,
    Expression<int>? action,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (account != null) 'account': account,
      if (article != null) 'article': article,
      if (action != null) 'action': action,
    });
  }

  DelayedCompanion copyWith(
      {Value<int>? id,
      Value<int>? account,
      Value<int>? article,
      Value<int>? action}) {
    return DelayedCompanion(
      id: id ?? this.id,
      account: account ?? this.account,
      article: article ?? this.article,
      action: action ?? this.action,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (account.present) {
      map['account'] = Variable<int>(account.value);
    }
    if (article.present) {
      map['article'] = Variable<int>(article.value);
    }
    if (action.present) {
      map['action'] = Variable<int>(action.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DelayedCompanion(')
          ..write('id: $id, ')
          ..write('account: $account, ')
          ..write('article: $article, ')
          ..write('action: $action')
          ..write(')'))
        .toString();
  }
}

class Settings extends Table with TableInfo<Settings, SettingsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Settings(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  late final GeneratedColumn<double> fontSize = GeneratedColumn<double>(
      'font_size', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(14.0));
  late final GeneratedColumn<double> lineHeight = GeneratedColumn<double>(
      'line_height', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.5));
  late final GeneratedColumn<double> wordSpacing = GeneratedColumn<double>(
      'word_spacing', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  late final GeneratedColumn<String> font = GeneratedColumn<String>(
      'font', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant("Arial"));
  late final GeneratedColumn<bool> isBionic = GeneratedColumn<bool>(
      'is_bionic', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_bionic" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, accountId, fontSize, lineHeight, wordSpacing, font, isBionic];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id']),
      fontSize: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}font_size'])!,
      lineHeight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}line_height'])!,
      wordSpacing: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}word_spacing'])!,
      font: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}font'])!,
      isBionic: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_bionic'])!,
    );
  }

  @override
  Settings createAlias(String alias) {
    return Settings(attachedDatabase, alias);
  }
}

class SettingsData extends DataClass implements Insertable<SettingsData> {
  final int id;
  final int? accountId;
  final double fontSize;
  final double lineHeight;
  final double wordSpacing;
  final String font;
  final bool isBionic;
  const SettingsData(
      {required this.id,
      this.accountId,
      required this.fontSize,
      required this.lineHeight,
      required this.wordSpacing,
      required this.font,
      required this.isBionic});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    map['font_size'] = Variable<double>(fontSize);
    map['line_height'] = Variable<double>(lineHeight);
    map['word_spacing'] = Variable<double>(wordSpacing);
    map['font'] = Variable<String>(font);
    map['is_bionic'] = Variable<bool>(isBionic);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      fontSize: Value(fontSize),
      lineHeight: Value(lineHeight),
      wordSpacing: Value(wordSpacing),
      font: Value(font),
      isBionic: Value(isBionic),
    );
  }

  factory SettingsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsData(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      fontSize: serializer.fromJson<double>(json['fontSize']),
      lineHeight: serializer.fromJson<double>(json['lineHeight']),
      wordSpacing: serializer.fromJson<double>(json['wordSpacing']),
      font: serializer.fromJson<String>(json['font']),
      isBionic: serializer.fromJson<bool>(json['isBionic']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<int?>(accountId),
      'fontSize': serializer.toJson<double>(fontSize),
      'lineHeight': serializer.toJson<double>(lineHeight),
      'wordSpacing': serializer.toJson<double>(wordSpacing),
      'font': serializer.toJson<String>(font),
      'isBionic': serializer.toJson<bool>(isBionic),
    };
  }

  SettingsData copyWith(
          {int? id,
          Value<int?> accountId = const Value.absent(),
          double? fontSize,
          double? lineHeight,
          double? wordSpacing,
          String? font,
          bool? isBionic}) =>
      SettingsData(
        id: id ?? this.id,
        accountId: accountId.present ? accountId.value : this.accountId,
        fontSize: fontSize ?? this.fontSize,
        lineHeight: lineHeight ?? this.lineHeight,
        wordSpacing: wordSpacing ?? this.wordSpacing,
        font: font ?? this.font,
        isBionic: isBionic ?? this.isBionic,
      );
  SettingsData copyWithCompanion(SettingsCompanion data) {
    return SettingsData(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      fontSize: data.fontSize.present ? data.fontSize.value : this.fontSize,
      lineHeight:
          data.lineHeight.present ? data.lineHeight.value : this.lineHeight,
      wordSpacing:
          data.wordSpacing.present ? data.wordSpacing.value : this.wordSpacing,
      font: data.font.present ? data.font.value : this.font,
      isBionic: data.isBionic.present ? data.isBionic.value : this.isBionic,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsData(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('fontSize: $fontSize, ')
          ..write('lineHeight: $lineHeight, ')
          ..write('wordSpacing: $wordSpacing, ')
          ..write('font: $font, ')
          ..write('isBionic: $isBionic')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, accountId, fontSize, lineHeight, wordSpacing, font, isBionic);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsData &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.fontSize == this.fontSize &&
          other.lineHeight == this.lineHeight &&
          other.wordSpacing == this.wordSpacing &&
          other.font == this.font &&
          other.isBionic == this.isBionic);
}

class SettingsCompanion extends UpdateCompanion<SettingsData> {
  final Value<int> id;
  final Value<int?> accountId;
  final Value<double> fontSize;
  final Value<double> lineHeight;
  final Value<double> wordSpacing;
  final Value<String> font;
  final Value<bool> isBionic;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.fontSize = const Value.absent(),
    this.lineHeight = const Value.absent(),
    this.wordSpacing = const Value.absent(),
    this.font = const Value.absent(),
    this.isBionic = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.fontSize = const Value.absent(),
    this.lineHeight = const Value.absent(),
    this.wordSpacing = const Value.absent(),
    this.font = const Value.absent(),
    this.isBionic = const Value.absent(),
  });
  static Insertable<SettingsData> custom({
    Expression<int>? id,
    Expression<int>? accountId,
    Expression<double>? fontSize,
    Expression<double>? lineHeight,
    Expression<double>? wordSpacing,
    Expression<String>? font,
    Expression<bool>? isBionic,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (fontSize != null) 'font_size': fontSize,
      if (lineHeight != null) 'line_height': lineHeight,
      if (wordSpacing != null) 'word_spacing': wordSpacing,
      if (font != null) 'font': font,
      if (isBionic != null) 'is_bionic': isBionic,
    });
  }

  SettingsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? accountId,
      Value<double>? fontSize,
      Value<double>? lineHeight,
      Value<double>? wordSpacing,
      Value<String>? font,
      Value<bool>? isBionic}) {
    return SettingsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      font: font ?? this.font,
      isBionic: isBionic ?? this.isBionic,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (fontSize.present) {
      map['font_size'] = Variable<double>(fontSize.value);
    }
    if (lineHeight.present) {
      map['line_height'] = Variable<double>(lineHeight.value);
    }
    if (wordSpacing.present) {
      map['word_spacing'] = Variable<double>(wordSpacing.value);
    }
    if (font.present) {
      map['font'] = Variable<String>(font.value);
    }
    if (isBionic.present) {
      map['is_bionic'] = Variable<bool>(isBionic.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('fontSize: $fontSize, ')
          ..write('lineHeight: $lineHeight, ')
          ..write('wordSpacing: $wordSpacing, ')
          ..write('font: $font, ')
          ..write('isBionic: $isBionic')
          ..write(')'))
        .toString();
  }
}

class DatabaseAtV2 extends GeneratedDatabase {
  DatabaseAtV2(QueryExecutor e) : super(e);
  late final Account account = Account(this);
  late final Category category = Category(this);
  late final Subscription subscription = Subscription(this);
  late final Article article = Article(this);
  late final Delayed delayed = Delayed(this);
  late final Settings settings = Settings(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [account, category, subscription, article, delayed, settings];
  @override
  int get schemaVersion => 2;
}

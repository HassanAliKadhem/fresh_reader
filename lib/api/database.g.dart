// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AccountTable extends Account with TableInfo<$AccountTable, AccountData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _providerMeta =
      const VerificationMeta('provider');
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
      'provider', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverUrlMeta =
      const VerificationMeta('serverUrl');
  @override
  late final GeneratedColumn<String> serverUrl = GeneratedColumn<String>(
      'server_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userNameMeta =
      const VerificationMeta('userName');
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
      'user_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _passwordMeta =
      const VerificationMeta('password');
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
      'password', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedArticleTimeMeta =
      const VerificationMeta('updatedArticleTime');
  @override
  late final GeneratedColumn<int> updatedArticleTime = GeneratedColumn<int>(
      'updated_article_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedStarredTimeMeta =
      const VerificationMeta('updatedStarredTime');
  @override
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
  VerificationContext validateIntegrity(Insertable<AccountData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('provider')) {
      context.handle(_providerMeta,
          provider.isAcceptableOrUnknown(data['provider']!, _providerMeta));
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('server_url')) {
      context.handle(_serverUrlMeta,
          serverUrl.isAcceptableOrUnknown(data['server_url']!, _serverUrlMeta));
    } else if (isInserting) {
      context.missing(_serverUrlMeta);
    }
    if (data.containsKey('user_name')) {
      context.handle(_userNameMeta,
          userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta));
    } else if (isInserting) {
      context.missing(_userNameMeta);
    }
    if (data.containsKey('password')) {
      context.handle(_passwordMeta,
          password.isAcceptableOrUnknown(data['password']!, _passwordMeta));
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('updated_article_time')) {
      context.handle(
          _updatedArticleTimeMeta,
          updatedArticleTime.isAcceptableOrUnknown(
              data['updated_article_time']!, _updatedArticleTimeMeta));
    } else if (isInserting) {
      context.missing(_updatedArticleTimeMeta);
    }
    if (data.containsKey('updated_starred_time')) {
      context.handle(
          _updatedStarredTimeMeta,
          updatedStarredTime.isAcceptableOrUnknown(
              data['updated_starred_time']!, _updatedStarredTimeMeta));
    } else if (isInserting) {
      context.missing(_updatedStarredTimeMeta);
    }
    return context;
  }

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
  $AccountTable createAlias(String alias) {
    return $AccountTable(attachedDatabase, alias);
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

class $CategoryTable extends Category
    with TableInfo<$CategoryTable, CategoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIDMeta =
      const VerificationMeta('serverID');
  @override
  late final GeneratedColumn<String> serverID = GeneratedColumn<String>(
      'server_i_d', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountMeta =
      const VerificationMeta('account');
  @override
  late final GeneratedColumn<int> account = GeneratedColumn<int>(
      'account', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES account (id)'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _catUrlMeta = const VerificationMeta('catUrl');
  @override
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
  VerificationContext validateIntegrity(Insertable<CategoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_i_d')) {
      context.handle(_serverIDMeta,
          serverID.isAcceptableOrUnknown(data['server_i_d']!, _serverIDMeta));
    } else if (isInserting) {
      context.missing(_serverIDMeta);
    }
    if (data.containsKey('account')) {
      context.handle(_accountMeta,
          account.isAcceptableOrUnknown(data['account']!, _accountMeta));
    } else if (isInserting) {
      context.missing(_accountMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('cat_url')) {
      context.handle(_catUrlMeta,
          catUrl.isAcceptableOrUnknown(data['cat_url']!, _catUrlMeta));
    } else if (isInserting) {
      context.missing(_catUrlMeta);
    }
    return context;
  }

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
  $CategoryTable createAlias(String alias) {
    return $CategoryTable(attachedDatabase, alias);
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

class $SubscriptionTable extends Subscription
    with TableInfo<$SubscriptionTable, SubscriptionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIDMeta =
      const VerificationMeta('serverID');
  @override
  late final GeneratedColumn<String> serverID = GeneratedColumn<String>(
      'server_i_d', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountMeta =
      const VerificationMeta('account');
  @override
  late final GeneratedColumn<int> account = GeneratedColumn<int>(
      'account', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES account (id)'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<int> category = GeneratedColumn<int>(
      'category', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES category (id)'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _htmlUrlMeta =
      const VerificationMeta('htmlUrl');
  @override
  late final GeneratedColumn<String> htmlUrl = GeneratedColumn<String>(
      'html_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconUrlMeta =
      const VerificationMeta('iconUrl');
  @override
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
  VerificationContext validateIntegrity(Insertable<SubscriptionData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_i_d')) {
      context.handle(_serverIDMeta,
          serverID.isAcceptableOrUnknown(data['server_i_d']!, _serverIDMeta));
    } else if (isInserting) {
      context.missing(_serverIDMeta);
    }
    if (data.containsKey('account')) {
      context.handle(_accountMeta,
          account.isAcceptableOrUnknown(data['account']!, _accountMeta));
    } else if (isInserting) {
      context.missing(_accountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('html_url')) {
      context.handle(_htmlUrlMeta,
          htmlUrl.isAcceptableOrUnknown(data['html_url']!, _htmlUrlMeta));
    } else if (isInserting) {
      context.missing(_htmlUrlMeta);
    }
    if (data.containsKey('icon_url')) {
      context.handle(_iconUrlMeta,
          iconUrl.isAcceptableOrUnknown(data['icon_url']!, _iconUrlMeta));
    } else if (isInserting) {
      context.missing(_iconUrlMeta);
    }
    return context;
  }

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
  $SubscriptionTable createAlias(String alias) {
    return $SubscriptionTable(attachedDatabase, alias);
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

class $ArticleTable extends Article with TableInfo<$ArticleTable, ArticleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArticleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIDMeta =
      const VerificationMeta('serverID');
  @override
  late final GeneratedColumn<String> serverID = GeneratedColumn<String>(
      'server_i_d', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subscriptionMeta =
      const VerificationMeta('subscription');
  @override
  late final GeneratedColumn<int> subscription = GeneratedColumn<int>(
      'subscription', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES subscription (id)'));
  static const VerificationMeta _accountMeta =
      const VerificationMeta('account');
  @override
  late final GeneratedColumn<int> account = GeneratedColumn<int>(
      'account', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES account (id)'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
      'image', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _publishedMeta =
      const VerificationMeta('published');
  @override
  late final GeneratedColumn<int> published = GeneratedColumn<int>(
      'published', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _readMeta = const VerificationMeta('read');
  @override
  late final GeneratedColumn<bool> read = GeneratedColumn<bool>(
      'read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("read" IN (0, 1))'));
  static const VerificationMeta _starredMeta =
      const VerificationMeta('starred');
  @override
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
  VerificationContext validateIntegrity(Insertable<ArticleData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_i_d')) {
      context.handle(_serverIDMeta,
          serverID.isAcceptableOrUnknown(data['server_i_d']!, _serverIDMeta));
    } else if (isInserting) {
      context.missing(_serverIDMeta);
    }
    if (data.containsKey('subscription')) {
      context.handle(
          _subscriptionMeta,
          subscription.isAcceptableOrUnknown(
              data['subscription']!, _subscriptionMeta));
    } else if (isInserting) {
      context.missing(_subscriptionMeta);
    }
    if (data.containsKey('account')) {
      context.handle(_accountMeta,
          account.isAcceptableOrUnknown(data['account']!, _accountMeta));
    } else if (isInserting) {
      context.missing(_accountMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('image')) {
      context.handle(
          _imageMeta, image.isAcceptableOrUnknown(data['image']!, _imageMeta));
    }
    if (data.containsKey('published')) {
      context.handle(_publishedMeta,
          published.isAcceptableOrUnknown(data['published']!, _publishedMeta));
    } else if (isInserting) {
      context.missing(_publishedMeta);
    }
    if (data.containsKey('read')) {
      context.handle(
          _readMeta, read.isAcceptableOrUnknown(data['read']!, _readMeta));
    } else if (isInserting) {
      context.missing(_readMeta);
    }
    if (data.containsKey('starred')) {
      context.handle(_starredMeta,
          starred.isAcceptableOrUnknown(data['starred']!, _starredMeta));
    } else if (isInserting) {
      context.missing(_starredMeta);
    }
    return context;
  }

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
  $ArticleTable createAlias(String alias) {
    return $ArticleTable(attachedDatabase, alias);
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

class $DelayedTable extends Delayed with TableInfo<$DelayedTable, DelayedData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DelayedTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _accountMeta =
      const VerificationMeta('account');
  @override
  late final GeneratedColumn<int> account = GeneratedColumn<int>(
      'account', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES account (id)'));
  static const VerificationMeta _articleMeta =
      const VerificationMeta('article');
  @override
  late final GeneratedColumn<int> article = GeneratedColumn<int>(
      'article', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES article (id)'));
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
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
  VerificationContext validateIntegrity(Insertable<DelayedData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account')) {
      context.handle(_accountMeta,
          account.isAcceptableOrUnknown(data['account']!, _accountMeta));
    } else if (isInserting) {
      context.missing(_accountMeta);
    }
    if (data.containsKey('article')) {
      context.handle(_articleMeta,
          article.isAcceptableOrUnknown(data['article']!, _articleMeta));
    } else if (isInserting) {
      context.missing(_articleMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    return context;
  }

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
  $DelayedTable createAlias(String alias) {
    return $DelayedTable(attachedDatabase, alias);
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

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _fontSizeMeta =
      const VerificationMeta('fontSize');
  @override
  late final GeneratedColumn<double> fontSize = GeneratedColumn<double>(
      'font_size', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(14.0));
  static const VerificationMeta _lineHeightMeta =
      const VerificationMeta('lineHeight');
  @override
  late final GeneratedColumn<double> lineHeight = GeneratedColumn<double>(
      'line_height', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.5));
  static const VerificationMeta _wordSpacingMeta =
      const VerificationMeta('wordSpacing');
  @override
  late final GeneratedColumn<double> wordSpacing = GeneratedColumn<double>(
      'word_spacing', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _fontMeta = const VerificationMeta('font');
  @override
  late final GeneratedColumn<String> font = GeneratedColumn<String>(
      'font', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant("Arial"));
  static const VerificationMeta _isBionicMeta =
      const VerificationMeta('isBionic');
  @override
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
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('font_size')) {
      context.handle(_fontSizeMeta,
          fontSize.isAcceptableOrUnknown(data['font_size']!, _fontSizeMeta));
    }
    if (data.containsKey('line_height')) {
      context.handle(
          _lineHeightMeta,
          lineHeight.isAcceptableOrUnknown(
              data['line_height']!, _lineHeightMeta));
    }
    if (data.containsKey('word_spacing')) {
      context.handle(
          _wordSpacingMeta,
          wordSpacing.isAcceptableOrUnknown(
              data['word_spacing']!, _wordSpacingMeta));
    }
    if (data.containsKey('font')) {
      context.handle(
          _fontMeta, font.isAcceptableOrUnknown(data['font']!, _fontMeta));
    }
    if (data.containsKey('is_bionic')) {
      context.handle(_isBionicMeta,
          isBionic.isAcceptableOrUnknown(data['is_bionic']!, _isBionicMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
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
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final int id;
  final int? accountId;
  final double fontSize;
  final double lineHeight;
  final double wordSpacing;
  final String font;
  final bool isBionic;
  const Setting(
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

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
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

  Setting copyWith(
          {int? id,
          Value<int?> accountId = const Value.absent(),
          double? fontSize,
          double? lineHeight,
          double? wordSpacing,
          String? font,
          bool? isBionic}) =>
      Setting(
        id: id ?? this.id,
        accountId: accountId.present ? accountId.value : this.accountId,
        fontSize: fontSize ?? this.fontSize,
        lineHeight: lineHeight ?? this.lineHeight,
        wordSpacing: wordSpacing ?? this.wordSpacing,
        font: font ?? this.font,
        isBionic: isBionic ?? this.isBionic,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
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
    return (StringBuffer('Setting(')
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
      (other is Setting &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.fontSize == this.fontSize &&
          other.lineHeight == this.lineHeight &&
          other.wordSpacing == this.wordSpacing &&
          other.font == this.font &&
          other.isBionic == this.isBionic);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
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
  static Insertable<Setting> custom({
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountTable account = $AccountTable(this);
  late final $CategoryTable category = $CategoryTable(this);
  late final $SubscriptionTable subscription = $SubscriptionTable(this);
  late final $ArticleTable article = $ArticleTable(this);
  late final $DelayedTable delayed = $DelayedTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [account, category, subscription, article, delayed, settings];
}

typedef $$AccountTableCreateCompanionBuilder = AccountCompanion Function({
  Value<int> id,
  required String provider,
  required String serverUrl,
  required String userName,
  required String password,
  required int updatedArticleTime,
  required int updatedStarredTime,
});
typedef $$AccountTableUpdateCompanionBuilder = AccountCompanion Function({
  Value<int> id,
  Value<String> provider,
  Value<String> serverUrl,
  Value<String> userName,
  Value<String> password,
  Value<int> updatedArticleTime,
  Value<int> updatedStarredTime,
});

final class $$AccountTableReferences
    extends BaseReferences<_$AppDatabase, $AccountTable, AccountData> {
  $$AccountTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CategoryTable, List<CategoryData>>
      _categoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.category,
          aliasName: $_aliasNameGenerator(db.account.id, db.category.account));

  $$CategoryTableProcessedTableManager get categoryRefs {
    final manager = $$CategoryTableTableManager($_db, $_db.category)
        .filter((f) => f.account.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_categoryRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SubscriptionTable, List<SubscriptionData>>
      _subscriptionRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.subscription,
              aliasName:
                  $_aliasNameGenerator(db.account.id, db.subscription.account));

  $$SubscriptionTableProcessedTableManager get subscriptionRefs {
    final manager = $$SubscriptionTableTableManager($_db, $_db.subscription)
        .filter((f) => f.account.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_subscriptionRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ArticleTable, List<ArticleData>>
      _articleRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.article,
          aliasName: $_aliasNameGenerator(db.account.id, db.article.account));

  $$ArticleTableProcessedTableManager get articleRefs {
    final manager = $$ArticleTableTableManager($_db, $_db.article)
        .filter((f) => f.account.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_articleRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DelayedTable, List<DelayedData>>
      _delayedRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.delayed,
          aliasName: $_aliasNameGenerator(db.account.id, db.delayed.account));

  $$DelayedTableProcessedTableManager get delayedRefs {
    final manager = $$DelayedTableTableManager($_db, $_db.delayed)
        .filter((f) => f.account.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_delayedRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AccountTableFilterComposer
    extends Composer<_$AppDatabase, $AccountTable> {
  $$AccountTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverUrl => $composableBuilder(
      column: $table.serverUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userName => $composableBuilder(
      column: $table.userName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedArticleTime => $composableBuilder(
      column: $table.updatedArticleTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedStarredTime => $composableBuilder(
      column: $table.updatedStarredTime,
      builder: (column) => ColumnFilters(column));

  Expression<bool> categoryRefs(
      Expression<bool> Function($$CategoryTableFilterComposer f) f) {
    final $$CategoryTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.category,
        getReferencedColumn: (t) => t.account,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryTableFilterComposer(
              $db: $db,
              $table: $db.category,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> subscriptionRefs(
      Expression<bool> Function($$SubscriptionTableFilterComposer f) f) {
    final $$SubscriptionTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subscription,
        getReferencedColumn: (t) => t.account,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubscriptionTableFilterComposer(
              $db: $db,
              $table: $db.subscription,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> articleRefs(
      Expression<bool> Function($$ArticleTableFilterComposer f) f) {
    final $$ArticleTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.article,
        getReferencedColumn: (t) => t.account,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ArticleTableFilterComposer(
              $db: $db,
              $table: $db.article,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> delayedRefs(
      Expression<bool> Function($$DelayedTableFilterComposer f) f) {
    final $$DelayedTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.delayed,
        getReferencedColumn: (t) => t.account,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DelayedTableFilterComposer(
              $db: $db,
              $table: $db.delayed,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AccountTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountTable> {
  $$AccountTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverUrl => $composableBuilder(
      column: $table.serverUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userName => $composableBuilder(
      column: $table.userName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedArticleTime => $composableBuilder(
      column: $table.updatedArticleTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedStarredTime => $composableBuilder(
      column: $table.updatedStarredTime,
      builder: (column) => ColumnOrderings(column));
}

class $$AccountTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountTable> {
  $$AccountTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get serverUrl =>
      $composableBuilder(column: $table.serverUrl, builder: (column) => column);

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<int> get updatedArticleTime => $composableBuilder(
      column: $table.updatedArticleTime, builder: (column) => column);

  GeneratedColumn<int> get updatedStarredTime => $composableBuilder(
      column: $table.updatedStarredTime, builder: (column) => column);

  Expression<T> categoryRefs<T extends Object>(
      Expression<T> Function($$CategoryTableAnnotationComposer a) f) {
    final $$CategoryTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.category,
        getReferencedColumn: (t) => t.account,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryTableAnnotationComposer(
              $db: $db,
              $table: $db.category,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> subscriptionRefs<T extends Object>(
      Expression<T> Function($$SubscriptionTableAnnotationComposer a) f) {
    final $$SubscriptionTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subscription,
        getReferencedColumn: (t) => t.account,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubscriptionTableAnnotationComposer(
              $db: $db,
              $table: $db.subscription,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> articleRefs<T extends Object>(
      Expression<T> Function($$ArticleTableAnnotationComposer a) f) {
    final $$ArticleTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.article,
        getReferencedColumn: (t) => t.account,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ArticleTableAnnotationComposer(
              $db: $db,
              $table: $db.article,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> delayedRefs<T extends Object>(
      Expression<T> Function($$DelayedTableAnnotationComposer a) f) {
    final $$DelayedTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.delayed,
        getReferencedColumn: (t) => t.account,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DelayedTableAnnotationComposer(
              $db: $db,
              $table: $db.delayed,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AccountTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountTable,
    AccountData,
    $$AccountTableFilterComposer,
    $$AccountTableOrderingComposer,
    $$AccountTableAnnotationComposer,
    $$AccountTableCreateCompanionBuilder,
    $$AccountTableUpdateCompanionBuilder,
    (AccountData, $$AccountTableReferences),
    AccountData,
    PrefetchHooks Function(
        {bool categoryRefs,
        bool subscriptionRefs,
        bool articleRefs,
        bool delayedRefs})> {
  $$AccountTableTableManager(_$AppDatabase db, $AccountTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> provider = const Value.absent(),
            Value<String> serverUrl = const Value.absent(),
            Value<String> userName = const Value.absent(),
            Value<String> password = const Value.absent(),
            Value<int> updatedArticleTime = const Value.absent(),
            Value<int> updatedStarredTime = const Value.absent(),
          }) =>
              AccountCompanion(
            id: id,
            provider: provider,
            serverUrl: serverUrl,
            userName: userName,
            password: password,
            updatedArticleTime: updatedArticleTime,
            updatedStarredTime: updatedStarredTime,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String provider,
            required String serverUrl,
            required String userName,
            required String password,
            required int updatedArticleTime,
            required int updatedStarredTime,
          }) =>
              AccountCompanion.insert(
            id: id,
            provider: provider,
            serverUrl: serverUrl,
            userName: userName,
            password: password,
            updatedArticleTime: updatedArticleTime,
            updatedStarredTime: updatedStarredTime,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$AccountTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {categoryRefs = false,
              subscriptionRefs = false,
              articleRefs = false,
              delayedRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (categoryRefs) db.category,
                if (subscriptionRefs) db.subscription,
                if (articleRefs) db.article,
                if (delayedRefs) db.delayed
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (categoryRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$AccountTableReferences._categoryRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountTableReferences(db, table, p0)
                                .categoryRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.account == item.id),
                        typedResults: items),
                  if (subscriptionRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$AccountTableReferences._subscriptionRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountTableReferences(db, table, p0)
                                .subscriptionRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.account == item.id),
                        typedResults: items),
                  if (articleRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$AccountTableReferences._articleRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountTableReferences(db, table, p0).articleRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.account == item.id),
                        typedResults: items),
                  if (delayedRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$AccountTableReferences._delayedRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountTableReferences(db, table, p0).delayedRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.account == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AccountTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountTable,
    AccountData,
    $$AccountTableFilterComposer,
    $$AccountTableOrderingComposer,
    $$AccountTableAnnotationComposer,
    $$AccountTableCreateCompanionBuilder,
    $$AccountTableUpdateCompanionBuilder,
    (AccountData, $$AccountTableReferences),
    AccountData,
    PrefetchHooks Function(
        {bool categoryRefs,
        bool subscriptionRefs,
        bool articleRefs,
        bool delayedRefs})>;
typedef $$CategoryTableCreateCompanionBuilder = CategoryCompanion Function({
  Value<int> id,
  required String serverID,
  required int account,
  required String title,
  required String catUrl,
});
typedef $$CategoryTableUpdateCompanionBuilder = CategoryCompanion Function({
  Value<int> id,
  Value<String> serverID,
  Value<int> account,
  Value<String> title,
  Value<String> catUrl,
});

final class $$CategoryTableReferences
    extends BaseReferences<_$AppDatabase, $CategoryTable, CategoryData> {
  $$CategoryTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountTable _accountTable(_$AppDatabase db) => db.account
      .createAlias($_aliasNameGenerator(db.category.account, db.account.id));

  $$AccountTableProcessedTableManager get account {
    final manager = $$AccountTableTableManager($_db, $_db.account)
        .filter((f) => f.id($_item.account!));
    final item = $_typedResult.readTableOrNull(_accountTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SubscriptionTable, List<SubscriptionData>>
      _subscriptionRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.subscription,
          aliasName:
              $_aliasNameGenerator(db.category.id, db.subscription.category));

  $$SubscriptionTableProcessedTableManager get subscriptionRefs {
    final manager = $$SubscriptionTableTableManager($_db, $_db.subscription)
        .filter((f) => f.category.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_subscriptionRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoryTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryTable> {
  $$CategoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverID => $composableBuilder(
      column: $table.serverID, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get catUrl => $composableBuilder(
      column: $table.catUrl, builder: (column) => ColumnFilters(column));

  $$AccountTableFilterComposer get account {
    final $$AccountTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.account,
        referencedTable: $db.account,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountTableFilterComposer(
              $db: $db,
              $table: $db.account,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> subscriptionRefs(
      Expression<bool> Function($$SubscriptionTableFilterComposer f) f) {
    final $$SubscriptionTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subscription,
        getReferencedColumn: (t) => t.category,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubscriptionTableFilterComposer(
              $db: $db,
              $table: $db.subscription,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoryTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryTable> {
  $$CategoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverID => $composableBuilder(
      column: $table.serverID, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get catUrl => $composableBuilder(
      column: $table.catUrl, builder: (column) => ColumnOrderings(column));

  $$AccountTableOrderingComposer get account {
    final $$AccountTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.account,
        referencedTable: $db.account,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountTableOrderingComposer(
              $db: $db,
              $table: $db.account,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CategoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryTable> {
  $$CategoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverID =>
      $composableBuilder(column: $table.serverID, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get catUrl =>
      $composableBuilder(column: $table.catUrl, builder: (column) => column);

  $$AccountTableAnnotationComposer get account {
    final $$AccountTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.account,
        referencedTable: $db.account,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountTableAnnotationComposer(
              $db: $db,
              $table: $db.account,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> subscriptionRefs<T extends Object>(
      Expression<T> Function($$SubscriptionTableAnnotationComposer a) f) {
    final $$SubscriptionTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subscription,
        getReferencedColumn: (t) => t.category,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubscriptionTableAnnotationComposer(
              $db: $db,
              $table: $db.subscription,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoryTable,
    CategoryData,
    $$CategoryTableFilterComposer,
    $$CategoryTableOrderingComposer,
    $$CategoryTableAnnotationComposer,
    $$CategoryTableCreateCompanionBuilder,
    $$CategoryTableUpdateCompanionBuilder,
    (CategoryData, $$CategoryTableReferences),
    CategoryData,
    PrefetchHooks Function({bool account, bool subscriptionRefs})> {
  $$CategoryTableTableManager(_$AppDatabase db, $CategoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> serverID = const Value.absent(),
            Value<int> account = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> catUrl = const Value.absent(),
          }) =>
              CategoryCompanion(
            id: id,
            serverID: serverID,
            account: account,
            title: title,
            catUrl: catUrl,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String serverID,
            required int account,
            required String title,
            required String catUrl,
          }) =>
              CategoryCompanion.insert(
            id: id,
            serverID: serverID,
            account: account,
            title: title,
            catUrl: catUrl,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$CategoryTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({account = false, subscriptionRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (subscriptionRefs) db.subscription],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (account) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.account,
                    referencedTable:
                        $$CategoryTableReferences._accountTable(db),
                    referencedColumn:
                        $$CategoryTableReferences._accountTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (subscriptionRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$CategoryTableReferences
                            ._subscriptionRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoryTableReferences(db, table, p0)
                                .subscriptionRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.category == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoryTable,
    CategoryData,
    $$CategoryTableFilterComposer,
    $$CategoryTableOrderingComposer,
    $$CategoryTableAnnotationComposer,
    $$CategoryTableCreateCompanionBuilder,
    $$CategoryTableUpdateCompanionBuilder,
    (CategoryData, $$CategoryTableReferences),
    CategoryData,
    PrefetchHooks Function({bool account, bool subscriptionRefs})>;
typedef $$SubscriptionTableCreateCompanionBuilder = SubscriptionCompanion
    Function({
  Value<int> id,
  required String serverID,
  required int account,
  Value<int?> category,
  required String title,
  required String url,
  required String htmlUrl,
  required String iconUrl,
});
typedef $$SubscriptionTableUpdateCompanionBuilder = SubscriptionCompanion
    Function({
  Value<int> id,
  Value<String> serverID,
  Value<int> account,
  Value<int?> category,
  Value<String> title,
  Value<String> url,
  Value<String> htmlUrl,
  Value<String> iconUrl,
});

final class $$SubscriptionTableReferences extends BaseReferences<_$AppDatabase,
    $SubscriptionTable, SubscriptionData> {
  $$SubscriptionTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountTable _accountTable(_$AppDatabase db) =>
      db.account.createAlias(
          $_aliasNameGenerator(db.subscription.account, db.account.id));

  $$AccountTableProcessedTableManager get account {
    final manager = $$AccountTableTableManager($_db, $_db.account)
        .filter((f) => f.id($_item.account!));
    final item = $_typedResult.readTableOrNull(_accountTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CategoryTable _categoryTable(_$AppDatabase db) =>
      db.category.createAlias(
          $_aliasNameGenerator(db.subscription.category, db.category.id));

  $$CategoryTableProcessedTableManager? get category {
    if ($_item.category == null) return null;
    final manager = $$CategoryTableTableManager($_db, $_db.category)
        .filter((f) => f.id($_item.category!));
    final item = $_typedResult.readTableOrNull(_categoryTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ArticleTable, List<ArticleData>>
      _articleRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.article,
              aliasName: $_aliasNameGenerator(
                  db.subscription.id, db.article.subscription));

  $$ArticleTableProcessedTableManager get articleRefs {
    final manager = $$ArticleTableTableManager($_db, $_db.article)
        .filter((f) => f.subscription.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_articleRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SubscriptionTableFilterComposer
    extends Composer<_$AppDatabase, $SubscriptionTable> {
  $$SubscriptionTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverID => $composableBuilder(
      column: $table.serverID, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get htmlUrl => $composableBuilder(
      column: $table.htmlUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconUrl => $composableBuilder(
      column: $table.iconUrl, builder: (column) => ColumnFilters(column));

  $$AccountTableFilterComposer get account {
    final $$AccountTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.account,
        referencedTable: $db.account,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountTableFilterComposer(
              $db: $db,
              $table: $db.account,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoryTableFilterComposer get category {
    final $$CategoryTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.category,
        referencedTable: $db.category,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryTableFilterComposer(
              $db: $db,
              $table: $db.category,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> articleRefs(
      Expression<bool> Function($$ArticleTableFilterComposer f) f) {
    final $$ArticleTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.article,
        getReferencedColumn: (t) => t.subscription,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ArticleTableFilterComposer(
              $db: $db,
              $table: $db.article,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SubscriptionTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscriptionTable> {
  $$SubscriptionTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverID => $composableBuilder(
      column: $table.serverID, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get htmlUrl => $composableBuilder(
      column: $table.htmlUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconUrl => $composableBuilder(
      column: $table.iconUrl, builder: (column) => ColumnOrderings(column));

  $$AccountTableOrderingComposer get account {
    final $$AccountTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.account,
        referencedTable: $db.account,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountTableOrderingComposer(
              $db: $db,
              $table: $db.account,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoryTableOrderingComposer get category {
    final $$CategoryTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.category,
        referencedTable: $db.category,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryTableOrderingComposer(
              $db: $db,
              $table: $db.category,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SubscriptionTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscriptionTable> {
  $$SubscriptionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverID =>
      $composableBuilder(column: $table.serverID, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get htmlUrl =>
      $composableBuilder(column: $table.htmlUrl, builder: (column) => column);

  GeneratedColumn<String> get iconUrl =>
      $composableBuilder(column: $table.iconUrl, builder: (column) => column);

  $$AccountTableAnnotationComposer get account {
    final $$AccountTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.account,
        referencedTable: $db.account,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountTableAnnotationComposer(
              $db: $db,
              $table: $db.account,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoryTableAnnotationComposer get category {
    final $$CategoryTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.category,
        referencedTable: $db.category,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryTableAnnotationComposer(
              $db: $db,
              $table: $db.category,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> articleRefs<T extends Object>(
      Expression<T> Function($$ArticleTableAnnotationComposer a) f) {
    final $$ArticleTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.article,
        getReferencedColumn: (t) => t.subscription,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ArticleTableAnnotationComposer(
              $db: $db,
              $table: $db.article,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SubscriptionTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubscriptionTable,
    SubscriptionData,
    $$SubscriptionTableFilterComposer,
    $$SubscriptionTableOrderingComposer,
    $$SubscriptionTableAnnotationComposer,
    $$SubscriptionTableCreateCompanionBuilder,
    $$SubscriptionTableUpdateCompanionBuilder,
    (SubscriptionData, $$SubscriptionTableReferences),
    SubscriptionData,
    PrefetchHooks Function({bool account, bool category, bool articleRefs})> {
  $$SubscriptionTableTableManager(_$AppDatabase db, $SubscriptionTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscriptionTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> serverID = const Value.absent(),
            Value<int> account = const Value.absent(),
            Value<int?> category = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String> htmlUrl = const Value.absent(),
            Value<String> iconUrl = const Value.absent(),
          }) =>
              SubscriptionCompanion(
            id: id,
            serverID: serverID,
            account: account,
            category: category,
            title: title,
            url: url,
            htmlUrl: htmlUrl,
            iconUrl: iconUrl,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String serverID,
            required int account,
            Value<int?> category = const Value.absent(),
            required String title,
            required String url,
            required String htmlUrl,
            required String iconUrl,
          }) =>
              SubscriptionCompanion.insert(
            id: id,
            serverID: serverID,
            account: account,
            category: category,
            title: title,
            url: url,
            htmlUrl: htmlUrl,
            iconUrl: iconUrl,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SubscriptionTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {account = false, category = false, articleRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (articleRefs) db.article],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (account) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.account,
                    referencedTable:
                        $$SubscriptionTableReferences._accountTable(db),
                    referencedColumn:
                        $$SubscriptionTableReferences._accountTable(db).id,
                  ) as T;
                }
                if (category) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.category,
                    referencedTable:
                        $$SubscriptionTableReferences._categoryTable(db),
                    referencedColumn:
                        $$SubscriptionTableReferences._categoryTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (articleRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$SubscriptionTableReferences._articleRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SubscriptionTableReferences(db, table, p0)
                                .articleRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.subscription == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SubscriptionTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubscriptionTable,
    SubscriptionData,
    $$SubscriptionTableFilterComposer,
    $$SubscriptionTableOrderingComposer,
    $$SubscriptionTableAnnotationComposer,
    $$SubscriptionTableCreateCompanionBuilder,
    $$SubscriptionTableUpdateCompanionBuilder,
    (SubscriptionData, $$SubscriptionTableReferences),
    SubscriptionData,
    PrefetchHooks Function({bool account, bool category, bool articleRefs})>;
typedef $$ArticleTableCreateCompanionBuilder = ArticleCompanion Function({
  Value<int> id,
  required String serverID,
  required int subscription,
  required int account,
  required String title,
  required String url,
  required String content,
  Value<String?> image,
  required int published,
  required bool read,
  required bool starred,
});
typedef $$ArticleTableUpdateCompanionBuilder = ArticleCompanion Function({
  Value<int> id,
  Value<String> serverID,
  Value<int> subscription,
  Value<int> account,
  Value<String> title,
  Value<String> url,
  Value<String> content,
  Value<String?> image,
  Value<int> published,
  Value<bool> read,
  Value<bool> starred,
});

final class $$ArticleTableReferences
    extends BaseReferences<_$AppDatabase, $ArticleTable, ArticleData> {
  $$ArticleTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SubscriptionTable _subscriptionTable(_$AppDatabase db) =>
      db.subscription.createAlias(
          $_aliasNameGenerator(db.article.subscription, db.subscription.id));

  $$SubscriptionTableProcessedTableManager get subscription {
    final manager = $$SubscriptionTableTableManager($_db, $_db.subscription)
        .filter((f) => f.id($_item.subscription!));
    final item = $_typedResult.readTableOrNull(_subscriptionTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AccountTable _accountTable(_$AppDatabase db) => db.account
      .createAlias($_aliasNameGenerator(db.article.account, db.account.id));

  $$AccountTableProcessedTableManager get account {
    final manager = $$AccountTableTableManager($_db, $_db.account)
        .filter((f) => f.id($_item.account!));
    final item = $_typedResult.readTableOrNull(_accountTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$DelayedTable, List<DelayedData>>
      _delayedRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.delayed,
          aliasName: $_aliasNameGenerator(db.article.id, db.delayed.article));

  $$DelayedTableProcessedTableManager get delayedRefs {
    final manager = $$DelayedTableTableManager($_db, $_db.delayed)
        .filter((f) => f.article.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_delayedRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ArticleTableFilterComposer
    extends Composer<_$AppDatabase, $ArticleTable> {
  $$ArticleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverID => $composableBuilder(
      column: $table.serverID, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get image => $composableBuilder(
      column: $table.image, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get published => $composableBuilder(
      column: $table.published, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get read => $composableBuilder(
      column: $table.read, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get starred => $composableBuilder(
      column: $table.starred, builder: (column) => ColumnFilters(column));

  $$SubscriptionTableFilterComposer get subscription {
    final $$SubscriptionTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subscription,
        referencedTable: $db.subscription,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubscriptionTableFilterComposer(
              $db: $db,
              $table: $db.subscription,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountTableFilterComposer get account {
    final $$AccountTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.account,
        referencedTable: $db.account,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountTableFilterComposer(
              $db: $db,
              $table: $db.account,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> delayedRefs(
      Expression<bool> Function($$DelayedTableFilterComposer f) f) {
    final $$DelayedTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.delayed,
        getReferencedColumn: (t) => t.article,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DelayedTableFilterComposer(
              $db: $db,
              $table: $db.delayed,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ArticleTableOrderingComposer
    extends Composer<_$AppDatabase, $ArticleTable> {
  $$ArticleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverID => $composableBuilder(
      column: $table.serverID, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get image => $composableBuilder(
      column: $table.image, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get published => $composableBuilder(
      column: $table.published, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get read => $composableBuilder(
      column: $table.read, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get starred => $composableBuilder(
      column: $table.starred, builder: (column) => ColumnOrderings(column));

  $$SubscriptionTableOrderingComposer get subscription {
    final $$SubscriptionTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subscription,
        referencedTable: $db.subscription,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubscriptionTableOrderingComposer(
              $db: $db,
              $table: $db.subscription,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountTableOrderingComposer get account {
    final $$AccountTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.account,
        referencedTable: $db.account,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountTableOrderingComposer(
              $db: $db,
              $table: $db.account,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ArticleTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArticleTable> {
  $$ArticleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverID =>
      $composableBuilder(column: $table.serverID, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  GeneratedColumn<int> get published =>
      $composableBuilder(column: $table.published, builder: (column) => column);

  GeneratedColumn<bool> get read =>
      $composableBuilder(column: $table.read, builder: (column) => column);

  GeneratedColumn<bool> get starred =>
      $composableBuilder(column: $table.starred, builder: (column) => column);

  $$SubscriptionTableAnnotationComposer get subscription {
    final $$SubscriptionTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subscription,
        referencedTable: $db.subscription,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubscriptionTableAnnotationComposer(
              $db: $db,
              $table: $db.subscription,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountTableAnnotationComposer get account {
    final $$AccountTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.account,
        referencedTable: $db.account,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountTableAnnotationComposer(
              $db: $db,
              $table: $db.account,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> delayedRefs<T extends Object>(
      Expression<T> Function($$DelayedTableAnnotationComposer a) f) {
    final $$DelayedTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.delayed,
        getReferencedColumn: (t) => t.article,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DelayedTableAnnotationComposer(
              $db: $db,
              $table: $db.delayed,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ArticleTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ArticleTable,
    ArticleData,
    $$ArticleTableFilterComposer,
    $$ArticleTableOrderingComposer,
    $$ArticleTableAnnotationComposer,
    $$ArticleTableCreateCompanionBuilder,
    $$ArticleTableUpdateCompanionBuilder,
    (ArticleData, $$ArticleTableReferences),
    ArticleData,
    PrefetchHooks Function(
        {bool subscription, bool account, bool delayedRefs})> {
  $$ArticleTableTableManager(_$AppDatabase db, $ArticleTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArticleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArticleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArticleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> serverID = const Value.absent(),
            Value<int> subscription = const Value.absent(),
            Value<int> account = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String?> image = const Value.absent(),
            Value<int> published = const Value.absent(),
            Value<bool> read = const Value.absent(),
            Value<bool> starred = const Value.absent(),
          }) =>
              ArticleCompanion(
            id: id,
            serverID: serverID,
            subscription: subscription,
            account: account,
            title: title,
            url: url,
            content: content,
            image: image,
            published: published,
            read: read,
            starred: starred,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String serverID,
            required int subscription,
            required int account,
            required String title,
            required String url,
            required String content,
            Value<String?> image = const Value.absent(),
            required int published,
            required bool read,
            required bool starred,
          }) =>
              ArticleCompanion.insert(
            id: id,
            serverID: serverID,
            subscription: subscription,
            account: account,
            title: title,
            url: url,
            content: content,
            image: image,
            published: published,
            read: read,
            starred: starred,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ArticleTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {subscription = false, account = false, delayedRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (delayedRefs) db.delayed],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (subscription) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.subscription,
                    referencedTable:
                        $$ArticleTableReferences._subscriptionTable(db),
                    referencedColumn:
                        $$ArticleTableReferences._subscriptionTable(db).id,
                  ) as T;
                }
                if (account) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.account,
                    referencedTable: $$ArticleTableReferences._accountTable(db),
                    referencedColumn:
                        $$ArticleTableReferences._accountTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (delayedRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ArticleTableReferences._delayedRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ArticleTableReferences(db, table, p0).delayedRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.article == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ArticleTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ArticleTable,
    ArticleData,
    $$ArticleTableFilterComposer,
    $$ArticleTableOrderingComposer,
    $$ArticleTableAnnotationComposer,
    $$ArticleTableCreateCompanionBuilder,
    $$ArticleTableUpdateCompanionBuilder,
    (ArticleData, $$ArticleTableReferences),
    ArticleData,
    PrefetchHooks Function(
        {bool subscription, bool account, bool delayedRefs})>;
typedef $$DelayedTableCreateCompanionBuilder = DelayedCompanion Function({
  Value<int> id,
  required int account,
  required int article,
  required int action,
});
typedef $$DelayedTableUpdateCompanionBuilder = DelayedCompanion Function({
  Value<int> id,
  Value<int> account,
  Value<int> article,
  Value<int> action,
});

final class $$DelayedTableReferences
    extends BaseReferences<_$AppDatabase, $DelayedTable, DelayedData> {
  $$DelayedTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountTable _accountTable(_$AppDatabase db) => db.account
      .createAlias($_aliasNameGenerator(db.delayed.account, db.account.id));

  $$AccountTableProcessedTableManager get account {
    final manager = $$AccountTableTableManager($_db, $_db.account)
        .filter((f) => f.id($_item.account!));
    final item = $_typedResult.readTableOrNull(_accountTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ArticleTable _articleTable(_$AppDatabase db) => db.article
      .createAlias($_aliasNameGenerator(db.delayed.article, db.article.id));

  $$ArticleTableProcessedTableManager get article {
    final manager = $$ArticleTableTableManager($_db, $_db.article)
        .filter((f) => f.id($_item.article!));
    final item = $_typedResult.readTableOrNull(_articleTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DelayedTableFilterComposer
    extends Composer<_$AppDatabase, $DelayedTable> {
  $$DelayedTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  $$AccountTableFilterComposer get account {
    final $$AccountTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.account,
        referencedTable: $db.account,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountTableFilterComposer(
              $db: $db,
              $table: $db.account,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ArticleTableFilterComposer get article {
    final $$ArticleTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.article,
        referencedTable: $db.article,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ArticleTableFilterComposer(
              $db: $db,
              $table: $db.article,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DelayedTableOrderingComposer
    extends Composer<_$AppDatabase, $DelayedTable> {
  $$DelayedTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  $$AccountTableOrderingComposer get account {
    final $$AccountTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.account,
        referencedTable: $db.account,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountTableOrderingComposer(
              $db: $db,
              $table: $db.account,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ArticleTableOrderingComposer get article {
    final $$ArticleTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.article,
        referencedTable: $db.article,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ArticleTableOrderingComposer(
              $db: $db,
              $table: $db.article,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DelayedTableAnnotationComposer
    extends Composer<_$AppDatabase, $DelayedTable> {
  $$DelayedTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  $$AccountTableAnnotationComposer get account {
    final $$AccountTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.account,
        referencedTable: $db.account,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountTableAnnotationComposer(
              $db: $db,
              $table: $db.account,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ArticleTableAnnotationComposer get article {
    final $$ArticleTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.article,
        referencedTable: $db.article,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ArticleTableAnnotationComposer(
              $db: $db,
              $table: $db.article,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DelayedTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DelayedTable,
    DelayedData,
    $$DelayedTableFilterComposer,
    $$DelayedTableOrderingComposer,
    $$DelayedTableAnnotationComposer,
    $$DelayedTableCreateCompanionBuilder,
    $$DelayedTableUpdateCompanionBuilder,
    (DelayedData, $$DelayedTableReferences),
    DelayedData,
    PrefetchHooks Function({bool account, bool article})> {
  $$DelayedTableTableManager(_$AppDatabase db, $DelayedTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DelayedTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DelayedTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DelayedTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> account = const Value.absent(),
            Value<int> article = const Value.absent(),
            Value<int> action = const Value.absent(),
          }) =>
              DelayedCompanion(
            id: id,
            account: account,
            article: article,
            action: action,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int account,
            required int article,
            required int action,
          }) =>
              DelayedCompanion.insert(
            id: id,
            account: account,
            article: article,
            action: action,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$DelayedTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({account = false, article = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (account) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.account,
                    referencedTable: $$DelayedTableReferences._accountTable(db),
                    referencedColumn:
                        $$DelayedTableReferences._accountTable(db).id,
                  ) as T;
                }
                if (article) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.article,
                    referencedTable: $$DelayedTableReferences._articleTable(db),
                    referencedColumn:
                        $$DelayedTableReferences._articleTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DelayedTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DelayedTable,
    DelayedData,
    $$DelayedTableFilterComposer,
    $$DelayedTableOrderingComposer,
    $$DelayedTableAnnotationComposer,
    $$DelayedTableCreateCompanionBuilder,
    $$DelayedTableUpdateCompanionBuilder,
    (DelayedData, $$DelayedTableReferences),
    DelayedData,
    PrefetchHooks Function({bool account, bool article})>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<int?> accountId,
  Value<double> fontSize,
  Value<double> lineHeight,
  Value<double> wordSpacing,
  Value<String> font,
  Value<bool> isBionic,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<int?> accountId,
  Value<double> fontSize,
  Value<double> lineHeight,
  Value<double> wordSpacing,
  Value<String> font,
  Value<bool> isBionic,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fontSize => $composableBuilder(
      column: $table.fontSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lineHeight => $composableBuilder(
      column: $table.lineHeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get wordSpacing => $composableBuilder(
      column: $table.wordSpacing, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get font => $composableBuilder(
      column: $table.font, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isBionic => $composableBuilder(
      column: $table.isBionic, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fontSize => $composableBuilder(
      column: $table.fontSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lineHeight => $composableBuilder(
      column: $table.lineHeight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get wordSpacing => $composableBuilder(
      column: $table.wordSpacing, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get font => $composableBuilder(
      column: $table.font, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isBionic => $composableBuilder(
      column: $table.isBionic, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<double> get fontSize =>
      $composableBuilder(column: $table.fontSize, builder: (column) => column);

  GeneratedColumn<double> get lineHeight => $composableBuilder(
      column: $table.lineHeight, builder: (column) => column);

  GeneratedColumn<double> get wordSpacing => $composableBuilder(
      column: $table.wordSpacing, builder: (column) => column);

  GeneratedColumn<String> get font =>
      $composableBuilder(column: $table.font, builder: (column) => column);

  GeneratedColumn<bool> get isBionic =>
      $composableBuilder(column: $table.isBionic, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
            Value<double> fontSize = const Value.absent(),
            Value<double> lineHeight = const Value.absent(),
            Value<double> wordSpacing = const Value.absent(),
            Value<String> font = const Value.absent(),
            Value<bool> isBionic = const Value.absent(),
          }) =>
              SettingsCompanion(
            id: id,
            accountId: accountId,
            fontSize: fontSize,
            lineHeight: lineHeight,
            wordSpacing: wordSpacing,
            font: font,
            isBionic: isBionic,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
            Value<double> fontSize = const Value.absent(),
            Value<double> lineHeight = const Value.absent(),
            Value<double> wordSpacing = const Value.absent(),
            Value<String> font = const Value.absent(),
            Value<bool> isBionic = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            id: id,
            accountId: accountId,
            fontSize: fontSize,
            lineHeight: lineHeight,
            wordSpacing: wordSpacing,
            font: font,
            isBionic: isBionic,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountTableTableManager get account =>
      $$AccountTableTableManager(_db, _db.account);
  $$CategoryTableTableManager get category =>
      $$CategoryTableTableManager(_db, _db.category);
  $$SubscriptionTableTableManager get subscription =>
      $$SubscriptionTableTableManager(_db, _db.subscription);
  $$ArticleTableTableManager get article =>
      $$ArticleTableTableManager(_db, _db.article);
  $$DelayedTableTableManager get delayed =>
      $$DelayedTableTableManager(_db, _db.delayed);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}

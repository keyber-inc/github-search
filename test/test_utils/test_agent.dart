// Copyright 2022 susatthi All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_search/config/app.dart';
import 'package:github_search/domain/repositories/app_data_repository.dart';
import 'package:github_search/domain/repositories/query_history_repository.dart';
import 'package:github_search/domain/repositories/repo_repository.dart';
import 'package:github_search/infrastructure/github/http_client.dart';
import 'package:github_search/infrastructure/github/repo_repository.dart';
import 'package:github_search/infrastructure/hive/app_data_repository.dart';
import 'package:github_search/infrastructure/objectbox/query_history_repository.dart';
import 'package:github_search/localizations/strings.g.dart';
import 'package:github_search/objectbox.g.dart';
import 'package:github_search/presentation/repo/state/search_repos_query.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
// ignore: depend_on_referenced_packages
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'mocks.dart';

const defaultLocale = 'en';
const locale = String.fromEnvironment('locale', defaultValue: defaultLocale);

/// テストエージェント
class TestAgent {
  TestAgent() {
    // url_launcher のモック化
    UrlLauncherPlatform.instance = mockUrlLauncherPlatform;
  }

  final defaultOverrides = <Override>[
    // リポジトリの実装をDI
    appDataRepositoryProvider
        .overrideWithProvider(hiveAppDataRepositoryProvider),
    repoRepositoryProvider.overrideWithProvider(githubRepoRepositoryProvider),
    queryHistoryRepositoryProvider
        .overrideWithProvider(objectboxQueryHistoryRepositoryProvider),
    // GitHubアクセストークンをダミー文字列にする
    githubAccessTokenProvider.overrideWithValue('dummy'),
    // モック版のHTTPクライアントを使う
    httpClientProvider.overrideWithValue(mockHttpClient),
    // リポジトリ検索文字列の初期値を設定する
    repoSearchReposInitQueryStringProvider.overrideWithValue('flutter'),
  ];

  List<Override>? addOverrides;

  final mockUrlLauncherPlatform = MockUrlLauncherPlatform();

  final mockGoRouter = MockGoRouter();

  final hiveTestAgent = HiveTestAgent();
  final objectboxTestAgent = ObjectboxTestAgent();
  final providerContainerTestAgent = ProviderContainerTestAgent();

  Future<void> setUp({
    List<Override>? overrides,
  }) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // dart-define で与えられた言語情報を設定する
    LocaleSettings.setLocaleRaw(locale);

    // Hive のセットアップ
    await hiveTestAgent.setUp();

    // ObjectBox のセットアップ
    await objectboxTestAgent.setUp();

    // // 一部テストで下記エラーがでる対策
    // // The following MissingPluginException was thrown running a test (but after
    // // the test had completed):MissingPluginException(No implementation found
    // // for method getTemporaryDirectory on channel plugins.flutter.io/path_provider_macos)
    // // see: https://qiita.com/teriyaki398_/items/642be2f0ed1e87d8ae38
    // const MethodChannel('plugins.flutter.io/path_provider_macos')
    //     .setMockMethodCallHandler(
    //   (methodCall) async {
    //     return '.dart_tool/test/tmp';
    //   },
    // );

    addOverrides = overrides;
  }

  /// モック版のProviderContainer を生成する
  ProviderContainer mockContainer({
    List<Override>? overrides,
  }) {
    final container = providerContainerTestAgent.container;
    if (container != null) {
      return container;
    }

    providerContainerTestAgent.setUp(
      overrides: _generateOverrides(overrides),
    );
    return providerContainerTestAgent.container!;
  }

  /// モック版の GitHubSearchApp を生成する
  Widget mockApp({
    List<Override>? overrides,
    Widget? home,
  }) {
    return ProviderScope(
      overrides: _generateOverrides(overrides),
      child: GitHubSearchApp(
        home: home,
      ),
    );
  }

  List<Override> _generateOverrides(
    List<Override>? overrides,
  ) =>
      [
        ...defaultOverrides,
        storeProvider.overrideWithValue(objectboxTestAgent.store),
        ...?addOverrides,
        ...?overrides,
      ];

  Future<void> tearDown() async {
    await hiveTestAgent.tearDown();
    await objectboxTestAgent.tearDown();
    providerContainerTestAgent.tearDown();
  }
}

class ProviderContainerTestAgent {
  ProviderContainer? _container;
  ProviderContainer? get container => _container;

  void setUp({
    List<Override>? overrides,
  }) {
    _container = ProviderContainer(
      overrides: overrides ?? [],
    );
  }

  void tearDown() {
    _container?.dispose();
    _container = null;
  }
}

class TestDirectory {
  /// テストディレクトリ
  Directory? _dir;
  Directory get dir => _dir!;

  /// テストディレクトリを開く
  Future<void> open({
    String? prefix,
  }) async {
    if (_dir != null) {
      return;
    }

    final name = Random().nextInt(pow(2, 32) as int);
    final effectivePrefix = prefix ?? 'tmp';
    final tempPath =
        path.join(Directory.current.path, '.dart_tool', 'test', 'tmp');
    final dir = Directory(path.join(tempPath, '${effectivePrefix}_$name'));

    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
    await dir.create(recursive: true);
    _dir = dir;
  }

  /// テストディレクトリを閉じる
  void close() {
    final dir = _dir;
    if (dir == null) {
      return;
    }

    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
      _dir = null;
    }
  }
}

/// Hive のテストエージェント
class HiveTestAgent {
  final _testDir = TestDirectory();

  /// セットアップする
  Future<void> setUp() async {
    await _testDir.open(prefix: 'hive');
    Hive.init(_testDir.dir.path);
    final box = await Hive.openBox<dynamic>(hiveBoxNameAppData);
    await box.clear();
  }

  /// 終了する
  Future<void> tearDown() async {
    await Hive.deleteFromDisk();
    _testDir.close();
  }
}

/// ObjectBox のテストエージェント
class ObjectboxTestAgent {
  final testDir = TestDirectory();
  Store? _store;
  Store get store => _store!;

  /// セットアップする
  Future<void> setUp() async {
    await testDir.open(prefix: 'objectbox');
    _store = await openStore(
      directory: testDir.dir.path,
    );
  }

  /// 終了する
  Future<void> tearDown() async {
    _store?.close();
    _store = null;
    testDir.close();
  }
}

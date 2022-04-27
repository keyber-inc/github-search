// Copyright 2022 susatthi All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'hive/app_data_repository.dart';
import 'repo_repository.dart';

/// アプリデータRepositoryプロバイダー
final appDataRepositoryProvider = Provider<AppDataRepository>(
  (ref) => ref.watch(hiveAppDataRepositoryProvider),
);

/// アプリデータRepository
abstract class AppDataRepository {
  /// デフォルト値
  static const defaultValues = <AppDataKey, Object?>{
    AppDataKey.searchReposSort: RepoParamSearchReposSort.bestMatch,
    AppDataKey.searchReposOrder: RepoParamSearchReposOrder.desc,
  };

  /// リポジトリ検索用ソートを設定する
  void setSearchReposSort(RepoParamSearchReposSort sort);

  /// リポジトリ検索用ソートを返す
  RepoParamSearchReposSort getSearchReposSort();

  /// リポジトリ検索用オーダーを設定する
  void setSearchReposOrder(RepoParamSearchReposOrder order);

  /// リポジトリ検索用オーダーを設定する
  RepoParamSearchReposOrder getSearchReposOrder();
}

/// データのキー名
enum AppDataKey {
  searchReposSort,
  searchReposOrder,
}

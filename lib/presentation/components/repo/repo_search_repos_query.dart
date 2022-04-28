// Copyright 2022 susatthi All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/constants.dart';
import '../../../config/env.dart';

/// リポジトリ検索文字列初期値プロバイダー
final repoSearchReposInitQueryProvider = Provider<String>(
  (ref) => const String.fromEnvironment(
    dartDefineKeyDefaultSearchValue,
    //ignore: avoid_redundant_argument_values
    defaultValue: Env.defaultSearchValue,
  ),
);

/// リポジトリ検索文字列プロバイダー
final repoSearchReposQueryProvider =
    StateNotifierProvider<RepoSearchReposQueryController, String>(
  (ref) {
    final query = ref.watch(repoSearchReposInitQueryProvider);
    return RepoSearchReposQueryController(query);
  },
);

/// リポジトリ検索文字列コントローラー
class RepoSearchReposQueryController extends StateNotifier<String> {
  RepoSearchReposQueryController(
    String query,
  ) : super(query);

  /// 検索文字列を更新する
  // ignore: avoid_setters_without_getters
  set query(String query) {
    state = query;
  }
}

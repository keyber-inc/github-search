// Copyright 2022 susatthi All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entities/repo/repo.dart';
import '../entities/search_repos_result/search_repos_result.dart';
import 'github/repo_repository.dart';

final repoRepositoryProvider = Provider<RepoRepository>(
  (ref) => ref.watch(githubRepoRepositoryProvider),
);

/// リポジトリRepository
abstract class RepoRepository {
  /// リポジトリを検索する
  Future<SearchReposResult> searchRepos({
    required String query,
    required RepoSearchReposSort sort,
    required RepoSearchReposOrder order,
    int? perPage,
    int? page,
  });

  /// リポジトリを取得する
  Future<Repo> getRepo({
    required String ownerName,
    required String repoName,
  });
}

/// リポジトリ検索用ソート
enum RepoSearchReposSort {
  bestMatch,
  stars,
  forks,
  helpWantedIssues,
}

extension RepoSearchReposSortHelper on RepoSearchReposSort {
  /// 文字列からソートを返す
  /// 見つからない場合は IterableElementError.noElement() を投げる
  static RepoSearchReposSort valueOf(String name) {
    return RepoSearchReposSort.values
        .firstWhere((element) => element.name == name);
  }
}

/// リポジトリ検索用オーダー
enum RepoSearchReposOrder {
  desc,
  asc,
}

extension RepoSearchReposOrderHelper on RepoSearchReposOrder {
  /// 文字列からオーダーを返す
  /// 見つからない場合は IterableElementError.noElement() を投げる
  static RepoSearchReposOrder valueOf(String name) {
    return RepoSearchReposOrder.values
        .firstWhere((element) => element.name == name);
  }
}

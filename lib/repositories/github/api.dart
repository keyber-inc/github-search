// Copyright 2022 susatthi All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import '../repo_repository.dart';

/// GitHub API の定義
/// 各APIはUriを返す
class GitHubApi {
  const GitHubApi();

  static const _scheme = 'https';
  static const _apiUrl = 'api.github.com';
  static const _apiPath = '';

  /// Uriを構築する
  Uri _buildUri({
    required String endpoint,
    Map<String, String> Function()? parametersBuilder,
  }) {
    return Uri(
      scheme: _scheme,
      host: _apiUrl,
      path: '$_apiPath$endpoint',
      queryParameters: parametersBuilder != null ? parametersBuilder() : null,
    );
  }

  /// https://docs.github.com/ja/rest/reference/search#search-repositories
  Uri searchRepos({
    required String query,
    GitHubRepoSearchReposSort? sort,
    GitHubRepoSearchReposOrder? order,
    int? perPage,
    int? page,
  }) {
    assert(query.isNotEmpty);
    assert(perPage == null || (0 < perPage && perPage <= 100));
    assert(page == null || 0 < page);
    return _buildUri(
      endpoint: '/search/repositories',
      parametersBuilder: () {
        return {
          'q': query,
          if (sort != null) 'sort': sort.name,
          if (order != null) 'order': order.name,
          if (perPage != null) 'per_page': '$perPage',
          if (page != null) 'page': '$page',
        };
      },
    );
  }

  /// https://docs.github.com/ja/rest/reference/repos#get-a-repository
  Uri getRepo({
    required String ownerName,
    required String repoName,
  }) {
    assert(ownerName.isNotEmpty);
    assert(repoName.isNotEmpty);
    return _buildUri(
      endpoint: '/repos/$ownerName/$repoName',
    );
  }
}

/// GitHub リポジトリ検索用ソート
enum GitHubRepoSearchReposSort {
  stars,
  forks,
  helpWantedIssues,
}

extension GitHubRepoSearchReposSortHelper on GitHubRepoSearchReposSort {
  static final names = <GitHubRepoSearchReposSort, String>{
    GitHubRepoSearchReposSort.stars: 'stars',
    GitHubRepoSearchReposSort.forks: 'forks',
    GitHubRepoSearchReposSort.helpWantedIssues: 'help-wanted-issues',
  };

  /// override
  String get name => names[this]!;

  /// RepoSearchReposSort => GitHubRepoSearchReposSort
  static GitHubRepoSearchReposSort? valueOf(RepoSearchReposSort sort) {
    switch (sort) {
      case RepoSearchReposSort.bestMatch:
        return null;
      case RepoSearchReposSort.stars:
        return GitHubRepoSearchReposSort.stars;
      case RepoSearchReposSort.forks:
        return GitHubRepoSearchReposSort.forks;
      case RepoSearchReposSort.helpWantedIssues:
        return GitHubRepoSearchReposSort.helpWantedIssues;
    }
  }
}

/// GitHub リポジトリ検索用オーダー
enum GitHubRepoSearchReposOrder {
  desc,
  asc,
}

extension GitHubRepoSearchReposOrderHelper on GitHubRepoSearchReposOrder {
  /// RepoSearchReposOrder => GitHubRepoSearchReposOrder
  static GitHubRepoSearchReposOrder valueOf(
    RepoSearchReposOrder order,
  ) {
    switch (order) {
      case RepoSearchReposOrder.desc:
        return GitHubRepoSearchReposOrder.desc;
      case RepoSearchReposOrder.asc:
        return GitHubRepoSearchReposOrder.asc;
    }
  }
}

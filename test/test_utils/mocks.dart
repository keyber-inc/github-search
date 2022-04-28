// Copyright 2022 susatthi All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_search/config/github_search_app.dart';
import 'package:github_search/presentation/components/repo/repo_search_repos_query.dart';
import 'package:github_search/repositories/github/http_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'logger.dart';
import 'utils.dart';

/// モック版のHTTPクライアント
final mockHttpClient = MockClient(
  (request) async {
    final path = request.url.path;

    // リポジトリ検索
    if (path == '/search/repositories') {
      final query = request.url.queryParameters['q'];
      final page = request.url.queryParameters['page'] ?? 1;
      final sort = request.url.queryParameters['sort'];

      // JSONファイル名を生成する
      final jsonFileNameBuffer = StringBuffer('search_repos_')
        ..write(query)
        ..write('_page$page');
      if (sort != null) {
        jsonFileNameBuffer.write('_$sort');
      }
      jsonFileNameBuffer.write('.json');

      // JSONファイルのパス
      final jsonFilePath = 'github/${jsonFileNameBuffer.toString()}';
      testLogger.i('Required json file at $jsonFilePath');

      // 検索文字列からテスト用のJSONファイルを読み込む
      final jsonString = TestAssets.readString(jsonFilePath);
      if (jsonString != null) {
        return http.Response(
          jsonString,
          200,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
          },
        );
      }
      throw AssertionError('Invalid test request: path=$path');
    }

    // リポジトリ取得
    final reg = RegExp(r'^\/repos\/(.+)\/(.+)');
    if (reg.hasMatch(path)) {
      final ownerName = reg.allMatches(path).map((e) => e.group(1)).first;
      final repoName = reg.allMatches(path).map((e) => e.group(2)).first;

      // ownerName/repoNameからテスト用のJSONファイルを読み込む
      final jsonString = TestAssets.readString(
        'github/get_repo_${ownerName}_$repoName.json',
      );
      if (jsonString != null) {
        return http.Response(
          jsonString,
          200,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
          },
        );
      }
      throw AssertionError('Invalid test request: path=$path');
    }

    // 任意のステータスコードを返す
    final statusCode = int.tryParse(path);
    if (statusCode != null) {
      return http.Response('$statusCode', statusCode);
    }

    // SocketExceptionを発生させる
    if (path == 'socketException') {
      throw const SocketException('');
    }

    throw AssertionError('Invalid test request: path=$path');
  },
);

/// 常にエラーを返すモック版のHTTPクライアント
final mockHttpClientError = MockClient(
  (request) async {
    throw const SocketException('');
  },
);

/// モック版のGitHubSearchAppを返す
Widget mockGitHubSearchApp({
  List<Override>? overrides,
  Widget? home,
}) {
  return ProviderScope(
    overrides: [
      // GitHubアクセストークンをダミー文字列にする
      githubAccessTokenProvider.overrideWithValue('dummy'),
      // モック版のHTTPクライアントを使う
      httpClientProvider.overrideWithValue(mockHttpClient),
      // リポジトリ検索文字列の初期値を設定する
      repoSearchReposInitQueryProvider.overrideWithValue('flutter'),
      ...?overrides,
    ],
    child: GitHubSearchApp(
      home: home,
    ),
  );
}

/// モック版のProviderContainerを返す
ProviderContainer mockProviderContainer({
  List<Override>? overrides,
}) {
  return ProviderContainer(
    overrides: [
      // GitHubアクセストークンをダミー文字列にする
      githubAccessTokenProvider.overrideWithValue('dummy'),
      // モック版のHTTPクライアントを使う
      httpClientProvider.overrideWithValue(mockHttpClient),
      // リポジトリ検索文字列の初期値を設定する
      repoSearchReposInitQueryProvider.overrideWithValue('flutter'),
      ...?overrides,
    ],
  );
}

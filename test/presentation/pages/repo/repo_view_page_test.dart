// Copyright 2022 susatthi All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:github_search/presentation/components/repo/repo_detail_view_controller.dart';
import 'package:github_search/presentation/pages/repo/repo_view_page.dart';

import '../../../test_utils/mocks.dart';

void main() {
  group('RepoViewPage', () {
    testWidgets('画面が表示され必要なWidgetが存在するはず', (tester) async {
      // リポジトリ詳細画面を表示したはず
      await tester.pumpWidget(
        mockGitHubSearchApp(
          overrides: [
            repoDetailViewStateProvider.overrideWithProvider(
              repoDetailViewStateProviderFamily(
                const RepoDetailViewParameter(
                  ownerName: 'flutter',
                  repoName: 'plugins',
                ),
              ),
            ),
          ],
          home: const RepoViewPage(),
        ),
      );
      await tester.pump();

      // オーナー名
      expect(find.text('flutter'), findsOneWidget);

      // リポジトリ名
      expect(find.text('plugins'), findsOneWidget);

      // プロジェクト言語
      expect(find.text('Dart'), findsOneWidget);
    });
  });
}

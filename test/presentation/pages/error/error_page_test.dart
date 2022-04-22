// Copyright 2022 susatthi All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_search/config/github_search_app.dart';
import 'package:github_search/localizations/strings.g.dart';
import 'package:github_search/presentation/pages/error/error_page.dart';

void main() {
  testWidgets('errorがnullでも問題ないはず', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GitHubSearchApp(
          home: ErrorPage(),
        ),
      ),
    );
    expect(find.text(i18n.errorOccurred), findsOneWidget);
  });
  testWidgets('errorがある場合でも問題ないはず', (tester) async {
    final error = Exception('dummy');
    await tester.pumpWidget(
      ProviderScope(
        child: GitHubSearchApp(
          home: ErrorPage(
            error: error,
          ),
        ),
      ),
    );
    expect(find.text(error.toString()), findsOneWidget);
  });
}

// Copyright 2022 susatthi All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../utils/logger.dart';
import '../../pages/repo/repo_view_page.dart';
import '../common/async_value_handler.dart';
import 'repo_list_view_controller.dart';
import 'repo_list_view_state.dart';

/// リポジトリ一覧View
class RepoListView extends ConsumerWidget {
  const RepoListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(repoListViewStateProvider);
    return AsyncValueHandler<RepoListViewState>(
      value: asyncValue,
      builder: (state) => _RepoListView(state: state),
    );
  }
}

class _RepoListView extends StatelessWidget {
  const _RepoListView({
    Key? key,
    required this.state,
  }) : super(key: key);

  final RepoListViewState state;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: state.items.length + (state.hasNext ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < state.items.length) {
          final repo = state.items[index];
          return ListTile(
            title: Text(repo.fullName),
            onTap: () {
              // リポジトリ詳細画面に遷移する
              context.goNamed(
                RepoViewPage.name,
                params: RepoViewPage.params(
                  ownerName: repo.owner.name,
                  repoName: repo.name,
                ),
              );
            },
          );
        }
        return const _CircularProgressListTile();
      },
    );
  }
}

/// リストビューを一番下までスクロールしたときに表示するプログレス
class _CircularProgressListTile extends ConsumerWidget {
  const _CircularProgressListTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(repoListViewStateProvider.notifier);
    return VisibilityDetector(
      key: const Key('for detect visibility'),
      child: Column(
        children: const [
          Padding(
            padding: EdgeInsets.all(10),
            child: CircularProgressIndicator(),
          ),
        ],
      ),
      onVisibilityChanged: (info) async {
        if (info.visibleFraction > 0.1) {
          logger.i('appeared progress: info=$info');
          // 表示されたので次のページを取得する
          await controller.fetchNextPage();
        }
      },
    );
  }
}

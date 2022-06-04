// Copyright 2022 susatthi All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/app.dart';
import 'domain/repositories/app_data_repository.dart';
import 'domain/repositories/query_history_repository.dart';
import 'domain/repositories/repo_repository.dart';
import 'infrastructure/github/repo_repository.dart';
import 'infrastructure/hive/app_data_repository.dart';
import 'infrastructure/objectbox/query_history_repository.dart';
import 'localizations/strings.g.dart';
import 'objectbox.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // fast_i18n の初期化
  LocaleSettings.useDeviceLocale();

  // hive の初期化
  await Hive.initFlutter();
  await Hive.openBox<dynamic>(hiveBoxNameAppData);

  // objectbox の初期化
  final store = await openStore();

  runApp(
    ProviderScope(
      overrides: [
        // DataSources
        storeProvider.overrideWithValue(store),
        // Repositories
        appDataRepositoryProvider
            .overrideWithProvider(hiveAppDataRepositoryProvider),
        repoRepositoryProvider
            .overrideWithProvider(githubRepoRepositoryProvider),
        queryHistoryRepositoryProvider
            .overrideWithProvider(objectboxQueryHistoryRepositoryProvider),
      ],
      child: const GitHubSearchApp(),
    ),
  );
}

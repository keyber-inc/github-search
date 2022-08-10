#!/bin/bash

# Copyright 2022 susatthi All rights reserved.
# Use of this source code is governed by a MIT license that can be
# found in the LICENSE file.

# カバレッジから不要な結果を削除する
lcov --remove coverage/lcov.info 'lib/utils/assets/*' 'lib/localizations/*' 'lib/infrastructure/isar/**/collections/*' 'lib/**/*.g.dart' 'lib/domain/repositories/**/entities/*.dart' -o coverage/lcov.info

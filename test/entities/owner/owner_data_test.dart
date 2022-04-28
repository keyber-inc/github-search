// Copyright 2022 susatthi All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:github_search/entities/owner/owner.dart';
import 'package:github_search/entities/owner/owner_data.dart';

import '../../test_utils/utils.dart';

void main() {
  final ownerJsonObject = TestAssets.readJsonMap('github/owner.json')!;
  group('OwnerData', () {
    test('from()でインスタンスを作成できるはず', () async {
      final owner = Owner.fromJson(ownerJsonObject);
      final ownerData = OwnerData.from(owner);
      expect(ownerData, isNotNull);
    });
  });
}

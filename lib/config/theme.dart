// Copyright 2022 susatthi All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/assets/fonts.gen.dart';

/// テーマプロバイダー
final themeProvider = Provider.family<ThemeData, Brightness>(
  (ref, brightness) => ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      brightness: brightness,
      primarySwatch: Colors.grey,
    ),
    fontFamily: FontFamily.murecho,
  ),
);

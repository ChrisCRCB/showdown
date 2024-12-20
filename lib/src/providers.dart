import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'json/app_preferences.dart';

part 'providers.g.dart';

/// Provide the shared preferences instances.
@riverpod
Future<SharedPreferences> sharedPreferences(final Ref ref) =>
    SharedPreferences.getInstance();

/// Provide the app preferences.
@riverpod
Future<AppPreferences> appPreferences(final Ref ref) async {
  final sharedPreferences = await ref.watch(sharedPreferencesProvider.future);
  final source = sharedPreferences.getString(preferencesKey);
  if (source == null) {
    return AppPreferences();
  }
  final json = jsonDecode(source);
  return AppPreferences.fromJson(json);
}

/// Provide the font size.
@riverpod
Future<double> fontSize(final Ref ref) async {
  final appPreferences = await ref.watch(appPreferencesProvider.future);
  return appPreferences.fontSize.toDouble();
}

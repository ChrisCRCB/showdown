import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';

import '../constants.dart';
import '../providers.dart';

part 'app_preferences.g.dart';

/// The preferences for the app.
@JsonSerializable()
class AppPreferences {
  /// Create an instance.
  AppPreferences({
    this.fontSize = 20,
  });

  /// Create an instance from a JSON object.
  factory AppPreferences.fromJson(final Map<String, dynamic> json) =>
      _$AppPreferencesFromJson(json);

  /// The font size to use.
  int fontSize;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$AppPreferencesToJson(this);

  /// Save the app preferences.
  Future<void> safe(final WidgetRef ref) async {
    final sharedPreferences = await ref.read(sharedPreferencesProvider.future);
    final data = jsonEncode(toJson());
    await sharedPreferences.setString(preferencesKey, data);
    ref.invalidate(appPreferencesProvider);
  }
}

import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// Text with a custom font size.
class CustomText extends ConsumerWidget {
  /// Create an instance.
  const CustomText(
    this.data, {
    super.key,
  });

  /// The text to show.
  final String data;

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final value = ref.watch(appPreferencesProvider);
    return value.when(
      data: (final appPreferences) => Text(
        data,
        style: TextStyle(fontSize: appPreferences.fontSize.toDouble()),
      ),
      error: (final error, final stackTrace) => Text('$error, $stackTrace'),
      loading: LoadingWidget.new,
    );
  }
}

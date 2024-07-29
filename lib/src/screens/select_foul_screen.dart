import 'package:backstreets_widgets/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recase/recase.dart';

import '../json/game_event_type.dart';
import '../widgets/custom_text.dart';

/// A screen to select a foul.
class SelectFoulScreen extends ConsumerWidget {
  /// Create an instance.
  const SelectFoulScreen({
    required this.onDone,
    super.key,
  });

  /// The function to call when a foul has been selected.
  final ValueChanged<GameEventType> onDone;

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final fouls = GameEventType.values
        .where((final type) => type != GameEventType.goal)
        .toList()
      ..sort(
        (final a, final b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    return SimpleScaffold(
      title: 'Select Foul',
      body: ListView.builder(
        itemBuilder: (final context, final index) {
          final foul = fouls[index];
          final foulName = foul.name.titleCase;
          return FocusableActionDetector(
            actions: {
              ActivateIntent: CallbackAction(
                onInvoke: (final intent) => activateFoul(context, foul),
              ),
            },
            child: GestureDetector(
              onTap: () => activateFoul(context, foul),
              child: Card(
                child: CustomText(foulName),
              ),
            ),
          );
        },
        itemCount: fouls.length,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
      ),
    );
  }

  /// Activate the given [foul].
  void activateFoul(final BuildContext context, final GameEventType foul) {
    Navigator.pop(context);
    onDone(foul);
  }
}

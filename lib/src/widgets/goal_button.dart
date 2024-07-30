import 'package:flutter/material.dart';

import '../json/game_event_type.dart';

/// A button to add a goal.
class GoalButton extends StatelessWidget {
  /// Create an instance.
  const GoalButton({
    required this.addEvent,
    super.key,
  });

  /// The function to call to add an event.
  final void Function(GameEventType eventType) addEvent;

  /// Build the widget.

  @override
  Widget build(final BuildContext context) => ElevatedButton(
        onPressed: () => addEvent(
          GameEventType.goal,
        ),
        child: const Icon(
          Icons.sports_soccer,
          semanticLabel: 'Goal',
        ),
      );
}

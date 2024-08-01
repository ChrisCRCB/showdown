import 'package:backstreets_widgets/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:recase/recase.dart';

import '../json/game_event_type.dart';
import '../screens/select_foul_screen.dart';

/// A button to add a foul.
class FoulButton extends StatelessWidget {
  /// Create an instance.
  const FoulButton({
    required this.playerName,
    required this.addEvent,
    super.key,
  });

  /// The name of the player in question.
  final String playerName;

  /// The function to call to add an event.
  final void Function(GameEventType eventType) addEvent;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final fouls = GameEventType.values
        .where((final type) => type != GameEventType.goal)
        .toList()
      ..sort(
        (final a, final b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    return Semantics(
      customSemanticsActions: {
        for (final foul in fouls)
          CustomSemanticsAction(label: foul.name.titleCase): () =>
              addEvent(foul),
      },
      child: ElevatedButton(
        onPressed: () => context.pushWidgetBuilder(
          (final context) => SelectFoulScreen(
            onDone: addEvent,
          ),
        ),
        child: Icon(
          Icons.warning,
          semanticLabel: '$playerName Foul',
        ),
      ),
    );
  }
}

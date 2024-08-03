import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../json/game_event.dart';
import 'custom_text.dart';
import 'game_event_text.dart';

/// A list tile to show a game [event].
class GameEventListTile extends StatelessWidget {
  /// Create an instance.
  const GameEventListTile({
    required this.event,
    required this.deleteEvent,
    this.playerName,
    super.key,
  });

  /// The event to show.
  final GameEvent event;

  /// The function to call to delete [event].
  final void Function(GameEvent event) deleteEvent;

  /// The player name to show.
  ///
  /// If [playerName] is `null`, the [ListTile] will use [event] to create its
  /// `title`.
  final String? playerName;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final name = playerName;
    return CommonShortcuts(
      deleteCallback: () => deleteEvent(event),
      child: ListTile(
        title: name == null ? GameEventText(event: event) : CustomText(name),
        subtitle: name == null ? null : GameEventText(event: event),
        onTap: () => deleteEvent(event),
      ),
    );
  }
}

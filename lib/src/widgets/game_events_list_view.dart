import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../json/game_event.dart';
import '../table_end.dart';
import 'game_event_list_tile.dart';

/// A [ListView] which shows game [events].
class GameEventsListView extends StatelessWidget {
  /// Create an instance.
  const GameEventsListView({
    required this.events,
    required this.leftPlayerName,
    required this.rightPlayerName,
    required this.deleteEvent,
    super.key,
  });

  /// The events to show.
  final List<GameEvent> events;

  /// The name of the left player.
  final String leftPlayerName;

  /// The name of the right player.
  final String rightPlayerName;

  /// The function to call to delete an event.
  final void Function(GameEvent event) deleteEvent;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    if (events.isEmpty) {
      return const CenterText(text: 'There are no game events to show yet.');
    }
    return ListView.builder(
      itemBuilder: (final context, final index) {
        final event = events[index];
        final playerName = switch (event.tableEnd) {
          TableEnd.left => leftPlayerName,
          TableEnd.right => rightPlayerName,
        };
        return GameEventListTile(
          event: event,
          deleteEvent: deleteEvent,
          playerName: playerName,
        );
      },
      itemCount: events.length,
      shrinkWrap: true,
    );
  }
}

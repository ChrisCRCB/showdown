import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:recase/recase.dart';

import '../json/game_event.dart';
import '../json/game_event_type.dart';
import '../table_end.dart';
import 'custom_text.dart';
import 'foul_button.dart';
import 'goal_button.dart';
import 'rename_player.dart';

/// The panel to show stats for [name].
class PlayerPanel extends StatelessWidget {
  /// Create an instance.
  const PlayerPanel({
    required this.name,
    required this.tableEnd,
    required this.events,
    required this.onChanged,
    required this.addEvent,
    required this.deleteEvent,
    super.key,
  });

  /// The name of the player.
  final String name;

  /// Which end of the table this player is  at.
  final TableEnd tableEnd;

  /// The events which this player has generated.
  final List<GameEvent> events;

  /// The function to call when the player changes.
  final void Function(String name) onChanged;

  /// The function to call to add a new event.
  final void Function(GameEventType eventType) addEvent;

  /// The function to call to delete an event.
  final void Function(GameEvent event) deleteEvent;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final buttons = [
      GoalButton(playerName: name, addEvent: addEvent),
      FoulButton(playerName: name, addEvent: addEvent),
    ];
    return Column(
      crossAxisAlignment: switch (tableEnd) {
        TableEnd.left => CrossAxisAlignment.start,
        TableEnd.right => CrossAxisAlignment.end,
      },
      children: [
        Expanded(
          flex: 5,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: CustomText(name),
                onTap: () => context.pushWidgetBuilder(
                  (final builderContext) =>
                      RenamePlayer(onChanged: onChanged, name: name),
                ),
              ),
              ...events.reversed.map(
                (final event) => CommonShortcuts(
                  deleteCallback: () => deleteEvent(event),
                  child: ListTile(
                    title: CustomText(event.type.name.titleCase),
                    onTap: () => deleteEvent(event),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: switch (tableEnd) {
              TableEnd.left => MainAxisAlignment.start,
              TableEnd.right => MainAxisAlignment.end,
            },
            children: switch (tableEnd) {
              TableEnd.left => buttons,
              TableEnd.right => buttons.reversed.toList(),
            },
          ),
        ),
      ],
    );
  }
}

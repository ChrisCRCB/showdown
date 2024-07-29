import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/util.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:recase/recase.dart';

import '../json/game_event.dart';
import '../json/game_event_type.dart';
import '../screens/select_foul_screen.dart';
import '../table_end.dart';
import 'custom_text.dart';

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
    final fouls = GameEventType.values
        .where((final type) => type != GameEventType.goal)
        .toList()
      ..sort(
        (final a, final b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    final buttons = [
      ElevatedButton(
        onPressed: () => addEvent(
          GameEventType.goal,
        ),
        child: const Icon(
          Icons.sports_soccer,
          semanticLabel: 'Goal',
        ),
      ),
      Semantics(
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
          child: const Icon(
            Icons.warning,
            semanticLabel: 'Foul',
          ),
        ),
      ),
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
                  (final builderContext) => GetText(
                    onDone: (final value) {
                      Navigator.pop(builderContext);
                      onChanged(value);
                    },
                    labelText: 'Player name',
                    text: name,
                    title: 'Rename Player',
                    validator: FormBuilderValidators.required(),
                  ),
                ),
              ),
              ...events.reversed.map(
                (final event) => CommonShortcuts(
                  deleteCallback: () => doDeleteEvent(context, event),
                  child: ListTile(
                    title: CustomText(event.type.name.titleCase),
                    onTap: () {},
                    onLongPress: () => doDeleteEvent(context, event),
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

  /// Perform event deletion.
  Future<void> doDeleteEvent(
    final BuildContext context,
    final GameEvent event,
  ) =>
      confirm(
        context: context,
        message: 'Really delete this event?',
        title: 'Delete Event',
        yesCallback: () async {
          Navigator.pop(context);
          deleteEvent(event);
        },
      );
}

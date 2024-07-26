import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:recase/recase.dart';

import '../json/game_event.dart';
import '../providers.dart';
import '../table_end.dart';

/// The panel to show stats for [name].
class PlayerPanel extends ConsumerWidget {
  /// Create an instance.
  const PlayerPanel({
    required this.name,
    required this.tableEnd,
    required this.onChanged,
    required this.events,
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

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final value = ref.watch(appPreferencesProvider);
    return value.when(
      data: (final appPreferences) {
        final fontSize = appPreferences.fontSize.toDouble();
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(
                name,
                style: TextStyle(
                  fontSize: fontSize,
                ),
              ),
              onTap: () => context.pushWidgetBuilder(
                (final builderContext) => GetText(
                  onDone: (final value) {
                    Navigator.pop(builderContext);
                    onChanged(name);
                  },
                  labelText: 'Player name',
                  text: name,
                  title: 'Rename Player',
                  validator: FormBuilderValidators.required(),
                ),
              ),
            ),
            ...events.reversed.map(
              (final event) => ListTile(
                title: Text(
                  event.type.name.titleCase,
                  style: TextStyle(fontSize: fontSize),
                ),
                onTap: () {},
              ),
            ),
          ],
        );
      },
      error: ErrorListView.withPositional,
      loading: LoadingWidget.new,
    );
  }
}

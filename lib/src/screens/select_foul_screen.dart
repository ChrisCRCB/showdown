import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recase/recase.dart';

import '../json/game_event_type.dart';
import '../widgets/custom_text.dart';

/// A screen to select a foul.
class SelectFoulScreen extends ConsumerWidget {
  /// Create an instance.
  const SelectFoulScreen({
    required this.fouls,
    required this.onDone,
    super.key,
  });

  /// The fouls to show.
  final List<GameEventType> fouls;

  /// The function to call when a foul has been selected.
  final ValueChanged<GameEventType> onDone;

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) => Cancel(
        child: SimpleScaffold(
          title: 'Select Foul',
          body: OrientationBuilder(
            builder: (final context, final orientation) => ListView.builder(
              itemBuilder: (final context, final index) {
                final foul = fouls[index];
                final foulName = foul.name.titleCase;
                switch (orientation) {
                  case Orientation.portrait:
                    return ListTile(
                      autofocus: index == 0,
                      title: CustomText(foulName),
                      onTap: () => activateFoul(context, foul),
                    );
                  case Orientation.landscape:
                    return GestureDetector(
                      onTap: () => activateFoul(context, foul),
                      child: FocusableActionDetector(
                        autofocus: index == 0,
                        actions: {
                          ActivateIntent: CallbackAction(
                            onInvoke: (final intent) => activateFoul(
                              context,
                              foul,
                            ),
                          ),
                        },
                        child: Semantics(
                          label: foulName,
                          child: Card(
                            child: CustomText(foulName),
                          ),
                        ),
                      ),
                    );
                }
              },
              itemCount: fouls.length,
              scrollDirection: switch (orientation) {
                Orientation.portrait => Axis.vertical,
                Orientation.landscape => Axis.horizontal,
              },
              shrinkWrap: true,
            ),
          ),
        ),
      );

  /// Activate the given [foul].
  void activateFoul(final BuildContext context, final GameEventType foul) {
    Navigator.pop(context);
    onDone(foul);
  }
}

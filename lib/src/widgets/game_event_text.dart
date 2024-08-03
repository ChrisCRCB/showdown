import 'package:flutter/material.dart';
import 'package:recase/recase.dart';

import '../json/game_event.dart';
import 'custom_text.dart';

/// A [CustomText] widget which shows a game [event].
class GameEventText extends StatelessWidget {
  /// Create an instance.
  const GameEventText({
    required this.event,
    super.key,
  });

  /// The event to show.
  final GameEvent event;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) =>
      CustomText(event.type.name.titleCase);
}

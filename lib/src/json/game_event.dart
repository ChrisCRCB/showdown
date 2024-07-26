import 'package:json_annotation/json_annotation.dart';

import '../table_end.dart';
import 'game_event_type.dart';

part 'game_event.g.dart';

/// An event in a game.
@JsonSerializable()
class GameEvent {
  /// Create an instance.
  const GameEvent({
    required this.id,
    required this.time,
    required this.tableEnd,
    required this.type,
  });

  /// Create an instance from a JSON object.
  factory GameEvent.fromJson(final Map<String, dynamic> json) =>
      _$GameEventFromJson(json);

  /// The ID of this game.
  final String id;

  /// The time at which this event happened.
  final DateTime time;

  /// The end at which this event occurred.
  ///
  /// For fouls, this is the player who performed the foul, rather than the
  /// player who benefits from the points.
  final TableEnd tableEnd;

  /// The type of the event.
  final GameEventType type;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$GameEventToJson(this);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameEvent _$GameEventFromJson(Map<String, dynamic> json) => GameEvent(
      id: json['id'] as String,
      time: DateTime.parse(json['time'] as String),
      tableEnd: $enumDecode(_$TableEndEnumMap, json['tableEnd']),
      type: $enumDecode(_$GameEventTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$GameEventToJson(GameEvent instance) => <String, dynamic>{
      'id': instance.id,
      'time': instance.time.toIso8601String(),
      'tableEnd': _$TableEndEnumMap[instance.tableEnd]!,
      'type': _$GameEventTypeEnumMap[instance.type]!,
    };

const _$TableEndEnumMap = {
  TableEnd.left: 'left',
  TableEnd.right: 'right',
};

const _$GameEventTypeEnumMap = {
  GameEventType.goal: 'goal',
  GameEventType.shortServe: 'shortServe',
  GameEventType.longServe: 'longServe',
  GameEventType.handFoul: 'handFoul',
  GameEventType.bodyTouch: 'bodyTouch',
  GameEventType.out: 'out',
  GameEventType.screenInfraction: 'screenInfraction',
  GameEventType.serviceFault: 'serviceFault',
  GameEventType.illegalDefence: 'illegalDefence',
};

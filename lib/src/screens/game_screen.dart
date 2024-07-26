import 'dart:math';

import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../json/game_event.dart';
import '../json/game_event_type.dart';
import '../providers.dart';
import '../serve_number.dart';
import '../table_end.dart';
import '../widgets/custom_text.dart';
import '../widgets/player_panel.dart';

/// The main game screen.
class GameScreen extends ConsumerStatefulWidget {
  /// Create an instance.
  const GameScreen({
    this.playerPanelFlex = 4,
    this.middleFlex = 2,
    super.key,
  });

  /// The flex factor for the player panels.
  final int playerPanelFlex;

  /// The flex factor for the middle panel.
  final int middleFlex;

  /// Create state for this widget.
  @override
  GameScreenState createState() => GameScreenState();
}

/// State for [GameScreen].
class GameScreenState extends ConsumerState<GameScreen> {
  /// Which player is serving.
  late TableEnd servingPlayer;

  /// Whether or not it is the player's first serve..
  late ServeNumber serveNumber;

  /// The events which have happened in the game.
  late final List<GameEvent> events;

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    servingPlayer = TableEnd.left;
    serveNumber = ServeNumber.first;
    events = [];
  }

  /// Dispose of the widget.
  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final leftPlayerName = ref.watch(leftPlayerNameProvider);
    final rightPlayerName = ref.watch(rightPlayerNameProvider);
    print('Left player: $leftPlayerName');
    print('Right player: $rightPlayerName');
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    final servingPlayerName = switch (servingPlayer) {
      TableEnd.left => leftPlayerName,
      TableEnd.right => rightPlayerName,
    };
    final serveNumberString = serveNumber.name;
    final leftScore = getScore(TableEnd.left);
    final rightScore = getScore(TableEnd.right);
    final scores = switch (servingPlayer) {
      TableEnd.left => '$leftScore : $rightScore',
      TableEnd.right => '$rightScore : $leftScore',
    };
    return SimpleScaffold(
      leading: ElevatedButton(
        onPressed: () => confirm(
          context: context,
          message: 'Are you sure you want to start a new game?',
          title: 'Clear Game',
          yesCallback: () async {
            Navigator.pop(context);
            serveNumber = ServeNumber.first;
            servingPlayer = TableEnd.left;
            events.clear();
            setState(() {});
          },
        ),
        child: const Icon(
          Icons.replay,
          semanticLabel: 'Start new game',
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => alterFontSize(-2),
          icon: const Icon(
            Icons.text_decrease,
            semanticLabel: 'Decrease font size',
          ),
        ),
        IconButton(
          onPressed: () => alterFontSize(2),
          icon: const Icon(
            Icons.text_increase,
            semanticLabel: 'Increase font size',
          ),
        ),
      ],
      title: 'Showdown',
      body: Row(
        children: [
          Expanded(
            flex: widget.playerPanelFlex,
            child: PlayerPanel(
              name: leftPlayerName,
              key: ValueKey('${TableEnd.left} $leftPlayerName'),
              tableEnd: TableEnd.left,
              onChanged: (final name) => setState(() {
                ref.read(leftPlayerNameProvider.notifier).state = name;
              }),
              events: events,
              addEvent: addEvent,
              deleteEvent: deleteEvent,
            ),
          ),
          Expanded(
            flex: widget.middleFlex,
            child: ListView(
              shrinkWrap: true,
              key: ValueKey('$leftPlayerName $rightPlayerName'),
              children: [
                CustomText(
                  "$servingPlayerName's $serveNumberString serve ($scores)",
                ),
                CustomText('$leftPlayerName: $leftScore'),
                CustomText('$rightPlayerName: $rightScore'),
                ElevatedButton(
                  onPressed: switchEnds,
                  child: const Icon(
                    Icons.swap_calls,
                    semanticLabel: 'Switch ends',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: widget.playerPanelFlex,
            child: PlayerPanel(
              name: rightPlayerName,
              key: ValueKey('${TableEnd.right} $rightPlayerName'),
              tableEnd: TableEnd.right,
              onChanged: (final name) => setState(() {
                ref.read(rightPlayerNameProvider.notifier).state = name;
              }),
              events: getEvents(TableEnd.right),
              addEvent: addEvent,
              deleteEvent: deleteEvent,
            ),
          ),
        ],
      ),
    );
  }

  /// Switch which end of the table is serving.
  void switchEnds() {
    serveNumber = ServeNumber.first;
    setState(() {
      servingPlayer = switch (servingPlayer) {
        TableEnd.left => TableEnd.right,
        TableEnd.right => TableEnd.left
      };
    });
  }

  /// Add a new [event].
  void addEvent(final GameEvent event) {
    if (event.type == GameEventType.goal) {
      switch (serveNumber) {
        case ServeNumber.first:
          serveNumber = ServeNumber.second;
        case ServeNumber.second:
          switchEnds();
      }
    }
    events.add(event);
    setState(() {});
  }

  /// Delete [event].
  void deleteEvent(final GameEvent event) {
    events.removeWhere(
      (final oldEvent) => oldEvent.id == event.id,
    );
    setState(() {});
  }

  /// Alter the font size.
  Future<void> alterFontSize(final int amount) async {
    final appPreferences = await ref.read(appPreferencesProvider.future);
    appPreferences.fontSize = max(8, appPreferences.fontSize + amount);
    await appPreferences.safe(ref);
  }

  /// Get events for [end].
  List<GameEvent> getEvents(final TableEnd end) =>
      events.where((final event) => event.tableEnd == end).toList();

  /// Get the score for [end].
  int getScore(final TableEnd end) {
    var score = 0;
    for (final event in events) {
      if (event.type == GameEventType.goal) {
        if (event.tableEnd == end) {
          score += 2;
        }
      } else if (event.tableEnd != end) {
        score++;
      }
    }
    return score;
  }
}

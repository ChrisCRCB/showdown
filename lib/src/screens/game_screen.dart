import 'dart:math';

import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../constants.dart';
import '../json/game_event.dart';
import '../json/game_event_type.dart';
import '../providers.dart';
import '../serve_number.dart';
import '../table_end.dart';
import '../widgets/custom_text.dart';
import '../widgets/foul_button.dart';
import '../widgets/game_events_list_view.dart';
import '../widgets/goal_button.dart';
import '../widgets/player_panel.dart';
import '../widgets/rename_player.dart';
import '../widgets/score_panel.dart';
import 'select_foul_screen.dart';

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
  /// How often each foul has been used.
  late final Map<GameEventType, int> foulNumbers;

  /// The possible fouls.
  late final List<GameEventType> fouls;

  /// The name of the left player.
  late String leftPlayerName;

  /// The name of the right player.
  late String rightPlayerName;

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
    foulNumbers = {};
    fouls = GameEventType.values
        .where((final fouls) => fouls != GameEventType.goal)
        .toList();
    leftPlayerName = 'Left Player';
    rightPlayerName = 'Right Player';
    servingPlayer = TableEnd.left;
    serveNumber = ServeNumber.first;
    events = [];
  }

  /// Dispose of the widget.
  @override
  void dispose() {
    super.dispose();
    WakelockPlus.disable();
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    fouls.sort(
      (final a, final b) {
        final aNumber = foulNumbers[a] ?? 0;
        final bNumber = foulNumbers[b] ?? 0;
        if (aNumber == bNumber) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        }
        return aNumber.compareTo(bNumber);
      },
    );
    final leftScore = getScore(TableEnd.left);
    final rightScore = getScore(TableEnd.right);
    final shortcuts = <GameShortcut>[
      GameShortcut.withControlKey(
        title: 'Start new game',
        shortcut: GameShortcutsShortcut.keyN,
        onStart: newGame,
      ),
      GameShortcut.withControlKey(
        title: 'Left player goal',
        shortcut: GameShortcutsShortcut.keyG,
        onStart: (final innerContext) => addEvent(
          TableEnd.left,
          GameEventType.goal,
        ),
      ),
      GameShortcut.withControlKey(
        title: 'Left player foul',
        shortcut: GameShortcutsShortcut.keyF,
        onStart: (final innerContext) => innerContext.pushWidgetBuilder(
          (final innerContext) => SelectFoulScreen(
            fouls: fouls,
            onDone: (final value) => addEvent(TableEnd.left, value),
          ),
        ),
      ),
      GameShortcut.withControlKey(
        title: 'Right player foul',
        shortcut: GameShortcutsShortcut.keyJ,
        onStart: (final innerContext) => innerContext.pushWidgetBuilder(
          (final innerContext) => SelectFoulScreen(
            fouls: fouls,
            onDone: (final value) => addEvent(TableEnd.right, value),
          ),
        ),
      ),
      GameShortcut.withControlKey(
        title: 'Right player goal',
        shortcut: GameShortcutsShortcut.keyH,
        onStart: (final innerContext) => addEvent(
          TableEnd.right,
          GameEventType.goal,
        ),
      ),
      GameShortcut.withControlKey(
        title: 'Switch ends',
        shortcut: GameShortcutsShortcut.keyB,
        onStart: (final innerContext) => switchEnds(),
      ),
    ];
    shortcuts.add(
      GameShortcut.withControlKey(
        title: 'Show help',
        shortcut: GameShortcutsShortcut.slash,
        onStart: (final innerContext) => innerContext.pushWidgetBuilder(
          (final context) => GameShortcutsHelpScreen(shortcuts: shortcuts),
        ),
      ),
    );
    return GameShortcuts(
      shortcuts: shortcuts,
      canRequestFocus: false,
      child: SimpleScaffold(
        leading: ElevatedButton(
          onPressed: () {
            WakelockPlus.enable();
            newGame(context);
          },
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
        body: OrientationBuilder(
          builder: (final context, final orientation) {
            switch (orientation) {
              case Orientation.portrait:
                return Column(
                  children: [
                    Expanded(
                      flex: 5,
                      child: FocusTraversalGroup(
                        child: GameEventsListView(
                          events: events,
                          leftPlayerName: leftPlayerName,
                          rightPlayerName: rightPlayerName,
                          deleteEvent: deleteEvent,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          FocusTraversalGroup(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton(
                                  onPressed: () => context.pushWidgetBuilder(
                                    (final context) => RenamePlayer(
                                      name: leftPlayerName,
                                      onChanged: (final name) => setState(
                                        () => leftPlayerName = name,
                                      ),
                                    ),
                                  ),
                                  child: CustomText(leftPlayerName),
                                ),
                                FoulButton(
                                  fouls: fouls,
                                  playerName: leftPlayerName,
                                  addEvent: (final eventType) => addEvent(
                                    TableEnd.left,
                                    eventType,
                                  ),
                                ),
                                GoalButton(
                                  playerName: leftPlayerName,
                                  addEvent: (final eventType) => addEvent(
                                    TableEnd.left,
                                    eventType,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: FocusTraversalGroup(
                              child: ScorePanel(
                                leftPlayerName: leftPlayerName,
                                leftPlayerScore: leftScore,
                                rightPlayerName: rightPlayerName,
                                rightPlayerScore: rightScore,
                                serveNumber: serveNumber,
                                tableEnd: servingPlayer,
                                switchEnds: switchEnds,
                              ),
                            ),
                          ),
                          FocusTraversalGroup(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => context.pushWidgetBuilder(
                                    (final context) => RenamePlayer(
                                      name: rightPlayerName,
                                      onChanged: (final name) => setState(
                                        () => rightPlayerName = name,
                                      ),
                                    ),
                                  ),
                                  child: CustomText(rightPlayerName),
                                ),
                                FoulButton(
                                  fouls: fouls,
                                  playerName: rightPlayerName,
                                  addEvent: (final eventType) => addEvent(
                                    TableEnd.right,
                                    eventType,
                                  ),
                                ),
                                GoalButton(
                                  playerName: rightPlayerName,
                                  addEvent: (final eventType) => addEvent(
                                    TableEnd.right,
                                    eventType,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              case Orientation.landscape:
                return Row(
                  children: [
                    Expanded(
                      flex: widget.playerPanelFlex,
                      child: FocusTraversalGroup(
                        child: PlayerPanel(
                          fouls: fouls,
                          name: leftPlayerName,
                          key: ValueKey('${TableEnd.left} $leftPlayerName'),
                          tableEnd: TableEnd.left,
                          onChanged: (final name) => setState(() {
                            leftPlayerName = name;
                          }),
                          events: getEvents(TableEnd.left),
                          addEvent: (final eventType) => addEvent(
                            TableEnd.left,
                            eventType,
                          ),
                          deleteEvent: deleteEvent,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: widget.middleFlex,
                      child: FocusTraversalGroup(
                        child: ScorePanel(
                          leftPlayerName: leftPlayerName,
                          leftPlayerScore: leftScore,
                          rightPlayerName: rightPlayerName,
                          rightPlayerScore: rightScore,
                          serveNumber: serveNumber,
                          tableEnd: servingPlayer,
                          switchEnds: switchEnds,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: widget.playerPanelFlex,
                      child: FocusTraversalGroup(
                        child: PlayerPanel(
                          fouls: fouls,
                          name: rightPlayerName,
                          key: ValueKey('${TableEnd.right} $rightPlayerName'),
                          tableEnd: TableEnd.right,
                          onChanged: (final name) => setState(() {
                            rightPlayerName = name;
                          }),
                          events: getEvents(TableEnd.right),
                          addEvent: (final eventType) => addEvent(
                            TableEnd.right,
                            eventType,
                          ),
                          deleteEvent: deleteEvent,
                        ),
                      ),
                    ),
                  ],
                );
            }
          },
        ),
      ),
    );
  }

  /// Start a new game.
  Future<void> newGame(final BuildContext context) => context.confirm(
        message: 'Are you sure you want to start a new game?',
        title: 'Clear Game',
        yesCallback: () async {
          Navigator.pop(context);
          serveNumber = ServeNumber.first;
          servingPlayer = TableEnd.left;
          events.clear();
          setState(() {});
        },
      );

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

  /// Add a new [GameEvent] of [type] to the given [end].
  void addEvent(final TableEnd end, final GameEventType type) {
    switch (serveNumber) {
      case ServeNumber.first:
        serveNumber = ServeNumber.second;
      case ServeNumber.second:
        switchEnds();
    }
    final event = GameEvent(
      id: uuid.v4(),
      time: DateTime.now(),
      tableEnd: end,
      type: type,
    );
    if (type != GameEventType.goal) {
      foulNumbers[type] = (foulNumbers[type] ?? 0) + 1;
    }
    events.add(event);
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

  /// Perform event deletion.
  Future<void> deleteEvent(final GameEvent event) => context.confirm(
        message: 'Really delete this event?',
        title: 'Delete Event',
        yesCallback: () async {
          Navigator.pop(context);
          events.removeWhere(
            (final oldEvent) => oldEvent.id == event.id,
          );
          // Roll back the server.
          switch (serveNumber) {
            case ServeNumber.first:
              serveNumber = ServeNumber.second;
              servingPlayer = switch (servingPlayer) {
                TableEnd.left => TableEnd.right,
                TableEnd.right => TableEnd.left
              };
            case ServeNumber.second:
              serveNumber = ServeNumber.first;
          }
          setState(() {});
        },
      );
}

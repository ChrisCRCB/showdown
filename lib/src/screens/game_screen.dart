import 'dart:math';

import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/util.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants.dart';
import '../json/game_event.dart';
import '../json/game_event_type.dart';
import '../providers.dart';
import '../serve_number.dart';
import '../table_end.dart';
import '../widgets/custom_text.dart';
import '../widgets/player_panel.dart';
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
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
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
    final shortcuts = <GameShortcut>[
      GameShortcut(
        title: 'Start new game',
        shortcut: GameShortcutsShortcut.keyN,
        controlKey: useControlKey,
        altKey: useMetaKey,
        onStart: newGame,
      ),
      GameShortcut(
        title: 'Left player goal',
        shortcut: GameShortcutsShortcut.keyG,
        controlKey: useControlKey,
        altKey: useMetaKey,
        onStart: (final innerContext) =>
            addEvent(TableEnd.left, GameEventType.goal),
      ),
      GameShortcut(
        title: 'Left player foul',
        shortcut: GameShortcutsShortcut.keyF,
        controlKey: useControlKey,
        altKey: useMetaKey,
        onStart: (final innerContext) => innerContext.pushWidgetBuilder(
          (final innerContext) => SelectFoulScreen(
            onDone: (final value) => addEvent(TableEnd.left, value),
          ),
        ),
      ),
      GameShortcut(
        title: 'Right player foul',
        shortcut: GameShortcutsShortcut.keyJ,
        controlKey: useControlKey,
        altKey: useMetaKey,
        onStart: (final innerContext) => innerContext.pushWidgetBuilder(
          (final innerContext) => SelectFoulScreen(
            onDone: (final value) => addEvent(TableEnd.right, value),
          ),
        ),
      ),
      GameShortcut(
        title: 'Right player goal',
        shortcut: GameShortcutsShortcut.keyH,
        controlKey: useControlKey,
        altKey: useMetaKey,
        onStart: (final innerContext) =>
            addEvent(TableEnd.right, GameEventType.goal),
      ),
      GameShortcut(
        title: 'Switch ends',
        shortcut: GameShortcutsShortcut.keyB,
        controlKey: useControlKey,
        altKey: useMetaKey,
        onStart: (final innerContext) => switchEnds(),
      ),
    ];
    shortcuts.add(
      GameShortcut(
        title: 'Show help',
        shortcut: GameShortcutsShortcut.slash,
        controlKey: useControlKey,
        altKey: useMetaKey,
        onStart: (final innerContext) => innerContext.pushWidgetBuilder(
          (final context) => GameShortcutsHelpScreen(shortcuts: shortcuts),
        ),
      ),
    );
    return GameShortcuts(
      shortcuts: shortcuts,
      child: SimpleScaffold(
        leading: ElevatedButton(
          onPressed: () => newGame(context),
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
                  leftPlayerName = name;
                }),
                events: events,
                addEvent: (final eventType) =>
                    addEvent(TableEnd.left, eventType),
                deleteEvent: deleteEvent,
              ),
            ),
            Expanded(
              flex: widget.middleFlex,
              child: ListView(
                shrinkWrap: true,
                key: ValueKey('$leftPlayerName $rightPlayerName'),
                children: [
                  Semantics(
                    liveRegion: true,
                    child: CustomText(
                      "$servingPlayerName's $serveNumberString serve ($scores)",
                    ),
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
                  rightPlayerName = name;
                }),
                events: getEvents(TableEnd.right),
                addEvent: (final eventType) =>
                    addEvent(TableEnd.right, eventType),
                deleteEvent: deleteEvent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Start a new game.
  Future<void> newGame(final BuildContext context) => confirm(
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
    if (type == GameEventType.goal) {
      switch (serveNumber) {
        case ServeNumber.first:
          serveNumber = ServeNumber.second;
        case ServeNumber.second:
          switchEnds();
      }
    }
    final event = GameEvent(
      id: uuid.v4(),
      time: DateTime.now(),
      tableEnd: end,
      type: type,
    );
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

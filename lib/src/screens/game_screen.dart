import 'dart:math';

import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/util.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../json/game_event.dart';
import '../providers.dart';
import '../serve_number.dart';
import '../table_end.dart';
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
  /// The name of the player at the left hand end of the table.
  late String leftPlayerName;

  /// The name of the player at the right hand end of the table.
  late String rightPlayerName;

  /// Which player is serving.
  late TableEnd servingPlayer;

  /// Whether or not it is the player's first serve..
  late ServeNumber serveNumber;

  /// The number of goals since [servingPlayer] last changed.
  late int goalNumber;

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
    goalNumber = 0;
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
    final value = ref.watch(appPreferencesProvider);
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
            goalNumber = 0;
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
          onPressed: () => alterFontSize(-1),
          icon: const Icon(
            Icons.text_decrease,
            semanticLabel: 'Decrease font size',
          ),
        ),
        IconButton(
          onPressed: () => alterFontSize(1),
          icon: const Icon(
            Icons.text_increase,
            semanticLabel: 'Increase font size',
          ),
        ),
      ],
      title: 'Showdown',
      body: value.when(
        data: (final appPreferences) {
          final fontSize = appPreferences.fontSize.toDouble();
          return Row(
            children: [
              Expanded(
                flex: widget.playerPanelFlex,
                child: PlayerPanel(
                  name: leftPlayerName,
                  tableEnd: TableEnd.left,
                  onChanged: (final name) => setState(() {
                    leftPlayerName = name;
                  }),
                  events: events,
                ),
              ),
              Expanded(
                flex: widget.middleFlex,
                child: Column(
                  children: [
                    Text(
                      "$servingPlayerName's $serveNumberString serve",
                      style: TextStyle(
                        fontSize: fontSize,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: widget.playerPanelFlex,
                child: PlayerPanel(
                  name: rightPlayerName,
                  tableEnd: TableEnd.right,
                  onChanged: (final name) => setState(() {
                    rightPlayerName = name;
                  }),
                  events: getEvents(TableEnd.right),
                ),
              ),
            ],
          );
        },
        error: ErrorListView.withPositional,
        loading: LoadingWidget.new,
      ),
    );
  }

  /// Alter the font size.
  Future<void> alterFontSize(final int amount) async {
    final appPreferences = await ref.read(appPreferencesProvider.future);
    appPreferences.fontSize = min(8, appPreferences.fontSize + amount);
    await appPreferences.safe(ref);
  }

  /// Get events for [end].
  List<GameEvent> getEvents(final TableEnd end) =>
      events.where((final event) => event.tableEnd == end).toList();
}

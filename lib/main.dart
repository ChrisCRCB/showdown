import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/screens/game_screen.dart';

void main() {
  runApp(const MyApp());
}

/// The top-level app class.
class MyApp extends StatelessWidget {
  /// Create an instance.
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(final BuildContext context) {
    if (kIsWeb) {
      WidgetsFlutterBinding.ensureInitialized();
      RendererBinding.instance.ensureSemantics();
    }
    return ProviderScope(
      child: MaterialApp(
        title: 'Showdown',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const GameScreen(),
      ),
    );
  }
}

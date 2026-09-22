import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game/assets.dart';
import 'game/audio.dart';
import 'game/data.dart';
import 'game/game.dart';
import 'game/overlay.dart';

void main() {
  ErrorWidget.builder = (details) {
    final text = 'Terjadi error:\n${details.exception}\n\n${details.stack}';
    debugPrint(text);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(
            text,
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
        ),
      ),
    );
  };
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    final progress = loadProgress(prefs);
    runApp(MyApp(progress: progress, prefs: prefs));
  }, (error, stack) => debugPrint('Uncaught: $error\n$stack'));
}

Progress loadProgress(SharedPreferences prefs) {
  final raw = prefs.getString('progress');
  if (raw == null || raw.isEmpty) return defaultProgress();
  try {
    return sanitizeProgress(jsonDecode(raw));
  } catch (_) {
    return defaultProgress();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.progress, required this.prefs});
  final Progress progress;
  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ayam Pelari Angkasa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: GameScreen(progress: progress, prefs: prefs),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.progress, required this.prefs});
  final Progress progress;
  final SharedPreferences prefs;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final ChickenGame game;
  late final GameAudio audio;

  @override
  void initState() {
    super.initState();
    final store = AssetStore(rootBundle);
    audio = GameAudio();
    game = ChickenGame(store, widget.progress, audio, (type, payload) {
      if (type == 'gameOver') {
        debugPrint('Game over: $payload');
      }
    }, widget.prefs);
  }

  @override
  void dispose() {
    unawaited(audio.dispose());
    if (game.gw?.over != true) game.saveProgress();
    game.onRemove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GameWidget(game: game),
            GameControls(game),
            OverlayPanels(game),
            LoadingOverlay(game),
          ],
        ),
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay(this.game, {super.key});
  final ChickenGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: game.assetsReady,
      builder: (_, r, __) => r
          ? const SizedBox.shrink()
          : const ColoredBox(
              color: Colors.black,
              child: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'assets.dart';
import 'audio.dart';
import 'data.dart';
import 'renderer.dart';
import 'world.dart';

enum OverlayKind { none, pause, map, shop, modes, gameOver, resume }

class ChickenGame extends FlameGame with KeyboardEvents {
  ChickenGame(this.store, this.progress, this.audio, this.onEvent, this.prefs);

  final AssetStore store;
  final Progress progress;
  final GameAudio audio;
  final void Function(String, dynamic) onEvent;
  final SharedPreferences? prefs;

  World? gw;
  bool active = false;
  GameEvent? nextEvent;
  final ValueNotifier<bool> airborne = ValueNotifier(false);
  final ValueNotifier<OverlayKind> overlay = ValueNotifier(OverlayKind.none);
  final ValueNotifier<String?> banner = ValueNotifier(null);
  final ValueNotifier<String?> toast = ValueNotifier(null);
  final ValueNotifier<bool> assetsReady = ValueNotifier(false);
  late final Renderer renderer;

  final InputState input = InputState();
  double saveClock = 0;
  bool runFinalized = false;
  double fade = 0;
  bool _fadingOut = false;
  bool _fadingIn = false;
  Map<String, dynamic>? _pendingArea;

  @override
  Future<void> onLoad() async {
    renderer = Renderer(store);
    await super.onLoad();
    final restored = progress.activeRun;
    final restoredArea = (restored?['areaId'] as num?)?.toInt() ?? 1;
    final restoredMode = restored?['mode'] as String? ?? 'explore';
    final restoredSkin = restored?['skin'] as String? ?? progress.selectedSkin;
    gw = createWorld(
      balance: defaultBalance(),
      areaId: restoredArea,
      mode: restoredMode,
      skinId: restoredSkin,
      restored: restored,
    );
    gw!.paused = true;
    gw!.started = restored != null;
    final skinId = restoredSkin;
    gw!.skinId = skinId;
    gw!.skin = findSkin(skinId);
    gw!.player.extra = gw!.skin!.extra;
    gw!.events = handleWorldEvent;
    if (restored != null) overlay.value = OverlayKind.resume;
    try {
      await store.loadImage(backgroundAsset(gw!.area.id));
      await store.loadSheet(skinAsset(skinId, false));
    } catch (e) {
      debugPrint('Asset awal gagal dimuat: $e');
    }
    store.loadSheet(tileAsset(gw!.area.theme)).then((_) {}, onError: (_) {});
    unawaited(preloadWorld(gw!));
    assetsReady.value = true;
    audio.playMusic('chapter1');
  }

  @override
  void update(double dt) {
    if (gw != null) {
      gw!.bounds = size.toSize();
      if (gw!.player.y == 0 && gw!.player.onGround && gw!.bounds.height > 0) {
        gw!.player.y = gw!.bounds.height * 0.72;
        gw!.player.spawnY = gw!.player.y;
        gw!.player.cy = gw!.player.y;
      }
    }
    if (gw != null && !gw!.paused && !gw!.over) {
      final clamped = math.min(dt, 0.05);
      saveClock += clamped;
      if (saveClock > 1 && !runFinalized) {
        saveClock = 0;
        saveProgress();
      }
      updateWorld(gw!, clamped, input, size.toSize());
      if (gw!.started && gw!.player.hp <= 0) {
        finalizeRun(false);
      }
      airborne.value =
          !gw!.player.onGround && gw!.player.y < gw!.bounds.height * 0.72;
    }
    if (_fadingOut) {
      fade = math.min(1.0, fade + dt / 0.3);
      if (fade >= 1.0) {
        _fadingOut = false;
        _applyAreaChange();
        _fadingIn = true;
      }
    } else if (_fadingIn) {
      fade = math.max(0.0, fade - dt / 0.35);
      if (fade <= 0.0) {
        fade = 0.0;
        _fadingIn = false;
      }
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (gw != null) {
      renderer.render(
        canvas,
        size.toSize(),
        gw!,
        progress,
        toast.value,
        banner.value,
      );
    }
    super.render(canvas);
    if (fade > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = Color.fromARGB((fade * 255).round(), 0, 0, 0),
      );
    }
  }

  void inputPress(String action) {
    if (gw == null) return;
    if (action == 'jump') {
      tapJump();
      return;
    }
    final was = input.held.contains(action);
    input.held.add(action);
    if (action == 'pound') {
      performAction(gw!, 'pound');
    } else if (action == 'dash' && !was) {
      performAction(gw!, 'dash');
    } else if (action == 'skill' && !was) {
      performAction(gw!, 'skill');
    } else if (action == 'up' || action == 'hold') {
      input.held.add('up');
    } else if (action == 'down') {
      input.held.add('down');
    }
  }

  void inputRelease(String action) {
    if (gw == null) return;
    input.held.remove(action);
    if (action == 'jump' || action == 'up' || action == 'hold')
      input.held.remove('up');
    if (action == 'down') input.held.remove('down');
  }

  void tapJump() {
    if (gw == null) return;
    audio.unlock();
    if (gw!.paused && !gw!.started && !gw!.over) {
      gw!.started = true;
      gw!.paused = false;
      audio.playMusic('chapter${gw!.area.id}');
    }
    performAction(gw!, 'jump');
    input.held.add('up');
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    handleKey(event);
    return KeyEventResult.handled;
  }

  void handleKey(KeyEvent event) {
    String? action;
    if (event.logicalKey == LogicalKeyboardKey.space ||
        event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.keyW) {
      action = 'jump';
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.keyA) {
      action = 'left';
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.keyD) {
      action = 'right';
    } else if (event.logicalKey == LogicalKeyboardKey.keyX) {
      action = 'pound';
    } else if (event.logicalKey == LogicalKeyboardKey.keyZ) {
      action = 'dash';
    } else if (event.logicalKey == LogicalKeyboardKey.keyC) {
      action = 'skill';
    } else if (event.logicalKey == LogicalKeyboardKey.shift ||
        event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.keyS) {
      action = 'down';
    }
    if (action == null) return;
    if (event is KeyDownEvent) {
      inputPress(action);
    } else if (event is KeyUpEvent) {
      inputRelease(action);
    }
  }

  void uiAction(String action, [Map<String, dynamic>? payload]) {
    switch (action) {
      case 'pause':
        overlay.value = OverlayKind.pause;
        gw?.paused = true;
        audio.pauseMusic();
        saveProgress();
        break;
      case 'resume':
        overlay.value = OverlayKind.none;
        gw?.paused = false;
        audio.resumeMusic();
        break;
      case 'retry':
      case 'restart':
      case 'new':
        restartRun('explore');
        break;
      case 'quit':
      case 'menu':
        finalizeRun(false);
        break;
      case 'modes':
        overlay.value = OverlayKind.none;
        break;
      case 'mode':
        restartRun('explore');
        break;
      case 'map':
        overlay.value = OverlayKind.map;
        break;
      case 'shop':
        overlay.value = OverlayKind.shop;
        break;
      case 'close':
        overlay.value = gw?.paused == true
            ? OverlayKind.pause
            : OverlayKind.none;
        break;
      case 'area':
        startArea(payload?['area'] as int? ?? 1);
        break;
      case 'skin':
        buySkin(payload?['skin'] as String? ?? 'classic');
        refreshOverlay();
        break;
      case 'continue':
        overlay.value = OverlayKind.none;
        gw?.paused = false;
        if (gw != null) gw!.started = true;
        break;
      case 'nextArea':
        final nextArea = (gw?.area.id ?? 1) + 1;
        if (nextArea <= AREAS.length) startArea(nextArea);
        break;
    }
  }

  void equipSkin(String skinId) {
    if (gw == null) return;
    gw!.skinId = skinId;
    gw!.skin = findSkin(skinId);
    gw!.player.extra = gw!.skin!.extra;
  }

  bool buySkin(String skinId) {
    final skin = findSkin(skinId);
    if (progress.unlockedSkins.contains(skinId)) {
      equipSkin(skinId);
      progress.selectedSkin = skinId;
      unawaited(persist());
      return true;
    }
    if (progress.coins >= skin.price) {
      progress.coins -= skin.price;
      progress.unlockedSkins.add(skinId);
      progress.skins[skinId] = true;
      equipSkin(skinId);
      progress.selectedSkin = skinId;
      toast.value = 'Skin dibeli!';
      Future.delayed(const Duration(seconds: 1), () {
        if (toast.value == 'Skin dibeli!') toast.value = null;
      });
      unawaited(persist());
      return true;
    }
    toast.value = 'Butuh ● ${skin.price} coin';
    Future.delayed(const Duration(seconds: 1), () {
      if (toast.value == 'Butuh ● ${skin.price} coin') toast.value = null;
    });
    return false;
  }

  void startArea(int id) {
    runFinalized = false;
    _fadingOut = false;
    _fadingIn = false;
    fade = 0;
    _pendingArea = null;
    final skinId = gw?.skinId ?? progress.selectedSkin;
    gw = createWorld(balance: defaultBalance(), areaId: id, mode: 'explore');
    gw!.skinId = skinId;
    gw!.skin = findSkin(skinId);
    gw!.player.extra = gw!.skin!.extra;
    gw!.events = handleWorldEvent;
    overlay.value = OverlayKind.none;
    banner.value = null;
    toast.value = null;
    audio.playMusic('chapter${gw!.area.id}');
    preloadWorld(gw!);
    saveProgress();
  }

  void restartRun([String mode = 'explore']) {
    runFinalized = false;
    _fadingOut = false;
    _fadingIn = false;
    fade = 0;
    _pendingArea = null;
    final skinId = gw?.skinId ?? progress.selectedSkin;
    gw = createWorld(balance: defaultBalance(), areaId: 1, mode: mode);
    gw!.skinId = skinId;
    gw!.skin = findSkin(skinId);
    gw!.player.extra = gw!.skin!.extra;
    gw!.events = handleWorldEvent;
    overlay.value = OverlayKind.none;
    banner.value = null;
    toast.value = null;
    audio.playMusic('chapter${gw!.area.id}');
    preloadWorld(gw!);
    saveProgress();
  }

  void quitRun() {
    if (gw != null) finalizeRun(false);
  }

  void refreshOverlay() {
    final v = overlay.value;
    overlay.value = OverlayKind.none;
    overlay.value = v;
  }

  void finalizeRun(bool areaCleared) {
    if (gw == null || runFinalized) return;
    runFinalized = true;
    gw!.over = true;
    gw!.paused = true;
    bankLoot();
    saveProgress(includeRun: false);
    if (areaCleared) banner.value = 'AREA CLEARED!';
    overlay.value = OverlayKind.gameOver;
    onEvent('gameOver', <String, dynamic>{
      'distance': gw!.distance.round(),
      'coins': 0,
      'corn': 0,
      'score': gw!.score.round(),
      'areaCleared': areaCleared,
      'area': gw!.area.id,
    });
  }

  /// Pindahkan hasil kumpulan (coin/corn/...) dari run ke bank progres, lalu reset.
  void bankLoot() {
    final g = gw;
    if (g == null) return;
    final p = progress;
    p.coins += g.collected.coins;
    p.lifetimeCoins += g.collected.coins;
    if (g.collected.coins > 0) {
      p.coinHistory.add(
        CoinHistoryEntry(
          at: DateTime.now().millisecondsSinceEpoch,
          delta: g.collected.coins,
          reason: 'Run Area ${g.area.id.toString().padLeft(2, '0')}',
          balance: p.coins,
        ),
      );
      if (p.coinHistory.length > 20) {
        p.coinHistory = p.coinHistory.sublist(p.coinHistory.length - 20);
      }
    }
    p.corn += g.collected.corn;
    p.feathers += g.collected.feathers;
    p.cheese += g.collected.cheese;
    p.keys += g.collected.keys;
    for (final entry in g.collected.skins.entries) {
      if (entry.value) p.skins[entry.key] = true;
    }
    g.collected.reset();
  }

  void saveProgress({bool includeRun = true}) {
    if (gw == null) return;
    final g = gw!;
    final p = progress;
    if (g.distance.round() > p.bestDistance)
      p.bestDistance = g.distance.round();
    if (g.score.round() > p.bestScore) p.bestScore = g.score.round();
    p.areaBests[g.area.id] = math.max(
      p.areaBests[g.area.id] ?? 0,
      g.distance.round(),
    );
    if (g.distance.round() >= g.area.length && p.unlockedArea < g.area.id + 1) {
      p.unlockedArea = g.area.id + 1;
    }
    p.activeRun = includeRun && g.started && !g.over
        ? <String, dynamic>{
            'areaId': g.area.id,
            'distance': g.distance,
            'localDistance': g.localDistance,
            'collected': <String, dynamic>{
              'coins': g.collected.coins,
              'corn': g.collected.corn,
              'feathers': g.collected.feathers,
              'cheese': g.collected.cheese,
              'keys': g.collected.keys,
            },
            'skin': g.skinId,
            'hp': g.player.hp,
            'seed': g.seed,
            'mode': g.mode,
          }
        : null;
    unawaited(persist());
  }

  Future<void> persist() async {
    final p = prefs;
    if (p == null) return;
    try {
      await p.setString('progress', jsonEncode(progress.toJson()));
    } catch (_) {
      // Penyimpanan opsional; jangan ganggu gameplay.
    }
  }

  void handleWorldEvent(GameEvent? event) {
    if (event == null) return;
    if (event.type == 'start') audio.unlock();
    audio.playEvent(event.type);
    if (event.type == 'areaChange') {
      _pendingArea = event.payload;
      if (!_fadingOut && !_fadingIn) _fadingOut = true;
      final area = event.payload['area'] as Area;
      audio.playMusic('chapter${area.id}');
      banner.value = area.name;
      Future.delayed(const Duration(seconds: 2), () {
        if (banner.value == area.name) banner.value = null;
      });
    } else if (event.type == 'bankLoot') {
      final what = event.payload['what'] as String;
      toast.value = what == 'coin'
          ? '+${event.payload['amount']} coin'
          : what == 'corn'
          ? '+${event.payload['amount']} ðŸŒ½'
          : 'Skin baru!';
      Future.delayed(const Duration(seconds: 1), () {
        if (toast.value != null && toast.value!.startsWith('+'))
          toast.value = null;
      });
    } else if (event.type == 'bossAppears') {
      banner.value = gw!.boss!.name;
      Future.delayed(const Duration(seconds: 2), () {
        if (banner.value == gw!.boss!.name) banner.value = null;
      });
    } else if (event.type == 'bossDefeated') {
      banner.value = 'BOSS DOWN!';
      Future.delayed(const Duration(seconds: 2), () {
        if (banner.value == 'BOSS DOWN!') banner.value = null;
      });
    } else if (event.type == 'runEnd') {
      finalizeRun(true);
    } else if (event.type == 'gameOver') {
      finalizeRun(false);
    }
    onEvent(event.type, event.payload);
  }

  void _applyAreaChange() {
    final payload = _pendingArea;
    if (payload == null || gw == null) return;
    _pendingArea = null;
    final completedArea = payload['completedArea'] as int;
    final completedDistance = payload['completedDistance'] as double;
    final area = payload['area'] as Area;
    progress.areaBests[completedArea] = math.max(
      progress.areaBests[completedArea] ?? 0,
      completedDistance.round(),
    );
    progress.unlockedArea = math.max(progress.unlockedArea, area.id);
    gw!.area = area;
    gw!.areaIndex = AREAS.indexOf(area);
    gw!.balance = balanceFor(progress, area.id);
    gw!.player.baseSpeed = gw!.balance['baseSpeed']!;
    gw!.player.y = gw!.bounds.height * 0.72;
    gw!.player.spawnY = gw!.player.y;
    gw!.player.cy = gw!.player.y;
    gw!.cameraY = 0;
    gw!.distance = 0;
    gw!.localDistance = 0;
    gw!.nextTakeoff = area.id >= 7 ? 45 : 125;
    gw!.bossDone = false;
    gw!.player.energy = gw!.player.maxEnergy;
    gw!.player.flightTimer = area.id >= 7 ? 10 : 0;
    gw!.entities.clear();
    gw!.effects.clear();
    gw!.particles.clear();
    gw!.groundSpeed = gw!.balance['groundSpeed']!;
    gw!.transitioning = false;
    audio.playMusic('chapter${area.id}');
    preloadWorld(gw!);
    unawaited(persist());
  }

  Future<void> preloadWorld(World w) async {
    // Hanya muat asset wajib untuk frame pertama. Sisanya lazy lewat
    // getSheet/getImage saat benar-benar dibutuhkan (renderer sudah menangani null).
    await store.loadImage(backgroundAsset(w.area.id));
    await store.loadSheet(tileAsset(w.area.theme));
    await store.loadSheet(skinAsset(w.skinId, false));
  }

  List<String> criticalAssets(World w) => <String>[
    backgroundAsset(w.area.id),
    tileAsset(w.area.theme),
    skinAsset(w.skinId, false),
  ];
}

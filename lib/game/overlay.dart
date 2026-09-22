import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'assets.dart';
import 'data.dart';
import 'game.dart';

class SkinPreview extends StatelessWidget {
  const SkinPreview(this.store, this.skinId, this.size, {super.key});
  final AssetStore store;
  final String skinId;
  final double size;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image?>(
      future: store.spriteImage(skinAsset(skinId, false), 'idle'),
      builder: (_, snap) {
        if (snap.hasData && snap.data != null) {
          return RawImage(
            image: snap.data!,
            width: size,
            height: size,
            fit: BoxFit.contain,
          );
        }
        return Icon(
          Icons.flutter_dash,
          size: size * 0.7,
          color: Colors.white70,
        );
      },
    );
  }
}

class GameControls extends StatelessWidget {
  const GameControls(this.game, {super.key});
  final ChickenGame game;

  @override
  Widget build(BuildContext context) {
    final skin = SKINS.firstWhere(
      (s) => s.id == game.gw?.skinId,
      orElse: () => SKINS[0],
    );
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: (_) => game.tapJump(),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: _iconBtn(Icons.pause, () => game.uiAction('pause')),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ctrlBtn(
                      icon: Icons.arrow_left,
                      label: 'L',
                      onDown: () => game.inputPress('left'),
                      onUp: () => game.inputRelease('left'),
                    ),
                    const SizedBox(width: 16),
                    _ctrlBtn(
                      icon: Icons.arrow_right,
                      label: 'R',
                      onDown: () => game.inputPress('right'),
                      onUp: () => game.inputRelease('right'),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: game.airborne,
                      builder: (_, air, __) => air
                          ? Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: _ctrlBtn(
                                icon: Icons.keyboard_arrow_down,
                                label: 'v',
                                onDown: () => game.inputPress('down'),
                                onUp: () => game.inputRelease('down'),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    _ctrlBtn(
                      label: 'DASH',
                      onDown: () => game.inputPress('dash'),
                      onUp: () => game.inputRelease('dash'),
                    ),
                    const SizedBox(width: 14),
                    _ctrlBtn(
                      label: 'SKILL',
                      onDown: () => game.inputPress('skill'),
                      onUp: () => game.inputRelease('skill'),
                      extra: skin.power.split(' ').first.toUpperCase(),
                    ),
                    const SizedBox(width: 14),
                    _ctrlBtn(
                      label: 'JUMP',
                      onDown: () => game.inputPress('jump'),
                      onUp: () => game.inputRelease('jump'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => Material(
    color: Colors.black38,
    shape: const CircleBorder(),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    ),
  );

  Widget _ctrlBtn({
    IconData? icon,
    required String label,
    required VoidCallback onDown,
    required VoidCallback onUp,
    String? extra,
  }) => Material(
    color: Colors.white12,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTapDown: (_) => onDown(),
      onTapUp: (_) => onUp(),
      onTapCancel: onUp,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: icon != null
            ? Icon(icon, color: Colors.white, size: 22)
            : Text(
                extra ?? label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
      ),
    ),
  );
}

class OverlayPanels extends StatelessWidget {
  const OverlayPanels(this.game, {super.key});
  final ChickenGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<OverlayKind>(
      valueListenable: game.overlay,
      builder: (_, kind, __) {
        if (game.gw?.over == true) kind = OverlayKind.gameOver;
        if (kind == OverlayKind.none) return const SizedBox.shrink();
        late Widget panel;
        switch (kind) {
          case OverlayKind.pause:
            panel = _pause();
            break;
          case OverlayKind.map:
            panel = _map();
            break;
          case OverlayKind.shop:
            panel = _shop();
            break;
          case OverlayKind.gameOver:
            panel = _gameOver();
            break;
          case OverlayKind.resume:
            panel = _resume();
            break;
          default:
            panel = const SizedBox.shrink();
        }
        return Container(
          color: Colors.black54,
          child: Center(child: panel),
        );
      },
    );
  }

  Widget _card(Widget child) => Container(
    width: 340,
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xff1d272e),
      borderRadius: BorderRadius.circular(18),
    ),
    child: child,
  );

  Widget _btn(String label, VoidCallback onTap, {bool primary = false}) =>
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Material(
          color: primary ? Colors.amber : Colors.white12,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: primary ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _pause() => _card(
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${game.gw!.area.chapter}',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          '${game.gw!.area.emoji} ${game.gw!.area.name}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${game.gw!.distance.round()}m  •  Skor ${game.gw!.score.round()}',
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 8),
        _btn('LANJUT', () => game.uiAction('resume'), primary: true),
        _btn('PILIH MAP', () => game.uiAction('map')),
        _btn('GANTI SKIN AYAM', () => game.uiAction('shop')),
        _btn('AKHIRI RUN', () => game.uiAction('quit')),
      ],
    ),
  );

  Widget _map() {
    final current = game.gw?.area.id ?? 0;
    return _card(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '25 AREA',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const Text(
            'Peta penerbangan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: GridView.count(
              crossAxisCount: 5,
              childAspectRatio: 0.92,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              children: AREAS.map((area) {
                final unlocked = area.id <= game.progress.unlockedArea;
                final isCurrent = area.id == current;
                final best = game.progress.areaBests[area.id] ?? 0;
                return Material(
                  color: !unlocked
                      ? Colors.white10
                      : isCurrent
                      ? Colors.green.shade600
                      : Colors.amber.shade700,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: unlocked
                        ? () => game.uiAction('area', {'area': area.id})
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            unlocked ? area.emoji : '🔒',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            area.id.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: 11,
                              color: unlocked ? Colors.black : Colors.white54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            area.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 8,
                              color: unlocked ? Colors.black87 : Colors.white38,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (unlocked && best > 0)
                            Text(
                              '${best}m',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 7,
                                color: unlocked
                                    ? Colors.black54
                                    : Colors.white24,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          _btn('TUTUP', () => game.uiAction('close')),
        ],
      ),
    );
  }

  Widget _shop() => _card(
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'KANDANG AYAM • ● ${game.progress.coins} COIN',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const Text(
          'Pilih ayam',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 260,
          child: ListView(
            children: SKINS.map((skin) {
              final owned = game.progress.unlockedSkins.contains(skin.id);
              final selected = game.progress.selectedSkin == skin.id;
              final label = selected
                  ? 'DIPAKAI'
                  : owned
                  ? 'PAKAI'
                  : '● ${skin.price}';
              return Material(
                color: selected ? Colors.amber.shade700 : Colors.white10,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => game.uiAction('skin', {'skin': skin.id}),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        SkinPreview(game.store, skin.id, 40),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                skin.name,
                                style: TextStyle(
                                  color: selected ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                skin.passive,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.black87
                                      : Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.black,
                            size: 22,
                          )
                        else if (!owned)
                          const Icon(
                            Icons.lock,
                            color: Colors.white70,
                            size: 18,
                          ),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: TextStyle(
                            color: selected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        _btn('TUTUP', () => game.uiAction('close')),
      ],
    ),
  );

  Widget _gameOver() {
    final w = game.gw!;
    return _card(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            w.win
                ? 'CHECKPOINT TERCAPAI'
                : (w.lastThreat.isNotEmpty
                      ? 'TERKENA ${w.lastThreat.toUpperCase()}'
                      : 'RUN SELESAI'),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            '${w.distance.round()}m',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Skor ${w.score.round()}',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            '● ${w.collected.coins}  🌽 ${w.collected.corn}  🪶 ${w.collected.feathers}  🧀 ${w.collected.cheese}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          _btn('COBA LAGI', () => game.uiAction('retry'), primary: true),
          if (w.win && w.area.id < AREAS.length)
            _btn(
              'LANJUT KE AREA ${w.area.id + 1}',
              () => game.uiAction('nextArea'),
              primary: true,
            ),
        ],
      ),
    );
  }

  Widget _resume() {
    final run = game.progress.activeRun;
    return _card(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🐔🪶', style: TextStyle(fontSize: 28)),
          const Text(
            'RUN TERSIMPAN',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const Text(
            'Lanjut terbang?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(run?['distance'] as double? ?? 0).round()}m  •  Area ${((run?['areaId'] as int?) ?? 1).toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          _btn('CONTINUE', () => game.uiAction('continue'), primary: true),
          _btn('NEW RUN', () => game.uiAction('new')),
        ],
      ),
    );
  }
}

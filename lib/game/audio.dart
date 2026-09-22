import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

// File-based audio engine adapted from the reference AudioEngine.
// BGM uses a dedicated looping player so it never stops while SFX play;
// each SFX uses its own short-lived player so they overlap with the BGM.
class GameAudio {
  GameAudio([this.initialVolume = 0.18]);
  final double initialVolume;

  AudioPlayer? _bgm;

  double _volume = 0.18;
  double _bgmVolume = 0.34;
  bool _enabled = true;
  bool _bgmStarted = false;
  int _areaId = 1;
  int? _playingTrack;

  AudioContext _noFocusContext() => AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const <AVAudioSessionOptions>{
            AVAudioSessionOptions.mixWithOthers,
          },
        ),
      );

  void unlock() {
    _enabled = true;
    if (!_bgmStarted) unawaited(_startBgm());
  }

  void setVolume(double v) => _volume = v.clamp(0, 0.5);

  int get _currentTrack => ((_areaId - 1) ~/ 5).clamp(0, 4) + 1;

  Future<void> _startBgm() async {
    final track = _currentTrack;
    if (track == _playingTrack) return;
    _playingTrack = track;
    _bgmStarted = true;
    try {
      _bgm ??= AudioPlayer();
      await _bgm!.setAudioContext(_noFocusContext());
      await _bgm!.stop();
      await _bgm!.setReleaseMode(ReleaseMode.loop);
      await _bgm!.setVolume(_bgmVolume);
      await _bgm!.play(AssetSource('sfx/bgm$track.mp3'));
    } catch (_) {
      // Audio is optional and should never interrupt gameplay.
      _bgmStarted = false;
    }
  }

  void playMusic(String id) {
    final m = RegExp(r'(\d+)').firstMatch(id);
    if (m != null) _areaId = int.parse(m.group(1)!);
    if (_bgmStarted) unawaited(_startBgm());
  }

  void pauseMusic() => unawaited(_bgm?.pause());
  void resumeMusic() => unawaited(_bgm?.resume());
  void stopMusic() => unawaited(_bgm?.stop());

  Future<void> _play(String filename, {double scale = 1}) async {
    if (!_enabled) return;
    final player = AudioPlayer();
    try {
      await player.setAudioContext(_noFocusContext());
      await player.setVolume((_volume * scale).clamp(0, 1).toDouble());
      player.onPlayerComplete.listen((_) {
        unawaited(player.dispose());
      });
      await player.play(AssetSource('sfx/$filename'));
    } catch (_) {
      // Audio is optional and should never interrupt gameplay.
      unawaited(player.dispose());
    }
  }

  void playEvent(String type) {
    switch (type) {
      case 'jump':
        jump();
        break;
      case 'flap':
        flap();
        break;
      case 'dash':
        dash();
        break;
      case 'coin':
        coin();
        break;
      case 'feather':
        feather();
        break;
      case 'pickup':
        pickup();
        break;
      case 'hit':
        hit();
        break;
      case 'land':
        land();
        break;
      case 'takeoff':
        takeoff();
        break;
      case 'portal':
        portal();
        break;
      case 'warning':
        warning();
        break;
      case 'skill':
        skill();
        break;
      case 'magic':
        skill();
        break;
      case 'smash':
        smash();
        break;
      case 'bossStart':
      case 'bossAttack':
        boss();
        break;
      case 'bossDefeat':
      case 'areaChange':
        area();
        break;
      case 'shieldBreak':
        hit();
        break;
      case 'gameOver':
        gameOver();
        break;
      case 'runEnd':
        win();
        break;
    }
  }

  void jump() => unawaited(_play('jump.mp3'));
  void flap() => unawaited(_play('flap.mp3'));
  void dash() => unawaited(_play('dash.mp3'));
  void coin() => unawaited(_play('coin.mp3'));
  void feather() => unawaited(_play('feather.mp3'));
  void pickup() => unawaited(_play('pickup.mp3'));
  void hit() => unawaited(_play('hit.mp3'));
  void land() => unawaited(_play('land.mp3'));
  void takeoff() => unawaited(_play('takeoff.mp3'));
  void portal() => unawaited(_play('portal.mp3'));
  void warning() => unawaited(_play('warning.mp3'));
  void skill() => unawaited(_play('skill.mp3'));
  void smash() => unawaited(_play('smash.mp3'));
  void gameOver() => unawaited(_play('gameover.mp3'));
  void win() => unawaited(_play('win.mp3'));
  void boss() => unawaited(_play('boss.mp3'));
  void area() => unawaited(_play('area.mp3'));
  void click() => unawaited(_play('click.mp3'));

  Future<void> dispose() async {
    _enabled = false;
    unawaited(_bgm?.dispose());
  }
}

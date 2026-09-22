import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flame/sprite.dart';
import 'package:flame/extensions.dart';

class Frame {
  Frame({required this.name, required this.source, required this.content, required this.anchor});
  final String name;
  final Rect source;
  final Rect content;
  final Offset anchor;
}

class Anim {
  Anim({required this.name, required this.frames});
  final String name;
  final List<Frame> frames;
}

class Sheet {
  Sheet({required this.image, required this.frames, required this.anims});
  final ui.Image image;
  final List<Frame> frames;
  final Map<String, Anim> anims;
}

String imagePathFor(String key) {
  if (key.startsWith('BG_')) {
    final id = key.split('_')[2];
    return 'assets/images/bg_area_$id.webp';
  }
  return 'assets/images/${key.toLowerCase()}-transparent.webp';
}

String jsonPathFor(String key) {
  return 'assets/json/${key.toLowerCase()}-transparent.frames.json';
}

class AssetStore {
  AssetStore(this.bundle);
  final AssetBundle bundle;

  final Map<String, ui.Image> _images = {};
  final Map<String, Sheet> _sheets = {};
  final Set<String> _loading = {};

  Future<ui.Image> loadImage(String key) async {
    if (_images.containsKey(key)) return _images[key]!;
    final path = imagePathFor(key);
    final data = await bundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final image = frame.image;
    _images[key] = image;
    return image;
  }

  final Map<String, ui.Image> _sprites = {};

  Future<ui.Image?> spriteImage(String sheetKey, String frameName) async {
    final cacheKey = '$sheetKey#$frameName';
    if (_sprites.containsKey(cacheKey)) return _sprites[cacheKey];
    final sheet = await loadSheet(sheetKey);
    final frame = findFrame(sheet, frameName) ?? sheet.frames.firstOrNull;
    if (frame == null) return null;
    final c = frame.content;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawImageRect(sheet.image, c, ui.Rect.fromLTWH(0, 0, c.width, c.height), ui.Paint());
    final pic = recorder.endRecording();
    final img = await pic.toImage(c.width.round(), c.height.round());
    _sprites[cacheKey] = img;
    return img;
  }

  Future<Sheet> loadSheet(String key) async {
    if (_sheets.containsKey(key)) return _sheets[key]!;
    final tag = 'sheet:$key';
    if (_loading.contains(tag)) {
      while (_loading.contains(tag)) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      return _sheets[key]!;
    }
    _loading.add(tag);
    try {
      final image = await loadImage(key);
      final raw = await bundle.loadString(jsonPathFor(key));
      final meta = json.decode(raw) as Map<String, dynamic>;
      final framesJson = (meta['frames'] as List).cast<Map<String, dynamic>>();
      final frames = framesJson.map((f) {
        final source = _rect(f['source'] as Map);
        final content = f['content'] != null ? _rect(f['content'] as Map) : source;
        final anchor = f['anchor'] != null ? _offset(f['anchor'] as Map) : Offset(source.left + source.width / 2, source.top + source.height);
        return Frame(name: f['name'] as String, source: source, content: content, anchor: anchor);
      }).toList();
      final anims = <String, Anim>{};
      if (meta['animations'] is List) {
        for (final a in (meta['animations'] as List).cast<Map<String, dynamic>>()) {
          final aframes = (a['frames'] as List).cast<Map<String, dynamic>>().map((f) {
            final source = _rect(f['source'] as Map);
            final content = f['content'] != null ? _rect(f['content'] as Map) : source;
            final anchor = f['anchor'] != null ? _offset(f['anchor'] as Map) : Offset(source.left + source.width / 2, source.top + source.height);
            return Frame(name: f['name'] as String, source: source, content: content, anchor: anchor);
          }).toList();
          anims[a['name'] as String] = Anim(name: a['name'] as String, frames: aframes);
        }
      }
      final sheet = Sheet(image: image, frames: frames, anims: anims);
      _sheets[key] = sheet;
      return sheet;
    } finally {
      _loading.remove(tag);
    }
  }

  Frame? findFrame(Sheet sheet, String name) =>
      sheet.frames.where((f) => f.name.toLowerCase() == name.toLowerCase()).firstOrNull;

  Anim? findAnimation(Sheet sheet, String name) =>
      sheet.anims[name.toLowerCase()] ?? sheet.anims.values.firstOrNull;

  Rect cropOf(Frame frame) => frame.content;

  Sprite spriteFor(Sheet sheet, Frame frame) =>
      Sprite(sheet.image, srcPosition: Vector2(frame.content.left, frame.content.top), srcSize: Vector2(frame.content.width, frame.content.height));

  Future<void> warm(List<String> keys) async {
    await Future.wait(keys.map((key) => key.startsWith('BG_') ? loadImage(key) : loadSheet(key)));
  }

  ui.Image? getImage(String key) {
    if (!_images.containsKey(key)) {
      loadImage(key).then((_) {}, onError: (_) {});
    }
    return _images[key];
  }

  Sheet? getSheet(String key) {
    if (!_sheets.containsKey(key)) {
      loadSheet(key).then((_) {}, onError: (_) {});
    }
    return _sheets[key];
  }

  String urlFor(String key) => imagePathFor(key);
}

Rect _rect(Map m) => Rect.fromLTWH(
      (m['x'] as num).toDouble(),
      (m['y'] as num).toDouble(),
      (m['w'] as num).toDouble(),
      (m['h'] as num).toDouble(),
    );

Offset _offset(Map m) => Offset((m['x'] as num).toDouble(), (m['y'] as num).toDouble());

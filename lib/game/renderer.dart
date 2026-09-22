import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/widgets.dart';

import 'assets.dart';
import 'data.dart';
import 'world.dart';

Color hex(String s) => Color(int.parse('ff${s.replaceFirst('#', '')}', radix: 16));

Color withAlpha(Color c, double a) => Color.fromARGB((a.clamp(0, 1) * 255).round(), c.red, c.green, c.blue);

void roundRect(Canvas canvas, Rect rect, double radius, Paint paint) {
  final r = math.min(radius, math.min(rect.width / 2, rect.height / 2));
  canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(r)), paint);
}

class Renderer {
  Renderer(this.store);
  final AssetStore store;
  late Size _size;

  static const double kZoom = 0.7;

  void render(Canvas canvas, Size size, World world, Progress progress, String? toast, String? banner) {
    _size = size;
    if (size.width == 0 || size.height == 0) return;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = hex(world.area.palette[0]));
    canvas.save();
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.translate(cx, cy);
    canvas.scale(kZoom);
    canvas.translate(-cx, -cy);
    const shakeX = 0.0;
    const shakeY = 0.0;
    canvas.translate(shakeX, shakeY);
    drawBackdrop(canvas, world);
    drawRouteHint(canvas, world);
    drawGround(canvas, world);
    for (final entity in world.entities) {
      if (entity.type == 'item') {
        drawItem(canvas, world, entity);
      } else if (entity.type == 'obstacle') {
        drawObstacle(canvas, world, entity);
      } else if (entity.type == 'enemy') {
        drawEnemy(canvas, world, entity);
      } else if (entity.type == 'warning') {
        drawWarning(canvas, world, entity);
      }
    }
    drawEffects(canvas, world);
    drawBoss(canvas, world);
    drawPlayer(canvas, world);
    canvas.restore();

    drawHud(canvas, world, progress, toast, banner);
  }

  void drawBackdrop(Canvas canvas, World world) {
    final w = _size.width;
    final h = _size.height;
    final image = store.getImage(backgroundAsset(world.area.id));
    final sky = hex(world.area.palette[0]);
    final ground = hex(world.area.palette[1]);
    final gradient = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [sky, ground]);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h)));
    if (image == null) return;
    double scale = h / image.height;
    double tileW = image.width * scale;
    if (tileW < w) {
      scale = w / image.width;
      tileW = w;
    }
    final tileH = image.height * scale;
    final scroll = world.distance * 0.55;
    final offset = scroll % tileW;
    final firstIndex = (scroll / tileW).floor();
    final count = (w / tileW).ceil() + 2;
    for (int i = -1; i < count; i += 1) {
      final x = i * tileW - offset;
      canvas.save();
      if ((firstIndex + i) % 2 == 1) {
        canvas.translate(x + tileW, 0);
        canvas.scale(-1, 1);
        canvas.drawImageRect(image, Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
            Rect.fromLTWH(0, -math.max(0.0, tileH - h), tileW, tileH), Paint());
      } else {
        canvas.drawImageRect(image, Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
            Rect.fromLTWH(x, -math.max(0.0, tileH - h), tileW, tileH), Paint());
      }
      canvas.restore();
    }
  }

  void drawGround(Canvas canvas, World world) {
    final groundY = _size.height * 0.72 + world.cameraY;
    final sheet = store.getSheet(tileAsset(world.area.theme));
    Frame? frame;
    if (sheet != null) {
      frame = store.findFrame(sheet, 'center') ?? sheet.frames.firstOrNull;
    }
    if (sheet?.image == null || frame?.content == null) return;
    final crop = frame!.content;
    final visibleTop = crop.top.toDouble();
    final sourceH = math.max(1.0, crop.bottom - visibleTop);
    final segmentW = math.max(210.0, math.min(330.0, _size.width * 0.66));
    final segmentH = math.max(120.0, sourceH);
    final top = groundY - 12;
    final scroll = world.distance / 0.07;
    final offset = scroll % segmentW;
    final firstIndex = (scroll / segmentW).floor();
    final count = (_size.width / segmentW).ceil() + 3;
    for (int i = -1; i < count; i += 1) {
      final x = i * segmentW - offset;
      canvas.save();
      if ((firstIndex + i) % 2 == 1) {
        canvas.translate(x + segmentW, 0);
        canvas.scale(-1, 1);
        canvas.drawImageRect(sheet!.image, Rect.fromLTWH(crop.left, visibleTop, crop.width, sourceH),
            Rect.fromLTWH(0, top, segmentW + 1, segmentH), Paint());
      } else {
        canvas.drawImageRect(sheet!.image, Rect.fromLTWH(crop.left, visibleTop, crop.width, sourceH),
            Rect.fromLTWH(x, top, segmentW + 1, segmentH), Paint());
      }
      canvas.restore();
    }
  }

  void drawObstacle(Canvas canvas, World world, Entity entity) {
    final y = entity.y + world.cameraY;
    canvas.save();
    canvas.translate(entity.x, y);
    final stroke = Paint()..color = const Color(0xff4b3428)..style = PaintingStyle.stroke..strokeWidth = 4;
    if (entity.kind == 'hay') {
      final fill = Paint()..color = const Color(0xffd6a83d)..style = PaintingStyle.fill;
      roundRect(canvas, Rect.fromLTWH(0, 8, entity.w, entity.h - 8), 12, fill);
      roundRect(canvas, Rect.fromLTWH(0, 8, entity.w, entity.h - 8), 12, stroke);
      final line = Paint()..color = const Color(0xff8f682e)..style = PaintingStyle.stroke;
      canvas.drawLine(const Offset(7, 20), Offset(entity.w - 7, 42), line);
      canvas.drawLine(const Offset(8, 42), Offset(entity.w - 7, 20), line);
    } else if (entity.kind == 'wind') {
      final line = Paint()..color = const Color(0xe6defaff)..style = PaintingStyle.stroke..strokeWidth = 7;
      for (int i = 0; i < 3; i += 1) {
        canvas.drawArc(Rect.fromLTWH(16 + i * 8, 18 + i * 14, 22, 22), -1.1, 2.2, false, line);
      }
    } else if (entity.kind == 'crate') {
      final fill = Paint()..color = const Color(0xff9c6237)..style = PaintingStyle.fill;
      roundRect(canvas, Rect.fromLTWH(0, 0, entity.w, entity.h), 6, fill);
      roundRect(canvas, Rect.fromLTWH(0, 0, entity.w, entity.h), 6, stroke);
      canvas.drawLine(const Offset(8, 8), Offset(entity.w - 8, entity.h - 8), stroke);
      canvas.drawLine(Offset(entity.w - 8, 8), Offset(8, entity.h - 8), stroke);
    } else {
      final fill = Paint()..color = const Color(0xff9c6a42)..style = PaintingStyle.fill;
      for (int i = 0; i < 3; i += 1) {
        roundRect(canvas, Rect.fromLTWH(i * entity.w / 3 + 2, 0, entity.w / 4, entity.h), 4, fill);
        roundRect(canvas, Rect.fromLTWH(i * entity.w / 3 + 2, 0, entity.w / 4, entity.h), 4, stroke);
      }
      canvas.drawRect(Rect.fromLTWH(0, 23, entity.w, 13), fill);
      canvas.drawRect(Rect.fromLTWH(0, 23, entity.w, 13), stroke);
    }
    canvas.restore();
  }

  bool drawFrameInBox(Canvas canvas, Sheet? sheet, String name, double x, double y, double w, double h, {double alpha = 1}) {
    if (sheet?.image == null) return false;
    final frame = store.findFrame(sheet!, name);
    final crop = frame?.content;
    if (crop == null) return false;
    final scale = math.min(w / crop.width, h / crop.height);
    final dw = crop.width * scale;
    final dh = crop.height * scale;
    final sprite = Sprite(sheet.image, srcPosition: Vector2(crop.left, crop.top), srcSize: Vector2(crop.width, crop.height));
    if (alpha < 1) canvas.saveLayer(null, Paint()..color = Color.fromARGB((alpha * 255).round(), 255, 255, 255));
    sprite.render(canvas, position: Vector2(x + (w - dw) / 2, y + (h - dh) / 2), size: Vector2(dw, dh));
    if (alpha < 1) canvas.restore();
    return true;
  }

  void drawItem(Canvas canvas, World world, Entity entity) {
    final sheet = store.getSheet('ITEMS_ATLAS');
    final y = (entity.drawY ?? entity.y) + world.cameraY;
    if (!drawFrameInBox(canvas, sheet, entity.item!, entity.x, y, entity.w, entity.h)) {
      canvas.drawCircle(Offset(entity.x + entity.w / 2, y + entity.h / 2), entity.w / 2,
          Paint()..color = entity.item == 'coin' ? const Color(0xfff5c64d) : const Color(0xfff4efe0));
    }
  }

  void drawEnemy(Canvas canvas, World world, Entity entity) {
    final sheet = store.getSheet(entity.asset!);
    final y = entity.y + entity.h + world.cameraY;
    if (!drawSpriteAnchored(canvas, sheet, entity.animation!, entity.animClock ?? 0, entity.x + entity.w / 2, y, entity.h * 1.45, fps: 8)) {
      canvas.drawCircle(Offset(entity.x + entity.w / 2, entity.y + entity.h / 2), entity.w / 2, Paint()..color = const Color(0xff5a3f42));
    }
  }

  void drawWarning(Canvas canvas, World world, Entity entity) {
    final y = entity.y + world.cameraY;
    final active = (entity.age ?? 0) > 0.85;
    final a = active ? 0.75 : 0.25 + math.sin((entity.age ?? 0) * 24) * 0.2;
    final color = withAlpha(active ? const Color(0xffff594f) : const Color(0xffffe17d), a);
    canvas.drawRect(Rect.fromLTWH(entity.x, y, entity.w, entity.h), Paint()..color = color);
  }

  void drawRouteHint(Canvas canvas, World world) {
    if (world.area.id != 1 || world.localDistance > 115) return;
    final sheet = store.getSheet('ITEMS_ATLAS');
    final progress = world.localDistance / 115;
    final start = _size.width * (0.82 - progress * 0.3);
    for (int i = 0; i < 4; i += 1) {
      final x = start + i * 42;
      final y = _size.height * 0.55 - math.sin(i / 3 * math.pi) * 70;
      drawFrameInBox(canvas, sheet, 'feather', x, y, 28, 28, alpha: 0.82);
    }
    drawText(canvas, 'ikuti bulu', start + 62, _size.height * 0.51, 14, const Color(0xe0ffffff), align: TextAlign.center);
  }

  void drawBoss(Canvas canvas, World world) {
    if (world.boss == null) return;
    final sheet = store.getSheet(world.boss!.asset);
    final x = world.boss!.x;
    final y = world.boss!.y + world.cameraY;
    final height = math.min(330.0, math.max(150.0, _size.height * 0.43));
    drawSpriteAnchored(canvas, sheet, world.boss!.animation, world.boss!.animClock, x, y, height, fps: 7, flipX: world.boss!.sourceFacing == 'left');
  }

  void drawEffects(Canvas canvas, World world) {
    for (final effect in world.effects) {
      if (effect.type == 'warning') continue;
      final key = ['takeoff', 'coinburst', 'impact', 'dash'].contains(effect.type) ? 'EFFECTS_FLIGHT' : 'EFFECTS_MAGIC';
      final sheet = store.getSheet(key);
      final anim = sheet != null ? store.findAnimation(sheet, effect.type) : null;
      if (anim == null || anim.frames.isEmpty) continue;
      final frame = anim.frames[math.min(anim.frames.length - 1, (effect.age / effect.duration * anim.frames.length).floor())];
      drawFrameInBox(canvas, sheet, frame.name, effect.x - 55, effect.y - 55 + world.cameraY, 110, 110, alpha: 1 - effect.age / effect.duration * 0.2);
    }
    for (final p in world.particles) {
      final a = math.max(0, 1 - p.age / p.life).toDouble();
      canvas.drawCircle(Offset(p.x, p.y + world.cameraY), p.size, Paint()..color = withAlpha(hex(p.color), a));
    }
  }

  void drawPlayer(Canvas canvas, World world) {
    final player = world.player;
    final extra = ['land', 'hurt', 'skill'].contains(player.anim);
    Sheet? sheet = store.getSheet(skinAsset(world.skinId, extra));
    sheet ??= store.getSheet(skinAsset(world.skinId, false));
    final alpha = player.invulnerable > 0 && (player.invulnerable * 14).floor() % 2 == 1 ? 0.35 : 1.0;
    final y = player.y + world.cameraY;
    if (player.shield) {
      final halo = RadialGradient(
        center: Alignment(((player.x / _size.width) * 2 - 1).toDouble(), ((y - 34) / _size.height * 2 - 1).toDouble()),
        radius: 1,
        colors: const [Color(0x146fc8ff), Color(0x38c9f7ff), Color(0x00c9f7ff)],
        stops: const [0, 0.75, 1],
      );
      canvas.drawCircle(Offset(player.x, y - 34), 56,
          Paint()..shader = halo.createShader(Rect.fromLTWH(player.x - 56, y - 90, 112, 112)));
      canvas.drawCircle(Offset(player.x, y - 34), 43, Paint()..color = const Color(0xccf9f7ff)..style = PaintingStyle.stroke..strokeWidth = 3);
    }
    final onGround = player.onGround;
    final bob = onGround ? math.sin(player.animClock * 16) * 2.5 : 0.0;
    final waddle = onGround ? math.sin(player.animClock * 16) * 0.04 : 0.0;
    canvas.save();
    canvas.translate(player.x, y);
    canvas.rotate(waddle);
    canvas.translate(-player.x, -y);
    canvas.translate(0, -bob);
    drawSpriteAnchored(canvas, sheet, player.anim, player.animClock, player.x, y, math.min(86.0, _size.height * 0.15),
        fps: player.anim == 'run' ? 11.0 : 8.0, alpha: alpha);
    canvas.restore();
  }

  bool drawSpriteAnchored(Canvas canvas, Sheet? sheet, String animName, double clock, double anchorX, double anchorY, double targetHeight,
      {double fps = 9, bool flipX = false, double alpha = 1}) {
    if (sheet?.image == null) return false;
    final anim = store.findAnimation(sheet!, animName) ?? sheet.anims.values.firstOrNull;
    if (anim == null || anim.frames.isEmpty) return false;
    final frame = anim.frames[(clock * fps).floor() % anim.frames.length];
    final crop = frame.content;
    if (crop.height == 0) return false;
    final scale = targetHeight / crop.height;
    final dx = anchorX - (frame.anchor.dx - crop.left) * scale;
    final dy = anchorY - (frame.anchor.dy - crop.top) * scale;
    canvas.save();
    if (alpha < 1) canvas.saveLayer(null, Paint()..color = Color.fromARGB((alpha * 255).round(), 255, 255, 255));
    if (flipX) {
      canvas.translate(anchorX * 2, 0);
      canvas.scale(-1, 1);
    }
    final sprite = Sprite(sheet.image, srcPosition: Vector2(crop.left, crop.top), srcSize: Vector2(crop.width, crop.height));
    sprite.render(canvas, position: Vector2(dx, dy), size: Vector2(crop.width * scale, crop.height * scale));
    if (alpha < 1) canvas.restore();
    canvas.restore();
    return true;
  }

  void drawHud(Canvas canvas, World world, Progress progress, String? toast, String? banner) {
    final player = world.player;
    for (int i = 0; i < 3; i += 1) {
      drawText(canvas, '♥', 18 + i * 26, 18, 24, i >= player.hp ? const Color(0x55ffffff) : const Color(0xff6be0a0));
    }
    drawText(canvas, '● ${progress.coins + world.collected.coins}', 100, 20, 18, const Color(0xfff5c64d));
    drawText(canvas, '🌽 ${progress.corn + world.collected.corn}', 180, 20, 16, const Color(0xffe6d69b));
    drawText(canvas, '${world.distance.round()}m', _size.width - 70, 18, 20, const Color(0xffffffff), align: TextAlign.right);
    drawText(canvas, world.mode == 'time' ? '${world.timeLeft.ceil()}s' : 'BEST ${progress.bestDistance.round()}m', _size.width - 70, 42, 13, const Color(0xccffffff),
        align: TextAlign.right);
    final energyW = 140.0;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(18, 52, energyW, 12), const Radius.circular(6)), Paint()..color = const Color(0x401d272e));
    final eFill = math.max(0.0, math.min(100.0, player.energy / player.maxEnergy * 100)) / 100 * energyW;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(18, 52, eFill, 12), const Radius.circular(6)), Paint()..color = const Color(0xffc7f7ff));
    drawText(canvas, '×${world.multiplier.toStringAsFixed(world.multiplier % 1 == 0 ? 0 : 1)}', 18 + energyW + 10, 50, 16, const Color(0xfff5e6a0));
    if (world.boss != null) {
      drawText(canvas, world.boss!.name, _size.width / 2, 18, 16, const Color(0xffffffff), align: TextAlign.center);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(_size.width / 2 - 90, 40, 180, 10), const Radius.circular(5)), Paint()..color = const Color(0x401d272e));
      final bFill = world.boss!.stamina / 100 * 180;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(_size.width / 2 - 90, 40, bFill, 10), const Radius.circular(5)), Paint()..color = const Color(0xffe2554f));
    }
    if (!world.started && !world.over) {
      drawText(canvas, 'BERGERAK UNTUK MULAI', _size.width / 2, _size.height - 150, 16, const Color(0xffffffff), align: TextAlign.center);
      drawText(canvas, 'lari → lompat → terbang', _size.width / 2, _size.height - 128, 12, const Color(0xccffffff), align: TextAlign.center);
    }
    if (banner != null) {
      drawText(canvas, banner, _size.width / 2, 90, 22, const Color(0xffffffff), align: TextAlign.center);
    }
    if (toast != null) {
      drawText(canvas, toast, _size.width / 2, _size.height * 0.3, 18, const Color(0xffffe17d), align: TextAlign.center);
    }
  }
}

void drawText(Canvas canvas, String text, double x, double y, double size, Color color, {TextAlign align = TextAlign.left}) {
  final tp = TextPainter(
    text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
    textAlign: align,
    textDirection: TextDirection.ltr,
  );
  tp.layout();
  double dx = x;
  if (align == TextAlign.center) {
    dx = x - tp.width / 2;
  } else if (align == TextAlign.right) {
    dx = x - tp.width;
  }
  tp.paint(canvas, Offset(dx, y));
}

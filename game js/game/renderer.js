import { backgroundAsset, skinAsset, tileAsset } from "./data.js";

const findFrame = (meta, name) => meta?.frames?.find((frame) => frame.name.toLowerCase() === name.toLowerCase());
const findAnimation = (meta, name) => meta?.animations?.find((animation) => animation.name.toLowerCase() === name.toLowerCase());

function cropOf(frame) {
  return frame?.content || frame?.source;
}

function drawFrameInBox(ctx, sheet, frame, x, y, w, h, alpha = 1) {
  const crop = cropOf(frame);
  if (!sheet?.image || !crop) return false;
  const scale = Math.min(w / crop.w, h / crop.h);
  const dw = crop.w * scale;
  const dh = crop.h * scale;
  ctx.save();
  ctx.globalAlpha = alpha;
  ctx.drawImage(sheet.image, crop.x, crop.y, crop.w, crop.h, x + (w - dw) / 2, y + (h - dh) / 2, dw, dh);
  ctx.restore();
  return true;
}

function drawAnchored(ctx, sheet, animationName, clock, anchorX, anchorY, targetHeight, alpha = 1, fps = 9, flipX = false) {
  const animation = findAnimation(sheet?.meta, animationName) || sheet?.meta?.animations?.[0];
  if (!animation?.frames?.length || !sheet?.image) return false;
  const frame = animation.frames[Math.floor(clock * fps) % animation.frames.length];
  const crop = cropOf(frame);
  if (!crop) return false;
  const scale = targetHeight / crop.h;
  const anchor = frame.anchor || { x: frame.source.x + frame.source.w / 2, y: frame.source.y + frame.source.h };
  const dx = anchorX - (anchor.x - crop.x) * scale;
  const dy = anchorY - (anchor.y - crop.y) * scale;
  ctx.save();
  ctx.globalAlpha = alpha;
  if (flipX) {
    ctx.translate(anchorX * 2, 0);
    ctx.scale(-1, 1);
  }
  ctx.drawImage(sheet.image, crop.x, crop.y, crop.w, crop.h, dx, dy, crop.w * scale, crop.h * scale);
  ctx.restore();
  return true;
}

function roundedRect(ctx, x, y, w, h, radius) {
  const r = Math.min(radius, w / 2, h / 2);
  ctx.beginPath();
  ctx.roundRect(x, y, w, h, r);
}

export function createRenderer(canvas, store) {
  const ctx = canvas.getContext("2d", { alpha: false });
  const bounds = { width: 0, height: 0 };
  let observer;

  function resize() {
    const rect = canvas.getBoundingClientRect();
    if (!rect.width || !rect.height) return;
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    canvas.width = Math.round(rect.width * dpr);
    canvas.height = Math.round(rect.height * dpr);
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    bounds.width = rect.width;
    bounds.height = rect.height;
  }

  function start() {
    resize();
    observer = new ResizeObserver(resize);
    observer.observe(canvas);
  }

  function drawBackdrop(world) {
    const { width: w, height: h } = bounds;
    const image = store.getImage(backgroundAsset(world.area.id));
    const [sky, ground] = world.area.palette;
    const gradient = ctx.createLinearGradient(0, 0, 0, h);
    gradient.addColorStop(0, sky);
    gradient.addColorStop(1, ground);
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, w, h);
    if (!image) return;
    let scale = h / image.height;
    let tileW = image.width * scale;
    if (tileW < w) { scale = w / image.width; tileW = w; }
    const tileH = image.height * scale;
    const scroll = world.distance * 0.55;
    const offset = scroll % tileW;
    const firstIndex = Math.floor(scroll / tileW);
    const count = Math.ceil(w / tileW) + 2;
    for (let i = -1; i < count; i += 1) {
      const x = i * tileW - offset;
      ctx.save();
      if ((firstIndex + i) % 2) {
        ctx.translate(x + tileW, 0);
        ctx.scale(-1, 1);
        ctx.drawImage(image, 0, -Math.max(0, tileH - h), tileW, tileH);
      } else ctx.drawImage(image, x, -Math.max(0, tileH - h), tileW, tileH);
      ctx.restore();
    }
    const wash = ctx.createLinearGradient(0, 0, 0, h);
    wash.addColorStop(0, "rgba(255,255,255,.03)");
    wash.addColorStop(0.72, "rgba(21,30,34,.05)");
    wash.addColorStop(1, "rgba(21,30,34,.25)");
    ctx.fillStyle = wash;
    ctx.fillRect(0, 0, w, h);
  }

  function drawGround(world) {
    const groundY = bounds.height * 0.72 + world.cameraY;
    const sheet = store.getSheet(tileAsset(world.area.theme));
    const frame = findFrame(sheet?.meta, "center") || sheet?.meta?.frames?.find((entry) => entry.content);
    const crop = cropOf(frame);
    if (sheet?.image && crop) {
      const sourceSurface = frame.surfaceY ?? crop.y;
      const visibleTop = Math.max(crop.y, sourceSurface - 18);
      const sourceH = Math.max(1, crop.y + crop.h - visibleTop);
      const segmentW = Math.max(210, Math.min(330, bounds.width * 0.66));
      const segmentH = Math.max(90, bounds.height - groundY + 24);
      const scroll = world.distance / 0.07;
      const offset = scroll % segmentW;
      const firstIndex = Math.floor(scroll / segmentW);
      const count = Math.ceil(bounds.width / segmentW) + 3;
      for (let i = -1; i < count; i += 1) {
        const x = i * segmentW - offset;
        ctx.save();
        if ((firstIndex + i) % 2) {
          ctx.translate(x + segmentW, 0);
          ctx.scale(-1, 1);
          ctx.drawImage(sheet.image, crop.x, visibleTop, crop.w, sourceH, 0, groundY - 12, segmentW + 1, segmentH);
        } else {
          ctx.drawImage(sheet.image, crop.x, visibleTop, crop.w, sourceH, x, groundY - 12, segmentW + 1, segmentH);
        }
        ctx.restore();
      }
    } else {
      ctx.fillStyle = world.area.theme === "storm" ? "#40515c" : world.area.theme === "city" ? "#647681" : "#754b32";
      ctx.fillRect(0, groundY, bounds.width, bounds.height - groundY);
    }
    ctx.fillStyle = "rgba(30,24,22,.35)";
    ctx.fillRect(0, groundY - 3, bounds.width, 5);
  }

  function drawObstacle(world, entity) {
    const y = entity.y + world.cameraY;
    ctx.save();
    ctx.translate(entity.x, y);
    ctx.lineWidth = 4;
    ctx.strokeStyle = "#4b3428";
    if (entity.kind === "hay") {
      ctx.fillStyle = "#d6a83d";
      roundedRect(ctx, 0, 8, entity.w, entity.h - 8, 12);
      ctx.fill(); ctx.stroke();
      ctx.strokeStyle = "#8f682e";
      ctx.beginPath(); ctx.moveTo(7, 20); ctx.lineTo(entity.w - 7, 42); ctx.moveTo(8, 42); ctx.lineTo(entity.w - 7, 20); ctx.stroke();
    } else if (entity.kind === "wind") {
      ctx.strokeStyle = "rgba(222,250,255,.9)";
      ctx.lineWidth = 7;
      for (let i = 0; i < 3; i += 1) { ctx.beginPath(); ctx.arc(16 + i * 8, 18 + i * 14, 22, -1.1, 1.1); ctx.stroke(); }
    } else if (entity.kind === "crate") {
      ctx.fillStyle = "#9c6237";
      roundedRect(ctx, 0, 0, entity.w, entity.h, 6); ctx.fill(); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(8, 8); ctx.lineTo(entity.w - 8, entity.h - 8); ctx.moveTo(entity.w - 8, 8); ctx.lineTo(8, entity.h - 8); ctx.stroke();
    } else {
      ctx.fillStyle = "#9c6a42";
      for (let i = 0; i < 3; i += 1) { roundedRect(ctx, i * entity.w / 3 + 2, 0, entity.w / 4, entity.h, 4); ctx.fill(); ctx.stroke(); }
      ctx.fillRect(0, 23, entity.w, 13); ctx.strokeRect(0, 23, entity.w, 13);
    }
    ctx.restore();
  }

  function drawItem(world, entity) {
    const sheet = store.getSheet("ITEMS_ATLAS");
    const frame = findFrame(sheet?.meta, entity.item);
    const y = (entity.drawY ?? entity.y) + world.cameraY;
    if (!drawFrameInBox(ctx, sheet, frame, entity.x, y, entity.w, entity.h)) {
      ctx.fillStyle = entity.item === "coin" ? "#f5c64d" : "#f4efe0";
      ctx.beginPath(); ctx.arc(entity.x + entity.w / 2, y + entity.h / 2, entity.w / 2, 0, Math.PI * 2); ctx.fill();
    }
  }

  function drawEnemy(world, entity) {
    const sheet = store.getSheet(entity.asset);
    const alpha = 1;
    const y = entity.y + entity.h + world.cameraY;
    if (!drawAnchored(ctx, sheet, entity.animation, entity.animClock, entity.x + entity.w / 2, y, entity.h * 1.45, alpha, 8)) {
      ctx.fillStyle = "#5a3f42";
      ctx.beginPath(); ctx.ellipse(entity.x + entity.w / 2, entity.y + entity.h / 2, entity.w / 2, entity.h / 2, 0, 0, Math.PI * 2); ctx.fill();
    }
  }

  function drawWarning(world, entity) {
    const y = entity.y + world.cameraY;
    const active = entity.age > 0.85;
    ctx.save();
    ctx.globalAlpha = active ? 0.75 : 0.25 + Math.sin(entity.age * 24) * 0.2;
    ctx.fillStyle = active ? "#ff594f" : "#ffe17d";
    roundedRect(ctx, entity.x, y, entity.w, entity.h, 10); ctx.fill();
    ctx.restore();
  }

  function drawRouteHint(world) {
    if (world.area.id !== 1 || world.localDistance > 115) return;
    const sheet = store.getSheet("ITEMS_ATLAS");
    const frame = findFrame(sheet?.meta, "feather");
    const progress = world.localDistance / 115;
    const start = bounds.width * (0.82 - progress * 0.3);
    for (let i = 0; i < 4; i += 1) {
      const x = start + i * 42;
      const y = bounds.height * 0.55 - Math.sin(i / 3 * Math.PI) * 70;
      drawFrameInBox(ctx, sheet, frame, x, y, 28, 28, 0.82);
    }
    ctx.fillStyle = "rgba(255,255,255,.88)";
    ctx.font = "700 14px Nunito, sans-serif";
    ctx.textAlign = "center";
    ctx.fillText("ikuti bulu", start + 62, bounds.height * 0.51);
  }

  function drawBoss(world) {
    if (!world.boss) return;
    const sheet = store.getSheet(world.boss.asset);
    const x = world.boss.x;
    const y = world.boss.y + world.cameraY;
    const height = Math.min(330, Math.max(150, bounds.height * 0.43));
    drawAnchored(ctx, sheet, world.boss.animation, world.boss.animClock, x, y, height, 1, 7, world.boss.sourceFacing === "left");
  }

  function drawEffects(world) {
    for (const effect of world.effects) {
      if (effect.type === "warning") continue;
      const key = ["takeoff", "coinburst", "impact", "dash"].includes(effect.type) ? "EFFECTS_FLIGHT" : "EFFECTS_MAGIC";
      const sheet = store.getSheet(key);
      const animation = findAnimation(sheet?.meta, effect.type);
      if (!animation) continue;
      const frame = animation.frames[Math.min(animation.frames.length - 1, Math.floor(effect.age / effect.duration * animation.frames.length))];
      drawFrameInBox(ctx, sheet, frame, effect.x - 55, effect.y - 55 + world.cameraY, 110, 110, 1 - effect.age / effect.duration * 0.2);
    }
    for (const particle of world.particles) {
      ctx.globalAlpha = Math.max(0, 1 - particle.age / particle.life);
      ctx.fillStyle = particle.color;
      ctx.beginPath(); ctx.arc(particle.x, particle.y + world.cameraY, particle.size, 0, Math.PI * 2); ctx.fill();
    }
    ctx.globalAlpha = 1;
  }

  function drawPlayer(world) {
    const player = world.player;
    const extra = ["land", "hurt", "skill"].includes(player.anim);
    const sheet = store.getSheet(skinAsset(world.skinId, extra));
    const alpha = player.invulnerable > 0 && Math.floor(player.invulnerable * 14) % 2 ? 0.35 : 1;
    const y = player.y + world.cameraY;
    if (player.shield) {
      const halo = ctx.createRadialGradient(player.x, y - 34, 18, player.x, y - 34, 54);
      halo.addColorStop(0, "rgba(111,220,255,.08)");
      halo.addColorStop(0.75, "rgba(111,220,255,.22)");
      halo.addColorStop(1, "rgba(111,220,255,0)");
      ctx.fillStyle = halo; ctx.beginPath(); ctx.arc(player.x, y - 34, 56, 0, Math.PI * 2); ctx.fill();
      ctx.strokeStyle = "rgba(201,247,255,.8)"; ctx.lineWidth = 3; ctx.beginPath(); ctx.arc(player.x, y - 34, 43, 0, Math.PI * 2); ctx.stroke();
    }
    if (!drawAnchored(ctx, sheet, player.anim, player.animClock, player.x, y, Math.min(86, bounds.height * 0.15), alpha, player.anim === "run" ? 11 : 8)) {
      ctx.fillStyle = "#f3c64e"; ctx.beginPath(); ctx.ellipse(player.x, y - 32, 34, 28, 0, 0, Math.PI * 2); ctx.fill();
    }
  }

  function render(world) {
    if (!bounds.width || !bounds.height) return;
    ctx.save();
    const shakeX = world.shake > 0 ? (Math.random() - 0.5) * 10 : 0;
    const shakeY = world.shake > 0 ? (Math.random() - 0.5) * 7 : 0;
    ctx.translate(shakeX, shakeY);
    drawBackdrop(world);
    drawRouteHint(world);
    drawGround(world);
    for (const entity of world.entities) {
      if (entity.type === "item") drawItem(world, entity);
      else if (entity.type === "obstacle") drawObstacle(world, entity);
      else if (entity.type === "enemy") drawEnemy(world, entity);
      else if (entity.type === "warning") drawWarning(world, entity);
    }
    drawEffects(world);
    drawBoss(world);
    drawPlayer(world);
    ctx.restore();
  }

  return { start, resize, render, bounds, destroy() { observer?.disconnect(); } };
}

import { AREAS, BOSSES, ENEMIES } from "./data.js";

const clamp = (value, min, max) => Math.max(min, Math.min(max, value));
const overlap = (a, b) => a.x < b.x + b.w && a.x + a.w > b.x && a.y < b.y + b.h && a.y + a.h > b.y;
const AREA_LENGTH = 1000;
const BOSS_START_DISTANCE = 780;

function skinRules(id) {
  return {
    gravity: id === "astronaut" ? 0.8 : 1,
    airControl: id === "violet" ? 1.2 : 1,
    energy: id === "mint" ? 1.3 : 1,
    speed: id === "neon" ? 1.1 : 1,
    coin: id === "pirate" ? 1.25 : id === "golden" ? 1.2 : 1,
    combo: id === "sunset" ? 1.15 : 1,
    powerDuration: id === "wizard" ? 1.2 : 1,
  };
}

export function createWorld({ areaId = 1, mode = "explore", skinId = "classic", restored = null, balance }) {
  const areaIndex = clamp((restored?.areaId || areaId) - 1, 0, AREAS.length - 1);
  const rules = skinRules(skinId);
  const maxEnergy = Math.round(100 * rules.energy);
  const world = {
    mode,
    skinId,
    areaIndex,
    area: AREAS[areaIndex],
    started: false,
    paused: false,
    over: false,
    win: false,
    elapsed: restored?.elapsed || 0,
    timeLeft: mode === "time" ? Math.max(0, restored?.timeLeft ?? 180) : Infinity,
    distance: restored?.distance || 0,
    localDistance: restored?.localDistance || 0,
    score: restored?.score || 0,
    combo: restored?.combo || 0,
    multiplier: 1,
    collected: {
      coins: restored?.collected?.coins || 0,
      corn: restored?.collected?.corn || 0,
      feathers: restored?.collected?.feathers || 0,
      cheese: restored?.collected?.cheese || 0,
      keys: restored?.collected?.keys || 0,
    },
    entities: [],
    effects: [],
    particles: [],
    spawnTimer: 0.4,
    nextTakeoff: restored?.nextTakeoff || (areaIndex >= 6 ? 45 : 125),
    shake: 0,
    cameraY: 0,
    eventId: 0,
    boss: null,
    bossDone: false,
    lastThreat: "",
    balance,
    rules,
    player: {
      x: restored?.player?.x || 150,
      y: restored?.player?.y || 0,
      vx: 0,
      vy: restored?.player?.vy || 0,
      hp: restored?.player?.hp || 3,
      energy: restored?.player?.energy ?? maxEnergy,
      maxEnergy,
      onGround: true,
      dashTimer: 0,
      dashCooldown: 0,
      invulnerable: 0,
      hurtTimer: 0,
      landTimer: 0,
      flapTimer: 0,
      skillTimer: 0,
      skillCooldown: restored?.player?.skillCooldown || 0,
      slowTimer: 0,
      flightTimer: areaIndex >= 6 ? 10 : 0,
      shield: skinId === "cocoa",
      magnetTimer: 0,
      infiniteEnergy: 0,
      scoreBoost: 0,
      destroyTimer: 0,
      rocketTimer: 0,
      animClock: 0,
      anim: "idle",
    },
  };
  return world;
}

function emit(world, type, payload = {}) {
  world.eventId += 1;
  world.events?.({ id: world.eventId, type, ...payload });
}

export function setWorldEvents(world, callback) {
  world.events = callback;
}

export function performAction(world, action) {
  if (world.over || world.paused) return;
  const player = world.player;
  if (!world.started) {
    world.started = true;
    emit(world, "start");
  }
  if (action === "jump" || action === "up") {
    if (player.onGround) {
      player.vy = -world.balance.jumpForce * world.rules.gravity;
      player.onGround = false;
      player.animClock = 0;
      emit(world, "jump");
    } else if ((player.flightTimer > 0 || world.area.id >= 7) && player.energy > 3) {
      player.vy = -world.balance.flapForce;
      player.flapTimer = 0.32;
      if (player.infiniteEnergy <= 0) player.energy = Math.max(0, player.energy - 7);
      player.animClock = 0;
      emit(world, "flap");
    }
  }
  if (action === "dash" && player.dashCooldown <= 0) {
    player.dashTimer = 0.38;
    player.dashCooldown = 1.35;
    player.animClock = 0;
    emit(world, "dash");
  }
  if (action === "skill" && player.skillCooldown <= 0) activateSkill(world);
}

function activateSkill(world) {
  const player = world.player;
  const duration = world.rules.powerDuration;
  player.skillTimer = 0.75;
  player.skillCooldown = 12;
  player.animClock = 0;
  switch (world.skinId) {
    case "classic": player.dashTimer = 2.5; player.dashCooldown = 0; break;
    case "cocoa": player.destroyTimer = 5 * duration; break;
    case "violet": world.entities.forEach((entity) => { entity.x -= 120; }); break;
    case "mint": player.infiniteEnergy = 5 * duration; break;
    case "sunset": player.scoreBoost = 6 * duration; break;
    case "astronaut": player.flightTimer = Math.max(player.flightTimer, 7 * duration); player.infiniteEnergy = 7 * duration; break;
    case "pirate": player.magnetTimer = 7 * duration; break;
    case "wizard": {
      const obstacle = world.entities.find((entity) => entity.type === "obstacle");
      if (obstacle) { obstacle.type = "item"; obstacle.item = "coin"; obstacle.w = 34; obstacle.h = 34; emit(world, "magic", { x: obstacle.x, y: obstacle.y }); }
      break;
    }
    case "neon": player.destroyTimer = 5; player.scoreBoost = 5; player.dashTimer = 5; player.slowTimer = 7; break;
    case "golden": player.destroyTimer = 6; player.scoreBoost = 6; player.infiniteEnergy = 6; player.flightTimer = Math.max(player.flightTimer, 6); break;
    default: break;
  }
  emit(world, "skill");
}

function spawnItem(world, bounds, item = "coin", xOffset = 0, yOffset = 0) {
  const ground = bounds.height * 0.72;
  const air = world.player.flightTimer > 0 || world.area.id >= 7;
  world.entities.push({
    type: "item",
    item,
    x: bounds.width + 70 + xOffset,
    y: air ? ground - 125 + yOffset : ground - 42 + yOffset,
    w: 34,
    h: 34,
    phase: Math.random() * Math.PI * 2,
  });
}

function spawnPattern(world, bounds) {
  const roll = Math.random();
  const ground = bounds.height * 0.72;
  const difficulty = 1 + world.area.id * 0.045 + world.elapsed / 180;
  if (roll < 0.28) {
    const count = 4 + Math.floor(Math.random() * 3);
    for (let i = 0; i < count; i += 1) spawnItem(world, bounds, "coin", i * 43, -Math.sin((i / Math.max(1, count - 1)) * Math.PI) * 72);
  } else if (roll < 0.45) {
    world.entities.push({ type: "obstacle", kind: ["fence", "hay", "crate", "wind"][world.area.id % 4], x: bounds.width + 80, y: ground - 56, w: 48 + Math.random() * 18, h: 56, breakable: Math.random() < 0.3 });
    for (let i = 0; i < 3; i += 1) spawnItem(world, bounds, i === 1 ? "corn" : "coin", 30 + i * 42, -88 - Math.sin(i * Math.PI / 2) * 35);
  } else if (roll < 0.62) {
    const type = world.area.enemy || "bird";
    const enemy = ENEMIES[type];
    world.entities.push({ type: "enemy", enemy: type, asset: enemy.asset, animation: enemy.animation, x: bounds.width + 90, y: enemy.flying ? ground - 120 - Math.random() * 100 : ground - 60, w: enemy.size, h: enemy.size * 0.75, baseY: enemy.flying ? ground - 120 - Math.random() * 100 : ground - 60, phase: Math.random() * 6, animClock: 0 });
  } else if (roll < 0.82) {
    const special = Math.random() < 0.28 ? ["feather", "cheese", "key"][Math.floor(Math.random() * 3)] : "coin";
    for (let i = 0; i < 5; i += 1) spawnItem(world, bounds, i === 2 ? special : "coin", i * 40, -35 - i * 22);
  } else if (roll < 0.9) {
    const power = ["balloon", "wing", "rocket", "magnet", "eggshield", "electricegg"][Math.floor(Math.random() * 6)];
    spawnItem(world, bounds, power, 0, -70);
  } else {
    spawnItem(world, bounds, "heart", 0, -55);
  }
  world.spawnTimer = Math.max(0.62, world.balance.spawnGap / difficulty);
}

function spawnSafeCoins(world, bounds) {
  for (let i = 0; i < 5; i += 1) {
    spawnItem(world, bounds, "coin", i * 42, -Math.sin(i / 4 * Math.PI) * 48);
  }
  world.spawnTimer = 1.35;
}

function beginTakeoff(world, bounds) {
  world.player.flightTimer = Math.max(world.player.flightTimer, world.area.id >= 7 ? 14 : 9);
  world.player.vy = -310;
  world.player.onGround = false;
  world.player.energy = Math.min(world.player.maxEnergy, world.player.energy + 24);
  world.effects.push({ type: "takeoff", x: world.player.x, y: world.player.y, age: 0, duration: 0.6 });
  for (let i = 0; i < 6; i += 1) spawnItem(world, bounds, i === 2 ? "feather" : "coin", i * 44, -60 - i * 24);
  world.nextTakeoff += world.area.id >= 7 ? 170 : 235;
  emit(world, "takeoff");
}

function beginBoss(world, bounds) {
  const info = BOSSES[world.area.boss];
  const ground = bounds.height * 0.72;
  world.boss = {
    ...info,
    id: world.area.boss,
    stamina: 100,
    attackTimer: 1.4,
    strikeTimer: 0,
    elapsed: 0,
    animClock: 0,
    chaseAnimation: info.animation,
    animation: info.animation,
    x: -180,
    y: info.grounded ? ground : world.player.y,
    hitThisAttack: false,
  };
  if (!info.grounded) world.player.flightTimer = Math.max(world.player.flightTimer, 35);
  world.player.energy = world.player.maxEnergy;
  emit(world, "bossStart", { name: info.name });
  world.effects.push({ type: "warning", x: bounds.width * 0.75, y: bounds.height * 0.3, age: 0, duration: 1.2 });
}

function updateBoss(world, dt, bounds) {
  const boss = world.boss;
  if (!boss) return;
  boss.elapsed += dt;
  boss.animClock += dt;
  boss.attackTimer -= dt;
  boss.strikeTimer = Math.max(0, boss.strikeTimer - dt);
  const ground = bounds.height * 0.72;
  const targetX = Math.max(-15, world.player.x - (boss.strikeTimer > 0 ? 58 : 105));
  const targetY = boss.grounded ? ground : world.player.y + 8;
  boss.x += (targetX - boss.x) * Math.min(1, dt * 1.9);
  boss.y += (targetY - boss.y) * Math.min(1, dt * 2.8);
  if (boss.strikeTimer > 0) boss.animation = boss.strike;
  else if (boss.attackTimer < 0.72) boss.animation = boss.windup;
  else boss.animation = boss.chaseAnimation;
  if (boss.attackTimer <= 0) {
    if (!boss.hitThisAttack) boss.stamina = Math.max(0, boss.stamina - 9);
    boss.hitThisAttack = false;
    boss.attackTimer = 2.4;
    boss.strikeTimer = 0.48;
    boss.animation = boss.strike;
    const y = clamp(world.player.y - 25 + (Math.random() - 0.5) * 90, 70, bounds.height * 0.72 - 45);
    const warningX = Math.max(0, boss.x + 55);
    world.entities.push({ type: "warning", x: warningX, y, w: bounds.width - warningX, h: 22, age: 0, targetY: y });
    emit(world, "bossAttack");
  }
  if (boss.stamina <= 0) {
    emit(world, "bossDefeat", { name: boss.name });
    world.boss = null;
    world.bossDone = true;
    world.effects.push({ type: "portal", x: bounds.width * 0.72, y: bounds.height * 0.38, age: 0, duration: 0.7 });
    emit(world, "portal");
    changeArea(world);
  }
}

function playerBox(world) {
  return { x: world.player.x - 23, y: world.player.y - 48, w: 46, h: 44 };
}

function collect(world, entity) {
  const player = world.player;
  const currencyBoost = world.skinId === "golden" ? 1.2 : 1;
  switch (entity.item) {
    case "coin": world.collected.coins += Math.ceil(world.rules.coin); world.score += Math.round(10 * world.multiplier * (player.scoreBoost > 0 ? (world.skinId === "golden" ? 3 : 2) : 1)); world.combo += 1; emit(world, "coin", { combo: world.combo }); break;
    case "corn": world.collected.corn += Math.ceil(currencyBoost); world.score += 25; emit(world, "pickup", { item: "corn" }); break;
    case "feather": world.collected.feathers += Math.ceil(currencyBoost); player.energy = Math.min(player.maxEnergy, player.energy + 28); world.score += 40; emit(world, "feather"); break;
    case "cheese": world.collected.cheese += Math.ceil(currencyBoost); world.score += 75; emit(world, "pickup", { item: "cheese" }); break;
    case "key": world.collected.keys += 1; world.score += 100; emit(world, "pickup", { item: "key" }); break;
    case "heart": player.hp = Math.min(3, player.hp + 1); emit(world, "pickup", { item: "heart" }); break;
    case "balloon": player.flightTimer = Math.max(player.flightTimer, 8); player.vy = -120; emit(world, "power", { item: "balloon" }); break;
    case "wing": player.infiniteEnergy = 7; emit(world, "power", { item: "wing" }); break;
    case "rocket": player.rocketTimer = 5; player.destroyTimer = 5; player.flightTimer = Math.max(player.flightTimer, 5); emit(world, "power", { item: "rocket" }); break;
    case "magnet": player.magnetTimer = 8; emit(world, "power", { item: "magnet" }); break;
    case "eggshield": player.shield = true; emit(world, "power", { item: "eggshield" }); break;
    case "electricegg": world.entities = world.entities.filter((entry) => entry.type !== "enemy"); world.score += 120; emit(world, "power", { item: "electricegg" }); break;
    default: break;
  }
  world.multiplier = 1 + Math.min(4, Math.floor(world.combo / 8) * 0.5 * world.rules.combo);
  world.effects.push({ type: entity.item === "feather" ? "featherpickup" : "coinburst", x: entity.x + entity.w / 2, y: entity.y + entity.h / 2, age: 0, duration: 0.45 });
}

function hurt(world, threat) {
  const player = world.player;
  if (player.invulnerable > 0 || player.dashTimer > 0 || player.destroyTimer > 0) return;
  if (player.shield) {
    player.shield = false;
    player.invulnerable = 0.7;
    world.effects.push({ type: "shieldbreak", x: player.x, y: player.y - 28, age: 0, duration: 0.5 });
    emit(world, "shieldBreak");
    return;
  }
  player.hp -= 1;
  player.invulnerable = 1.35;
  player.hurtTimer = 0.55;
  player.vy = -250;
  world.combo = 0;
  world.multiplier = 1;
  world.shake = 0.35;
  world.lastThreat = threat;
  if (world.boss) world.boss.hitThisAttack = true;
  emit(world, "hit", { threat });
  if (player.hp <= 0) endRun(world, false);
}

function endRun(world, win) {
  world.over = true;
  world.win = win;
  world.started = false;
  emit(world, "gameOver", { win, threat: world.lastThreat || "Kehabisan tenaga" });
}

function changeArea(world) {
  if (world.area.id === AREAS.length && world.mode === "story") {
    endRun(world, true);
    return;
  }
  if (world.mode === "explore") {
    endRun(world, true);
    return;
  }
  const completedArea = world.area.id;
  const completedDistance = world.localDistance;
  const next = (world.areaIndex + 1) % AREAS.length;
  world.areaIndex = next;
  world.area = AREAS[next];
  world.localDistance = 0;
  world.nextTakeoff = world.area.id >= 7 ? 45 : 125;
  world.bossDone = false;
  world.entities.length = 0;
  world.player.energy = world.player.maxEnergy;
  world.player.flightTimer = world.area.id >= 7 ? 10 : 0;
  emit(world, "areaChange", { area: world.area, completedArea, completedDistance });
}

function chooseAnimation(world, input) {
  const player = world.player;
  if (!world.started) return "idle";
  if (player.skillTimer > 0) return "skill";
  if (player.hurtTimer > 0) return "hurt";
  if (player.landTimer > 0) return "land";
  if (player.dashTimer > 0) return "dash";
  if (!player.onGround && (player.flightTimer > 0 || world.area.id >= 7)) return player.flapTimer > 0 || input.isHeld("up") || input.isHeld("jump") ? "flap" : "glide";
  if (!player.onGround) return "jump";
  return "run";
}

export function updateWorld(world, dt, input, bounds) {
  if (world.paused || world.over || !bounds.width || !bounds.height) return;
  const player = world.player;
  const ground = bounds.height * 0.72;
  if (!player.y || player.y > bounds.height + 100) player.y = ground;
  player.animClock += dt;
  world.effects.forEach((effect) => { effect.age += dt; });
  world.effects = world.effects.filter((effect) => effect.age < effect.duration);
  world.particles.forEach((particle) => { particle.age += dt; particle.x += particle.vx * dt; particle.y += particle.vy * dt; particle.vy += 180 * dt; });
  world.particles = world.particles.filter((particle) => particle.age < particle.life);
  if (!world.started) { player.anim = "idle"; return; }

  world.elapsed += dt;
  if (world.mode === "time") {
    world.timeLeft -= dt;
    if (world.timeLeft <= 0) { world.timeLeft = 0; endRun(world, true); return; }
  }
  ["dashTimer", "dashCooldown", "invulnerable", "hurtTimer", "landTimer", "flapTimer", "skillTimer", "skillCooldown", "infiniteEnergy", "scoreBoost", "destroyTimer", "rocketTimer", "magnetTimer"].forEach((key) => { player[key] = Math.max(0, player[key] - dt); });
  if (player.slowTimer > 0) player.slowTimer = Math.max(0, player.slowTimer - dt);
  if (player.flightTimer > 0) player.flightTimer = Math.max(0, player.flightTimer - dt);
  world.shake = Math.max(0, world.shake - dt);

  const direction = (input.isHeld("right") ? 1 : 0) - (input.isHeld("left") ? 1 : 0);
  const flightControl = !player.onGround ? world.rules.airControl : 1;
  player.vx += direction * 900 * flightControl * dt;
  player.vx *= Math.pow(0.002, dt);
  player.x = clamp(player.x + player.vx * dt, bounds.width * 0.16, bounds.width * 0.5);

  const flying = player.flightTimer > 0 || world.area.id >= 7;
  let gravity = world.balance.gravity * world.rules.gravity;
  if (world.area.id === 14) gravity *= 0.12;
  else if (world.area.id === 13) gravity *= 0.35;
  else if (flying) gravity *= 0.42;
  if (flying && input.isHeld("up") && player.energy > 0) {
    player.vy -= 560 * dt;
    if (player.infiniteEnergy <= 0) player.energy = Math.max(0, player.energy - 18 * dt);
  }
  if (!player.onGround && input.isHeld("down")) player.vy += 620 * dt;
  player.vy += gravity * dt;
  player.vy = clamp(player.vy, -620, flying ? 360 : 780);
  player.y += player.vy * dt;
  const ceiling = 55;
  if (player.y < ceiling) { player.y = ceiling; player.vy = Math.max(40, player.vy); }
  if (player.y >= ground) {
    const wasAir = !player.onGround;
    player.y = ground;
    player.vy = 0;
    player.onGround = true;
    player.energy = Math.min(player.maxEnergy, player.energy + 35 * dt);
    if (wasAir) { player.landTimer = 0.38; player.animClock = 0; emit(world, "land"); }
  } else player.onGround = false;

  const slow = player.slowTimer > 0 && player.slowTimer < 2 ? 0.72 : 1;
  const speed = world.balance.runSpeed * world.rules.speed * slow * (1 + Math.min(0.55, world.elapsed / 150)) * (player.dashTimer > 0 ? 1.55 : 1) * (player.rocketTimer > 0 ? 1.35 : 1);
  const meters = speed * dt * 0.07;
  world.distance += meters;
  world.localDistance += meters;
  world.score += meters * world.multiplier * (player.scoreBoost > 0 ? (world.skinId === "golden" ? 3 : 2) : 1);
  world.cameraY += ((player.onGround ? 0 : clamp((ground - player.y) * 0.2, 0, 90)) - world.cameraY) * Math.min(1, dt * 3.5);

  if (world.localDistance >= world.nextTakeoff) beginTakeoff(world, bounds);
  if (!world.boss && world.area.boss && !world.bossDone && world.localDistance >= BOSS_START_DISTANCE) beginBoss(world, bounds);
  updateBoss(world, dt, bounds);
  if (!world.area.boss && world.localDistance >= AREA_LENGTH) {
    world.effects.push({ type: "portal", x: bounds.width * 0.72, y: bounds.height * 0.38, age: 0, duration: 0.7 });
    emit(world, "portal");
    changeArea(world);
    return;
  }

  world.spawnTimer -= dt;
  if (world.spawnTimer <= 0) {
    if (world.elapsed < 10) spawnSafeCoins(world, bounds);
    else spawnPattern(world, bounds);
  }

  const pBox = playerBox(world);
  for (const entity of world.entities) {
    if (entity.type !== "warning") entity.x -= speed * dt;
    entity.animClock = (entity.animClock || 0) + dt;
    if (entity.type === "item") {
      entity.phase += dt * 4;
      entity.drawY = entity.y + Math.sin(entity.phase) * 5;
      if (player.magnetTimer > 0 && Math.abs(entity.x - player.x) < 240) {
        entity.x += (player.x - entity.x) * dt * 7;
        entity.y += (player.y - 30 - entity.y) * dt * 7;
      }
    }
    if (entity.type === "enemy" && ENEMIES[entity.enemy]?.flying) {
      entity.y = entity.baseY + Math.sin(entity.phase + world.elapsed * 2.2) * 28;
    }
    if (entity.type === "warning") {
      entity.age += dt;
      if (entity.age > 0.85 && entity.age < 1.2 && overlap(pBox, entity)) hurt(world, world.boss?.name || "Serangan boss");
      continue;
    }
    const eBox = { x: entity.x, y: entity.drawY ?? entity.y, w: entity.w, h: entity.h };
    if (!overlap(pBox, eBox)) continue;
    if (entity.type === "item") { collect(world, entity); entity.dead = true; }
    else if (entity.type === "obstacle") {
      if (player.destroyTimer > 0 || player.dashTimer > 0 && entity.breakable) { entity.dead = true; world.score += 35; emit(world, "smash", { x: entity.x, y: entity.y }); }
      else hurt(world, entity.kind || "Rintangan");
    } else if (entity.type === "enemy") {
      if (player.destroyTimer > 0 || player.dashTimer > 0) { entity.dead = true; world.score += 60; emit(world, "smash", { x: entity.x, y: entity.y }); }
      else hurt(world, entity.enemy);
    }
  }
  world.entities = world.entities.filter((entity) => !entity.dead && entity.x > -180 && (entity.type !== "warning" || entity.age < 1.3));
  player.anim = chooseAnimation(world, input);
}

export function worldSnapshot(world) {
  return {
    areaId: world.area.id,
    mode: world.mode,
    skinId: world.skinId,
    elapsed: world.elapsed,
    timeLeft: Number.isFinite(world.timeLeft) ? world.timeLeft : null,
    distance: world.distance,
    localDistance: world.localDistance,
    score: world.score,
    combo: world.combo,
    collected: { ...world.collected },
    nextTakeoff: world.nextTakeoff,
    player: {
      x: world.player.x,
      y: world.player.y,
      vy: world.player.vy,
      hp: world.player.hp,
      energy: world.player.energy,
      skillCooldown: world.player.skillCooldown,
    },
  };
}

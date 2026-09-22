import 'dart:math' as math;
import 'dart:ui';

import 'data.dart';

const double AREA_LENGTH = 1000;
const double BOSS_START_DISTANCE = 780;

double clamp(double value, double min, double max) =>
    math.max(min, math.min(max, value));

bool overlap(Rect a, Rect b) =>
    a.left < b.right &&
    a.right > b.left &&
    a.top < b.bottom &&
    a.bottom > b.top;

class GameEvent {
  GameEvent(this.type, [this.payload = const {}]);
  final String type;
  final Map<String, dynamic> payload;
}

class Player {
  Player({
    required this.x,
    required this.y,
    this.vx = 0,
    this.vy = 0,
    this.hp = 3,
    this.energy = 100,
    this.maxEnergy = 100,
    this.onGround = true,
    this.dashTimer = 0,
    this.dashCooldown = 0,
    this.invulnerable = 0,
    this.hurtTimer = 0,
    this.landTimer = 0,
    this.flapTimer = 0,
    this.skillTimer = 0,
    this.skillCooldown = 0,
    this.slowTimer = 0,
    this.flightTimer = 0,
    this.shield = false,
    this.magnetTimer = 0,
    this.infiniteEnergy = 0,
    this.scoreBoost = 0,
    this.destroyTimer = 0,
    this.rocketTimer = 0,
    this.animClock = 0,
    this.anim = 'idle',
  });

  double x;
  double y;
  double vx;
  double vy;
  int hp;
  double energy;
  double maxEnergy;
  bool onGround;
  double dashTimer;
  double dashCooldown;
  double invulnerable;
  double hurtTimer;
  double landTimer;
  double flapTimer;
  double skillTimer;
  double skillCooldown;
  double slowTimer;
  double flightTimer;
  bool shield;
  double magnetTimer;
  double infiniteEnergy;
  double scoreBoost;
  double destroyTimer;
  double rocketTimer;
  double animClock;
  String anim;
  bool holding = false;
  int inputDir = 0;
  bool extra = false;
  int airJumps = 1;
  double baseSpeed = 245;
  double spawnY = 0;
  double cy = 0;
}

class Entity {
  Entity({
    required this.type,
    this.item,
    this.kind,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    this.phase,
    this.drawY,
    this.enemy,
    this.asset,
    this.animation,
    this.baseY,
    this.animClock,
    this.breakable = false,
    this.age,
    this.targetY,
    this.dead = false,
  });
  String type;
  String? item;
  String? kind;
  double x;
  double y;
  double w;
  double h;
  double? phase;
  double? drawY;
  String? enemy;
  String? asset;
  String? animation;
  double? baseY;
  double? animClock;
  bool breakable = false;
  double? age;
  double? targetY;
  bool dead = false;
}

class Effect {
  Effect({
    required this.type,
    required this.x,
    required this.y,
    required this.age,
    required this.duration,
    this.targetY,
  });
  final String type;
  double x;
  double y;
  double age;
  final double duration;
  double? targetY;
}

class Particle {
  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.age,
    required this.life,
    required this.size,
    required this.color,
  });
  double x;
  double y;
  double vx;
  double vy;
  double age;
  final double life;
  final double size;
  final String color;
}

class Boss {
  Boss({
    required this.id,
    required this.name,
    required this.asset,
    required this.animation,
    required this.windup,
    required this.strike,
    required this.grounded,
    required this.sourceFacing,
    required this.x,
    required this.y,
    required this.stamina,
    required this.attackTimer,
    required this.strikeTimer,
    required this.elapsed,
    required this.animClock,
    required this.chaseAnimation,
    required this.hitThisAttack,
  });
  final String id;
  final String name;
  final String asset;
  String animation;
  final String windup;
  final String strike;
  final bool grounded;
  final String sourceFacing;
  double x;
  double y;
  double stamina;
  double attackTimer;
  double strikeTimer;
  double elapsed;
  double animClock;
  final String chaseAnimation;
  bool hitThisAttack;
}

class Collected {
  Collected({
    this.coins = 0,
    this.corn = 0,
    this.feathers = 0,
    this.cheese = 0,
    this.keys = 0,
    this.skins = const {},
  });
  int coins;
  int corn;
  int feathers;
  int cheese;
  int keys;
  Map<String, bool> skins;

  void reset() {
    coins = 0;
    corn = 0;
    feathers = 0;
    cheese = 0;
    keys = 0;
    skins = {};
  }
}

class World {
  World({
    required this.mode,
    required this.skinId,
    required this.areaIndex,
    required this.area,
    required this.started,
    required this.paused,
    required this.over,
    required this.win,
    required this.elapsed,
    required this.timeLeft,
    required this.distance,
    required this.localDistance,
    required this.score,
    required this.combo,
    required this.multiplier,
    required this.collected,
    required this.entities,
    required this.effects,
    required this.particles,
    required this.spawnTimer,
    required this.nextTakeoff,
    required this.shake,
    required this.cameraY,
    required this.eventId,
    required this.boss,
    required this.bossDone,
    required this.lastThreat,
    required this.balance,
    required this.rules,
    required this.player,
    required this.bounds,
    required this.seed,
    required this.groundSpeed,
    this.skin,
  });
  final String mode;
  String skinId;
  int areaIndex;
  Area area;
  bool started;
  bool paused;
  bool over;
  bool win;
  double elapsed;
  double timeLeft;
  double distance;
  double localDistance;
  double score;
  int combo;
  double multiplier;
  Collected collected;
  List<Entity> entities;
  List<Effect> effects;
  List<Particle> particles;
  double spawnTimer;
  double nextTakeoff;
  double shake;
  double cameraY;
  int eventId;
  Boss? boss;
  bool bossDone;
  bool transitioning = false;
  String lastThreat;
  final Map<String, double> rules;
  Map<String, double> balance;
  final Player player;
  Skin? skin;
  Size bounds;
  int seed;
  double groundSpeed;

  void Function(GameEvent)? events;
}

Map<String, double> skinRules(String id) {
  switch (id) {
    case 'astronaut':
      return {
        'gravity': 0.8,
        'airControl': 1.0,
        'energy': 1.3,
        'speed': 1.0,
        'coin': 1.0,
        'combo': 1.0,
        'powerDuration': 1.0,
      };
    case 'violet':
      return {
        'gravity': 1.0,
        'airControl': 1.2,
        'energy': 1.0,
        'speed': 1.0,
        'coin': 1.0,
        'combo': 1.0,
        'powerDuration': 1.0,
      };
    case 'mint':
      return {
        'gravity': 1.0,
        'airControl': 1.0,
        'energy': 1.3,
        'speed': 1.0,
        'coin': 1.0,
        'combo': 1.0,
        'powerDuration': 1.0,
      };
    case 'sunset':
      return {
        'gravity': 1.0,
        'airControl': 1.0,
        'energy': 1.0,
        'speed': 1.0,
        'coin': 1.0,
        'combo': 1.15,
        'powerDuration': 1.0,
      };
    case 'pirate':
      return {
        'gravity': 1.0,
        'airControl': 1.0,
        'energy': 1.0,
        'speed': 1.0,
        'coin': 1.25,
        'combo': 1.0,
        'powerDuration': 1.0,
      };
    case 'wizard':
      return {
        'gravity': 1.0,
        'airControl': 1.0,
        'energy': 1.0,
        'speed': 1.0,
        'coin': 1.0,
        'combo': 1.0,
        'powerDuration': 1.2,
      };
    case 'neon':
      return {
        'gravity': 1.0,
        'airControl': 1.0,
        'energy': 1.0,
        'speed': 1.1,
        'coin': 1.0,
        'combo': 1.0,
        'powerDuration': 1.0,
      };
    case 'golden':
      return {
        'gravity': 1.0,
        'airControl': 1.0,
        'energy': 1.0,
        'speed': 1.0,
        'coin': 1.2,
        'combo': 1.0,
        'powerDuration': 1.0,
      };
    default:
      return {
        'gravity': 1.0,
        'airControl': 1.0,
        'energy': 1.0,
        'speed': 1.0,
        'coin': 1.0,
        'combo': 1.0,
        'powerDuration': 1.0,
      };
  }
}

World createWorld({
  int areaId = 1,
  String mode = 'explore',
  String skinId = 'classic',
  Map<String, dynamic>? restored,
  required Map<String, double> balance,
}) {
  final areaIndex = clamp(
    ((restored?['areaId'] ?? areaId) - 1).toDouble(),
    0.0,
    AREAS.length - 1,
  ).toInt();
  final rules = skinRules(skinId);
  final maxEnergy = (100 * rules['energy']!).roundToDouble();
  final player = Player(
    x: restored?['player']?['x']?.toDouble() ?? 150,
    y: restored?['player']?['y']?.toDouble() ?? 0,
    vy: restored?['player']?['vy']?.toDouble() ?? 0,
    hp: restored?['player']?['hp']?.toInt() ?? restored?['hp']?.toInt() ?? 3,
    energy: restored?['player']?['energy']?.toDouble() ?? maxEnergy,
    maxEnergy: maxEnergy,
    onGround: true,
    skillCooldown: restored?['player']?['skillCooldown']?.toDouble() ?? 0,
    flightTimer: areaIndex >= 6 ? 10 : 0,
    shield: skinId == 'cocoa',
  );
  return World(
    mode: mode,
    skinId: skinId,
    areaIndex: areaIndex,
    area: AREAS[areaIndex],
    started: false,
    paused: false,
    over: false,
    win: false,
    elapsed: restored?['elapsed']?.toDouble() ?? 0,
    timeLeft: mode == 'time'
        ? math.max(0, (restored?['timeLeft'] ?? 180).toDouble())
        : double.infinity,
    distance: restored?['distance']?.toDouble() ?? 0,
    localDistance: restored?['localDistance']?.toDouble() ?? 0,
    score: restored?['score']?.toDouble() ?? 0,
    combo: restored?['combo']?.toInt() ?? 0,
    multiplier: 1,
    collected: Collected(
      coins: restored?['collected']?['coins']?.toInt() ?? 0,
      corn: restored?['collected']?['corn']?.toInt() ?? 0,
      feathers: restored?['collected']?['feathers']?.toInt() ?? 0,
      cheese: restored?['collected']?['cheese']?.toInt() ?? 0,
      keys: restored?['collected']?['keys']?.toInt() ?? 0,
    ),
    entities: [],
    effects: [],
    particles: [],
    spawnTimer: 0.4,
    nextTakeoff:
        restored?['nextTakeoff']?.toDouble() ?? (areaIndex >= 6 ? 45 : 125),
    shake: 0,
    cameraY: 0,
    eventId: 0,
    boss: null,
    bossDone: false,
    lastThreat: '',
    balance: balance,
    rules: rules,
    player: player,
    bounds: Size(360, 640),
    seed: restored?['seed'] ?? math.Random().nextInt(1 << 31),
    groundSpeed: 0,
    skin: findSkin(skinId),
  );
}

void emit(World world, String type, [Map<String, dynamic> payload = const {}]) {
  world.eventId += 1;
  world.events?.call(GameEvent(type, {...payload}));
}

void setWorldEvents(World world, void Function(GameEvent) callback) {
  world.events = callback;
}

class InputState {
  final Set<String> held = {};
  bool isHeld(String action) => held.contains(action);
  void clear() => held.clear();
}

void performAction(World world, String action) {
  if (world.over || world.paused) return;
  final player = world.player;
  if (!world.started) {
    world.started = true;
    emit(world, 'start');
  }
  if (action == 'jump' || action == 'up') {
    if (player.onGround) {
      player.vy = -world.balance['jumpForce']! * world.rules['gravity']!;
      player.onGround = false;
      player.airJumps = 1;
      player.animClock = 0;
      emit(world, 'jump');
    } else if (player.airJumps > 0 &&
        player.flightTimer <= 0 &&
        world.area.id < 7 &&
        player.energy >= player.maxEnergy * 0.2) {
      player.vy = -world.balance['jumpForce']! * world.rules['gravity']! * 0.95;
      player.flightTimer = math.max(player.flightTimer, 1.3);
      player.energy = math.max(0, player.energy - player.maxEnergy * 0.2);
      player.airJumps -= 1;
      player.animClock = 0;
      emit(world, 'flap');
    } else if ((player.flightTimer > 0 || world.area.id >= 7) &&
        player.energy > 3) {
      player.vy = -world.balance['flapForce']!;
      player.flapTimer = 0.32;
      if (player.infiniteEnergy <= 0)
        player.energy = math.max(0, player.energy - 7);
      player.animClock = 0;
      emit(world, 'flap');
    }
  }
  if (action == 'dash' && player.dashCooldown <= 0) {
    player.dashTimer = 0.38;
    player.dashCooldown = 1.35;
    player.animClock = 0;
    emit(world, 'dash');
  }
  if (action == 'skill' && player.skillCooldown <= 0) activateSkill(world);
}

void activateSkill(World world) {
  final player = world.player;
  final duration = world.rules['powerDuration']!;
  player.skillTimer = 0.75;
  player.skillCooldown = 12;
  player.animClock = 0;
  switch (world.skinId) {
    case 'classic':
      player.dashTimer = 2.5;
      player.dashCooldown = 0;
      break;
    case 'cocoa':
      player.destroyTimer = 5 * duration;
      break;
    case 'violet':
      for (final entity in world.entities) {
        entity.x -= 120;
      }
      break;
    case 'mint':
      player.infiniteEnergy = 5 * duration;
      break;
    case 'sunset':
      player.scoreBoost = 6 * duration;
      break;
    case 'astronaut':
      player.flightTimer = math.max(player.flightTimer, 7 * duration);
      player.infiniteEnergy = 7 * duration;
      break;
    case 'pirate':
      player.magnetTimer = 7 * duration;
      break;
    case 'wizard':
      final obstacle = world.entities
          .where((e) => e.type == 'obstacle')
          .firstOrNull;
      if (obstacle != null) {
        obstacle.type = 'item';
        obstacle.item = 'coin';
        obstacle.w = 34;
        obstacle.h = 34;
        emit(world, 'magic', {'x': obstacle.x, 'y': obstacle.y});
      }
      break;
    case 'neon':
      player.destroyTimer = 5;
      player.scoreBoost = 5;
      player.dashTimer = 5;
      player.slowTimer = 7;
      break;
    case 'golden':
      player.destroyTimer = 6;
      player.scoreBoost = 6;
      player.infiniteEnergy = 6;
      player.flightTimer = math.max(player.flightTimer, 6);
      break;
    default:
      break;
  }
  emit(world, 'skill');
}

void spawnItem(
  World world,
  Size bounds, {
  String item = 'coin',
  double xOffset = 0,
  double yOffset = 0,
}) {
  final ground = bounds.height * 0.72;
  final air = world.player.flightTimer > 0 || world.area.id >= 7;
  world.entities.add(
    Entity(
      type: 'item',
      item: item,
      x: bounds.width + 70 + xOffset,
      y: air ? ground - 125 + yOffset : ground - 42 + yOffset,
      w: 34,
      h: 34,
      phase: math.Random().nextDouble() * math.pi * 2,
    ),
  );
}

void spawnPattern(World world, Size bounds) {
  final roll = math.Random().nextDouble();
  final ground = bounds.height * 0.72;
  final difficulty = 1 + world.area.id * 0.045 + world.elapsed / 180;
  if (roll < 0.28) {
    final count = 4 + (math.Random().nextDouble() * 3).floor();
    for (int i = 0; i < count; i += 1) {
      spawnItem(
        world,
        bounds,
        xOffset: i * 43,
        yOffset: -math.sin((i / math.max(1, count - 1)) * math.pi) * 72,
      );
    }
  } else if (roll < 0.45) {
    final kinds = ['fence', 'hay', 'wind'];
    world.entities.add(
      Entity(
        type: 'obstacle',
        kind: kinds[world.area.id % kinds.length],
        x: bounds.width + 80,
        y: ground - 56,
        w: 48 + math.Random().nextDouble() * 18,
        h: 56,
        breakable: math.Random().nextDouble() < 0.3,
      ),
    );
    for (int i = 0; i < 3; i += 1) {
      spawnItem(
        world,
        bounds,
        item: i == 1 ? 'corn' : 'coin',
        xOffset: 30 + i * 42,
        yOffset: -88 - math.sin(i * math.pi / 2) * 35,
      );
    }
  } else if (roll < 0.62) {
    final type = world.area.enemy;
    final enemy = ENEMIES[type]!;
    world.entities.add(
      Entity(
        type: 'enemy',
        enemy: type,
        asset: enemy.asset,
        animation: enemy.animation,
        x: bounds.width + 90,
        y: enemy.flying
            ? ground - 120 - math.Random().nextDouble() * 100
            : ground - 60,
        w: enemy.size,
        h: enemy.size * 0.75,
        baseY: enemy.flying
            ? ground - 120 - math.Random().nextDouble() * 100
            : ground - 60,
        phase: math.Random().nextDouble() * 6,
        animClock: 0,
      ),
    );
  } else if (roll < 0.82) {
    final special = math.Random().nextDouble() < 0.28
        ? ['feather', 'cheese', 'key'][(math.Random().nextDouble() * 3).floor()]
        : 'coin';
    for (int i = 0; i < 5; i += 1) {
      spawnItem(
        world,
        bounds,
        item: i == 2 ? special : 'coin',
        xOffset: i * 40,
        yOffset: -35 - i * 22,
      );
    }
  } else if (roll < 0.9) {
    final powers = [
      'balloon',
      'wing',
      'rocket',
      'magnet',
      'eggshield',
      'electricegg',
    ];
    spawnItem(
      world,
      bounds,
      item: powers[(math.Random().nextDouble() * 6).floor()],
      yOffset: -70,
    );
  } else {
    spawnItem(world, bounds, item: 'heart', yOffset: -55);
  }
  world.spawnTimer = math.max(0.62, world.balance['spawnGap']! / difficulty);
}

void spawnSafeCoins(World world, Size bounds) {
  for (int i = 0; i < 5; i += 1) {
    spawnItem(
      world,
      bounds,
      xOffset: i * 42,
      yOffset: -math.sin(i / 4 * math.pi) * 48,
    );
  }
  world.spawnTimer = 1.35;
}

void beginTakeoff(World world, Size bounds) {
  world.player.flightTimer = math.max(
    world.player.flightTimer,
    world.area.id >= 7 ? 14 : 9,
  );
  world.player.vy = -310;
  world.player.onGround = false;
  world.player.energy = math.min(
    world.player.maxEnergy,
    world.player.energy + 24,
  );
  world.effects.add(
    Effect(
      type: 'takeoff',
      x: world.player.x,
      y: world.player.y,
      age: 0,
      duration: 0.6,
    ),
  );
  for (int i = 0; i < 6; i += 1) {
    spawnItem(
      world,
      bounds,
      item: i == 2 ? 'feather' : 'coin',
      xOffset: i * 44,
      yOffset: -60 - i * 24,
    );
  }
  world.nextTakeoff += world.area.id >= 7 ? 170 : 235;
  emit(world, 'takeoff');
}

void beginBoss(World world, Size bounds) {
  final info = BOSSES[world.area.boss]!;
  final ground = bounds.height * 0.72;
  world.boss = Boss(
    id: world.area.boss!,
    name: info.name,
    asset: info.asset,
    animation: info.animation,
    windup: info.windup,
    strike: info.strike,
    grounded: info.grounded,
    sourceFacing: info.sourceFacing,
    x: -180,
    y: info.grounded ? ground : world.player.y,
    stamina: 100,
    attackTimer: 1.4,
    strikeTimer: 0,
    elapsed: 0,
    animClock: 0,
    chaseAnimation: info.animation,
    hitThisAttack: false,
  );
  if (!info.grounded)
    world.player.flightTimer = math.max(world.player.flightTimer, 35);
  world.player.energy = world.player.maxEnergy;
  emit(world, 'bossStart', {'name': info.name});
  world.effects.add(
    Effect(
      type: 'warning',
      x: bounds.width * 0.75,
      y: bounds.height * 0.3,
      age: 0,
      duration: 1.2,
    ),
  );
}

void updateBoss(World world, double dt, Size bounds) {
  final boss = world.boss;
  if (boss == null) return;
  boss.elapsed += dt;
  boss.animClock += dt;
  boss.attackTimer -= dt;
  boss.strikeTimer = math.max(0, boss.strikeTimer - dt);
  final ground = bounds.height * 0.72;
  final targetX = math.max(
    -15,
    world.player.x - (boss.strikeTimer > 0 ? 58 : 105),
  );
  final targetY = boss.grounded ? ground : world.player.y + 8;
  boss.x += (targetX - boss.x) * math.min(1, dt * 1.9);
  boss.y += (targetY - boss.y) * math.min(1, dt * 2.8);
  if (boss.strikeTimer > 0) {
    boss.animation = boss.strike;
  } else if (boss.attackTimer < 0.72) {
    boss.animation = boss.windup;
  } else {
    boss.animation = boss.chaseAnimation;
  }
  if (boss.attackTimer <= 0) {
    if (!boss.hitThisAttack) boss.stamina = math.max(0, boss.stamina - 9);
    boss.hitThisAttack = false;
    boss.attackTimer = 2.4;
    boss.strikeTimer = 0.48;
    boss.animation = boss.strike;
    final y = clamp(
      world.player.y - 25 + (math.Random().nextDouble() - 0.5) * 90,
      70,
      bounds.height * 0.72 - 45,
    ).toDouble();
    final warningX = math.max(0.0, boss.x + 55);
    world.entities.add(
      Entity(
        type: 'warning',
        x: warningX,
        y: y,
        w: bounds.width - warningX,
        h: 22.0,
        age: 0,
        targetY: y,
      ),
    );
    emit(world, 'bossAttack');
  }
  if (boss.stamina <= 0) {
    emit(world, 'bossDefeat', {'name': boss.name});
    world.boss = null;
    world.bossDone = true;
    world.effects.add(
      Effect(
        type: 'portal',
        x: bounds.width * 0.72,
        y: bounds.height * 0.38,
        age: 0,
        duration: 0.7,
      ),
    );
    emit(world, 'portal');
    changeArea(world);
  }
}

Rect playerBox(World world) =>
    Rect.fromLTWH(world.player.x - 23, world.player.y - 48, 46, 44);

void collect(World world, Entity entity) {
  final player = world.player;
  final currencyBoost = world.skinId == 'golden' ? 1.2 : 1;
  switch (entity.item) {
    case 'coin':
      world.collected.coins += (world.rules['coin']!).ceil();
      world.score +=
          (10 *
                  world.multiplier *
                  (player.scoreBoost > 0
                      ? (world.skinId == 'golden' ? 3 : 2)
                      : 1))
              .round();
      world.combo += 1;
      emit(world, 'coin', {'combo': world.combo});
      break;
    case 'corn':
      world.collected.corn += currencyBoost.ceil();
      world.score += 25;
      emit(world, 'pickup', {'item': 'corn'});
      break;
    case 'feather':
      world.collected.feathers += currencyBoost.ceil();
      player.energy = math.min(player.maxEnergy, player.energy + 28);
      world.score += 40;
      emit(world, 'feather');
      break;
    case 'cheese':
      world.collected.cheese += currencyBoost.ceil();
      world.score += 75;
      emit(world, 'pickup', {'item': 'cheese'});
      break;
    case 'key':
      world.collected.keys += 1;
      world.score += 100;
      emit(world, 'pickup', {'item': 'key'});
      break;
    case 'heart':
      player.hp = math.min(3, player.hp + 1);
      emit(world, 'pickup', {'item': 'heart'});
      break;
    case 'balloon':
      player.flightTimer = math.max(player.flightTimer, 8);
      player.vy = -120;
      emit(world, 'power', {'item': 'balloon'});
      break;
    case 'wing':
      player.infiniteEnergy = 7;
      emit(world, 'power', {'item': 'wing'});
      break;
    case 'rocket':
      player.rocketTimer = 5;
      player.destroyTimer = 5;
      player.flightTimer = math.max(player.flightTimer, 5);
      emit(world, 'power', {'item': 'rocket'});
      break;
    case 'magnet':
      player.magnetTimer = 8;
      emit(world, 'power', {'item': 'magnet'});
      break;
    case 'eggshield':
      player.shield = true;
      emit(world, 'power', {'item': 'eggshield'});
      break;
    case 'electricegg':
      world.entities = world.entities.where((e) => e.type != 'enemy').toList();
      world.score += 120;
      emit(world, 'power', {'item': 'electricegg'});
      break;
    default:
      break;
  }
  world.multiplier =
      1 + math.min(4, (world.combo / 8).floor() * 0.5 * world.rules['combo']!);
  world.effects.add(
    Effect(
      type: entity.item == 'feather' ? 'featherpickup' : 'coinburst',
      x: entity.x + entity.w / 2,
      y: entity.y + entity.h / 2,
      age: 0,
      duration: 0.45,
    ),
  );
}

void hurt(World world, String threat) {
  final player = world.player;
  if (player.invulnerable > 0 ||
      player.dashTimer > 0 ||
      player.destroyTimer > 0)
    return;
  if (player.shield) {
    player.shield = false;
    player.invulnerable = 0.7;
    world.effects.add(
      Effect(
        type: 'shieldbreak',
        x: player.x,
        y: player.y - 28,
        age: 0,
        duration: 0.5,
      ),
    );
    emit(world, 'shieldBreak');
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
  if (world.boss != null) world.boss!.hitThisAttack = true;
  emit(world, 'hit', {'threat': threat});
  if (player.hp <= 0) endRun(world, false);
}

void endRun(World world, bool win) {
  world.over = true;
  world.win = win;
  world.started = false;
  emit(world, win ? 'runEnd' : 'gameOver', {
    'win': win,
    'threat': world.lastThreat.isEmpty ? 'Kehabisan tenaga' : world.lastThreat,
  });
}

void changeArea(World world) {
  if (world.area.id == AREAS.length && world.mode == 'story') {
    endRun(world, true);
    return;
  }
  if (world.mode == 'explore') {
    endRun(world, true);
    return;
  }
  final completedArea = world.area.id;
  final completedDistance = world.localDistance;
  final next = (world.areaIndex + 1) % AREAS.length;
  final area = AREAS[next];
  world.transitioning = true;
  emit(world, 'areaChange', {
    'area': area,
    'completedArea': completedArea,
    'completedDistance': completedDistance,
  });
}

String chooseAnimation(World world, InputState input) {
  final player = world.player;
  if (!world.started) return 'idle';
  if (player.skillTimer > 0) return 'skill';
  if (player.hurtTimer > 0) return 'hurt';
  if (player.landTimer > 0) return 'land';
  if (player.dashTimer > 0) return 'dash';
  if (!player.onGround && (player.flightTimer > 0 || world.area.id >= 7)) {
    return player.flapTimer > 0 || input.isHeld('up') || input.isHeld('jump')
        ? 'flap'
        : 'glide';
  }
  if (!player.onGround) return 'jump';
  return 'run';
}

void updateWorld(World world, double dt, InputState input, Size bounds) {
  if (world.paused || world.over || bounds.width == 0 || bounds.height == 0)
    return;
  final player = world.player;
  final ground = bounds.height * 0.72;
  if (player.y == 0 || player.y > bounds.height + 100) player.y = ground;
  player.animClock += dt;
  for (final effect in world.effects) {
    effect.age += dt;
  }
  world.effects = world.effects.where((e) => e.age < e.duration).toList();
  for (final p in world.particles) {
    p.age += dt;
    p.x += p.vx * dt;
    p.y += p.vy * dt;
    p.vy += 180 * dt;
  }
  world.particles = world.particles.where((p) => p.age < p.life).toList();
  if (!world.started) {
    player.anim = player.onGround ? 'run' : 'idle';
    return;
  }

  world.elapsed += dt;
  if (world.mode == 'time') {
    world.timeLeft -= dt;
    if (world.timeLeft <= 0) {
      world.timeLeft = 0;
      endRun(world, true);
      return;
    }
  }
  for (final key in [
    'dashTimer',
    'dashCooldown',
    'invulnerable',
    'hurtTimer',
    'landTimer',
    'flapTimer',
    'skillTimer',
    'skillCooldown',
    'infiniteEnergy',
    'scoreBoost',
    'destroyTimer',
    'rocketTimer',
    'magnetTimer',
  ]) {
    player.dynamicSet(key, math.max(0, (player.dynamicGet(key)) - dt));
  }
  if (player.slowTimer > 0)
    player.slowTimer = math.max(0, player.slowTimer - dt);
  if (player.flightTimer > 0)
    player.flightTimer = math.max(0, player.flightTimer - dt);
  world.shake = math.max(0, world.shake - dt);

  final direction =
      (input.isHeld('right') ? 1 : 0) - (input.isHeld('left') ? 1 : 0);
  final flightControl = !player.onGround ? world.rules['airControl']! : 1;
  player.vx += direction * 900 * flightControl * dt;
  player.vx *= math.pow(0.002, dt);
  player.x = clamp(
    player.x + player.vx * dt,
    bounds.width * 0.16,
    bounds.width * 0.5,
  );

  final flying = player.flightTimer > 0 || world.area.id >= 7;
  double gravity = world.balance['gravity']! * world.rules['gravity']!;
  if (world.area.id == 14) {
    gravity *= 0.12;
  } else if (world.area.id == 13) {
    gravity *= 0.35;
  } else if (flying) {
    gravity *= 0.42;
  }
  if (flying && input.isHeld('up') && player.energy > 0) {
    player.vy -= 560 * dt;
    if (player.infiniteEnergy <= 0)
      player.energy = math.max(0, player.energy - 18 * dt);
  }
  if (!player.onGround && input.isHeld('down')) player.vy += 620 * dt;
  player.vy += gravity * dt;
  player.vy = clamp(player.vy, -620, flying ? 360 : 780);
  player.y += player.vy * dt;
  final ceiling = math.max(60.0, ground - 240);
  if (player.y < ceiling) {
    player.y = ceiling;
    player.vy = math.max(40, player.vy);
  }
  if (player.y >= ground) {
    final wasAir = !player.onGround;
    player.y = ground;
    player.vy = 0;
    player.onGround = true;
    player.airJumps = 1;
    player.energy = math.min(player.maxEnergy, player.energy + 35 * dt);
    if (wasAir) {
      player.landTimer = 0.38;
      player.animClock = 0;
      emit(world, 'land');
    }
  } else {
    player.onGround = false;
  }

  final slow = player.slowTimer > 0 && player.slowTimer < 2 ? 0.72 : 1;
  final speed =
      world.balance['runSpeed']! *
      world.rules['speed']! *
      slow *
      (1 + math.min(0.55, world.elapsed / 150)) *
      (player.dashTimer > 0 ? 1.55 : 1) *
      (player.rocketTimer > 0 ? 1.35 : 1);
  final meters = speed * dt * 0.07;
  world.distance += meters;
  world.localDistance += meters;
  world.score +=
      meters *
      world.multiplier *
      (player.scoreBoost > 0 ? (world.skinId == 'golden' ? 3 : 2) : 1);
  world.cameraY = 0;

  if (!world.transitioning) {
    if (world.localDistance >= world.nextTakeoff) beginTakeoff(world, bounds);
    if (world.boss == null &&
        world.area.boss != null &&
        !world.bossDone &&
        world.localDistance >= BOSS_START_DISTANCE) {
      beginBoss(world, bounds);
    }
    if (world.area.boss == null && world.localDistance >= AREA_LENGTH) {
      world.effects.add(
        Effect(
          type: 'portal',
          x: bounds.width * 0.72,
          y: bounds.height * 0.38,
          age: 0,
          duration: 0.7,
        ),
      );
      emit(world, 'portal');
      changeArea(world);
      return;
    }
  }
  updateBoss(world, dt, bounds);

  world.spawnTimer -= dt;
  if (world.spawnTimer <= 0) {
    if (world.elapsed < 10) {
      spawnSafeCoins(world, bounds);
    } else {
      spawnPattern(world, bounds);
    }
  }

  final pBox = playerBox(world);
  for (final entity in world.entities) {
    if (entity.type != 'warning') entity.x -= speed * dt;
    entity.animClock = (entity.animClock ?? 0) + dt;
    if (entity.type == 'item') {
      entity.phase = (entity.phase ?? 0) + dt * 4;
      entity.drawY = entity.y + math.sin(entity.phase!) * 5;
      if (player.magnetTimer > 0 && (entity.x - player.x).abs() < 240) {
        entity.x += (player.x - entity.x) * dt * 7;
        entity.y += (player.y - 30 - entity.y) * dt * 7;
      }
    }
    if (entity.type == 'enemy' && ENEMIES[entity.enemy]!.flying) {
      entity.y =
          entity.baseY! + math.sin(entity.phase! + world.elapsed * 2.2) * 28;
    }
    if (entity.type == 'warning') {
      entity.age = (entity.age ?? 0) + dt;
      if (entity.age! > 0.85 &&
          entity.age! < 1.2 &&
          overlap(
            pBox,
            Rect.fromLTWH(entity.x, entity.y, entity.w, entity.h),
          )) {
        hurt(world, world.boss?.name ?? 'Serangan boss');
      }
      continue;
    }
    final eBox = Rect.fromLTWH(
      entity.x,
      entity.drawY ?? entity.y,
      entity.w,
      entity.h,
    );
    if (!overlap(pBox, eBox)) continue;
    if (entity.type == 'item') {
      collect(world, entity);
      entity.dead = true;
    } else if (entity.type == 'obstacle') {
      if (player.destroyTimer > 0 ||
          (player.dashTimer > 0 && entity.breakable)) {
        entity.dead = true;
        world.score += 35;
        emit(world, 'smash', {'x': entity.x, 'y': entity.y});
      } else {
        hurt(world, entity.kind ?? 'Rintangan');
      }
    } else if (entity.type == 'enemy') {
      if (player.destroyTimer > 0 || player.dashTimer > 0) {
        entity.dead = true;
        world.score += 60;
        emit(world, 'smash', {'x': entity.x, 'y': entity.y});
      } else {
        hurt(world, entity.enemy!);
      }
    }
  }
  world.entities = world.entities
      .where(
        (e) =>
            !e.dead &&
            e.x > -180 &&
            (e.type != 'warning' || (e.age ?? 0) < 1.3),
      )
      .toList();
  player.anim = chooseAnimation(world, input);
}

Map<String, dynamic> worldSnapshot(World world) {
  return {
    'areaId': world.area.id,
    'mode': world.mode,
    'skinId': world.skinId,
    'elapsed': world.elapsed,
    'timeLeft': world.timeLeft.isFinite ? world.timeLeft : null,
    'distance': world.distance,
    'localDistance': world.localDistance,
    'score': world.score,
    'combo': world.combo,
    'collected': {
      'coins': world.collected.coins,
      'corn': world.collected.corn,
      'feathers': world.collected.feathers,
      'cheese': world.collected.cheese,
      'keys': world.collected.keys,
    },
    'nextTakeoff': world.nextTakeoff,
    'player': {
      'x': world.player.x,
      'y': world.player.y,
      'vy': world.player.vy,
      'hp': world.player.hp,
      'energy': world.player.energy,
      'skillCooldown': world.player.skillCooldown,
    },
  };
}

extension PlayerExt on Player {
  double dynamicGet(String key) {
    switch (key) {
      case 'dashTimer':
        return dashTimer;
      case 'dashCooldown':
        return dashCooldown;
      case 'invulnerable':
        return invulnerable;
      case 'hurtTimer':
        return hurtTimer;
      case 'landTimer':
        return landTimer;
      case 'flapTimer':
        return flapTimer;
      case 'skillTimer':
        return skillTimer;
      case 'skillCooldown':
        return skillCooldown;
      case 'infiniteEnergy':
        return infiniteEnergy;
      case 'scoreBoost':
        return scoreBoost;
      case 'destroyTimer':
        return destroyTimer;
      case 'rocketTimer':
        return rocketTimer;
      case 'magnetTimer':
        return magnetTimer;
      default:
        return 0;
    }
  }

  void dynamicSet(String key, double value) {
    switch (key) {
      case 'dashTimer':
        dashTimer = value;
        break;
      case 'dashCooldown':
        dashCooldown = value;
        break;
      case 'invulnerable':
        invulnerable = value;
        break;
      case 'hurtTimer':
        hurtTimer = value;
        break;
      case 'landTimer':
        landTimer = value;
        break;
      case 'flapTimer':
        flapTimer = value;
        break;
      case 'skillTimer':
        skillTimer = value;
        break;
      case 'skillCooldown':
        skillCooldown = value;
        break;
      case 'infiniteEnergy':
        infiniteEnergy = value;
        break;
      case 'scoreBoost':
        scoreBoost = value;
        break;
      case 'destroyTimer':
        destroyTimer = value;
        break;
      case 'rocketTimer':
        rocketTimer = value;
        break;
      case 'magnetTimer':
        magnetTimer = value;
        break;
    }
  }
}

class Skin {
  const Skin({
    required this.id,
    required this.name,
    required this.passive,
    required this.power,
    required this.price,
    required this.color,
    this.extra = false,
  });
  final String id;
  final String name;
  final String passive;
  final String power;
  final int price;
  final String color;
  final bool extra;
}

class Area {
  const Area({
    required this.id,
    required this.chapter,
    required this.name,
    required this.emoji,
    required this.theme,
    required this.enemy,
    required this.feature,
    required this.palette,
    this.boss,
    this.length = 1000,
  });
  final int id;
  final String chapter;
  final String name;
  final String emoji;
  final String theme;
  final String enemy;
  final String feature;
  final List<String> palette;
  final String? boss;
  final double length;
}

class EnemyDef {
  const EnemyDef({
    required this.asset,
    required this.animation,
    required this.size,
    required this.flying,
  });
  final String asset;
  final String animation;
  final double size;
  final bool flying;
}

class BossDef {
  const BossDef({
    required this.name,
    required this.asset,
    required this.animation,
    required this.windup,
    required this.strike,
    required this.grounded,
    required this.sourceFacing,
  });
  final String name;
  final String asset;
  final String animation;
  final String windup;
  final String strike;
  final bool grounded;
  final String sourceFacing;
}

const List<Skin> SKINS = [
  Skin(id: 'classic', name: 'Classic', passive: 'Seimbang', power: 'Chicken Dash', price: 0, color: '#f4c84b'),
  Skin(id: 'cocoa', name: 'Cocoa', passive: 'Tahan 1 hit', power: 'Heavy Peck', price: 80, color: '#8b593d'),
  Skin(id: 'violet', name: 'Violet', passive: 'Kontrol udara +20%', power: 'Blink', price: 130, color: '#9d73d8'),
  Skin(id: 'mint', name: 'Mint', passive: 'Energi +30%', power: 'Wind Glide', price: 180, color: '#74c9a7'),
  Skin(id: 'sunset', name: 'Sunset', passive: 'Combo +15%', power: 'Sunset Rush', price: 240, color: '#ed7b4d'),
  Skin(id: 'astronaut', name: 'Astronaut', passive: 'Gravitasi -20%', power: 'Moon Flight', price: 320, color: '#dbe8ef'),
  Skin(id: 'pirate', name: 'Pirate', passive: 'Coin +25%', power: 'Treasure Magnet', price: 410, color: '#d8bb81'),
  Skin(id: 'wizard', name: 'Wizard', passive: 'Durasi power +20%', power: 'Magic Feather', price: 520, color: '#7470b9'),
  Skin(id: 'neon', name: 'Neon', passive: 'Speed +10%', power: 'Overdrive', price: 680, color: '#37d9df'),
  Skin(id: 'golden', name: 'Golden', passive: 'Currency +20%', power: 'Golden Storm', price: 900, color: '#f2b935'),
];

const List<Area> AREAS = [
  Area(id: 1, chapter: 'THE FARM', name: 'Chicken Farm', emoji: '🌾', theme: 'farm', enemy: 'bird', feature: 'Fence • bucket • hay', palette: ['#85c9e8', '#f0c75b']),
  Area(id: 2, chapter: 'THE FARM', name: 'Countryside', emoji: '🚜', theme: 'farm', enemy: 'dog', feature: 'Mud • tractor • scarecrow', palette: ['#8bc8d9', '#9eb45a']),
  Area(id: 3, chapter: 'THE FARM', name: 'Village', emoji: '🏘️', theme: 'farm', enemy: 'dog', boss: 'giantDog', feature: 'Rooftop • Giant Dog', palette: ['#7fbee0', '#c97854']),
  Area(id: 4, chapter: 'THE CITY', name: 'Small City', emoji: '🏙️', theme: 'city', enemy: 'bird', feature: 'Vent • moving roof', palette: ['#78b9cf', '#6d8491']),
  Area(id: 5, chapter: 'THE CITY', name: 'Neon City', emoji: '🌆', theme: 'city', enemy: 'drone', feature: 'Drone • laser sign', palette: ['#27345e', '#e25b9d']),
  Area(id: 6, chapter: 'THE CITY', name: 'Metro City', emoji: '🚇', theme: 'city', enemy: 'drone', boss: 'helicopter', feature: 'Train • Helicopter', palette: ['#394b67', '#e5a84b']),
  Area(id: 7, chapter: 'THE SKY', name: 'Mountain', emoji: '⛰️', theme: 'sky', enemy: 'eagle', feature: 'Updraft • cliff', palette: ['#72c4e4', '#6f9f8a']),
  Area(id: 8, chapter: 'THE SKY', name: 'Cloud Kingdom', emoji: '☁️', theme: 'sky', enemy: 'bird', feature: 'Cloud • balloon', palette: ['#77ccea', '#f4eed7']),
  Area(id: 9, chapter: 'THE SKY', name: 'Rainbow Sky', emoji: '🌈', theme: 'sky', enemy: 'eagle', boss: 'skyEagle', feature: 'Rainbow • Sky Eagle', palette: ['#7dcae8', '#e99182']),
  Area(id: 10, chapter: 'THE STORM', name: 'Rain City', emoji: '🌧️', theme: 'storm', enemy: 'bat', feature: 'Slippery • rain', palette: ['#526b80', '#d7a65a']),
  Area(id: 11, chapter: 'THE STORM', name: 'Storm', emoji: '🌪️', theme: 'storm', enemy: 'bat', feature: 'Crosswind • debris', palette: ['#3e526b', '#8d7199']),
  Area(id: 12, chapter: 'THE STORM', name: 'Thunder Sky', emoji: '⚡', theme: 'storm', enemy: 'drone', boss: 'stormBeast', feature: 'Lightning • Storm Beast', palette: ['#35435f', '#e7b942']),
  Area(id: 13, chapter: 'BEYOND', name: 'Moon', emoji: '🌙', theme: 'beyond', enemy: 'bat', feature: 'Low gravity • crater', palette: ['#263c67', '#c7d1d9']),
  Area(id: 14, chapter: 'BEYOND', name: 'Space', emoji: '🪐', theme: 'beyond', enemy: 'drone', feature: 'Zero gravity • asteroid', palette: ['#181b40', '#9369b3']),
  Area(id: 15, chapter: 'BEYOND', name: 'Sun Kingdom', emoji: '☀️', theme: 'beyond', enemy: 'eagle', boss: 'skyDragon', feature: 'Solar ring • Sky Dragon', palette: ['#79cde2', '#f2bd48']),
  Area(id: 16, chapter: 'WILD FRONTIER', name: 'Crystal Canyon', emoji: '💎', theme: 'beyond', enemy: 'bat', feature: 'Crystal arch • canyon wind', palette: ['#6fcbd5', '#b678b9']),
  Area(id: 17, chapter: 'WILD FRONTIER', name: 'Floating Jungle', emoji: '🌿', theme: 'sky', enemy: 'bee', feature: 'Vines • floating falls', palette: ['#77cbd2', '#4f9f72']),
  Area(id: 18, chapter: 'WILD FRONTIER', name: 'Volcano Winds', emoji: '🌋', theme: 'storm', enemy: 'eagle', boss: 'firePhoenix', feature: 'Hot wind • Fire Phoenix', palette: ['#5d5865', '#ec7548']),
  Area(id: 19, chapter: 'MACHINE WORLD', name: 'Ocean Cliffs', emoji: '🌊', theme: 'sky', enemy: 'bird', feature: 'Sea gust • cliff rings', palette: ['#62c7dc', '#e6d69b']),
  Area(id: 20, chapter: 'MACHINE WORLD', name: 'Clockwork Harbor', emoji: '⚙️', theme: 'city', enemy: 'drone', feature: 'Brass crane • steam', palette: ['#75b9c5', '#bd7b43']),
  Area(id: 21, chapter: 'MACHINE WORLD', name: 'Gearstorm Factory', emoji: '🏭', theme: 'city', enemy: 'drone', boss: 'ironRooster', feature: 'Gear lane • Iron Rooster', palette: ['#455c73', '#c37b3d']),
  Area(id: 22, chapter: 'SKY LEGENDS', name: 'Ancient Ruins', emoji: '🏛️', theme: 'farm', enemy: 'dog', feature: 'Stone arch • petals', palette: ['#82c6d8', '#b8a56d']),
  Area(id: 23, chapter: 'SKY LEGENDS', name: 'Dream Forest', emoji: '🍄', theme: 'sky', enemy: 'bat', feature: 'Dream mist • giant trees', palette: ['#5c6996', '#9a6fb0']),
  Area(id: 24, chapter: 'SKY LEGENDS', name: 'Aurora Realm', emoji: '❄️', theme: 'storm', enemy: 'eagle', boss: 'frostOwl', feature: 'Ice gust • Frost Owl', palette: ['#466f91', '#80d4c3']),
  Area(id: 25, chapter: 'FINAL HORIZON', name: 'Star Nest', emoji: '🌟', theme: 'beyond', enemy: 'eagle', boss: 'celestialRoc', feature: 'Star rings • Celestial Roc', palette: ['#242a5c', '#efb84c']),
];

const Map<String, EnemyDef> ENEMIES = {
  'bird': EnemyDef(asset: 'ENEMY_BIRD', animation: 'flap', size: 62, flying: true),
  'dog': EnemyDef(asset: 'ENEMY_DOG', animation: 'run', size: 76, flying: false),
  'eagle': EnemyDef(asset: 'ENEMY_EAGLE', animation: 'flap', size: 82, flying: true),
  'bee': EnemyDef(asset: 'ENEMY_BEE', animation: 'hover', size: 54, flying: true),
  'bat': EnemyDef(asset: 'ENEMY_BAT', animation: 'flap', size: 62, flying: true),
  'drone': EnemyDef(asset: 'ENEMY_DRONE', animation: 'hover', size: 68, flying: true),
};

const Map<String, BossDef> BOSSES = {
  'giantDog': BossDef(name: 'GIANT DOG', asset: 'BOSS_GIANT_DOG', animation: 'run', windup: 'leap', strike: 'bite', grounded: true, sourceFacing: 'left'),
  'helicopter': BossDef(name: 'HELICOPTER', asset: 'BOSS_HELICOPTER', animation: 'patrol', windup: 'aim', strike: 'fire', grounded: false, sourceFacing: 'left'),
  'skyEagle': BossDef(name: 'SKY EAGLE', asset: 'BOSS_SKY_EAGLE', animation: 'cruise', windup: 'windup', strike: 'dive', grounded: false, sourceFacing: 'left'),
  'stormBeast': BossDef(name: 'STORM BEAST', asset: 'BOSS_STORM_BEAST', animation: 'swirl', windup: 'charge', strike: 'strike', grounded: false, sourceFacing: 'left'),
  'skyDragon': BossDef(name: 'SKY DRAGON', asset: 'BOSS_SKY_DRAGON', animation: 'fly', windup: 'windup', strike: 'breath', grounded: false, sourceFacing: 'left'),
  'firePhoenix': BossDef(name: 'FIRE PHOENIX', asset: 'BOSS_FIRE_PHOENIX', animation: 'chase', windup: 'windup', strike: 'strike', grounded: false, sourceFacing: 'right'),
  'ironRooster': BossDef(name: 'IRON ROOSTER', asset: 'BOSS_IRON_ROOSTER', animation: 'chase', windup: 'windup', strike: 'strike', grounded: true, sourceFacing: 'right'),
  'frostOwl': BossDef(name: 'FROST OWL', asset: 'BOSS_FROST_OWL', animation: 'chase', windup: 'windup', strike: 'strike', grounded: false, sourceFacing: 'right'),
  'celestialRoc': BossDef(name: 'CELESTIAL ROC', asset: 'BOSS_CELESTIAL_ROC', animation: 'chase', windup: 'windup', strike: 'strike', grounded: false, sourceFacing: 'right'),
};

const List<String> ITEM_NAMES = [
  'coin', 'corn', 'feather', 'cheese', 'key', 'heart', 'balloon', 'wing', 'rocket', 'magnet', 'eggshield', 'electricegg'
];

String skinAsset(String id, [bool extra = false]) {
  return 'CHICKEN_${id.toUpperCase()}_${extra ? "EXTRA" : "MAIN"}';
}

String backgroundAsset(int areaId) {
  return 'BG_AREA_${areaId.toString().padLeft(2, '0')}';
}

String tileAsset(String theme) {
  const map = {
    'farm': 'TILES_FARM',
    'city': 'TILES_CITY',
    'sky': 'TILES_SKY',
    'storm': 'TILES_STORM',
    'beyond': 'TILES_BEYOND',
  };
  return map[theme]!;
}

class CoinHistoryEntry {
  CoinHistoryEntry({required this.at, required this.delta, required this.reason, required this.balance});
  final int at;
  final int delta;
  final String reason;
  final int balance;
}

class Progress {
  Progress({
    this.version = 1,
    this.bestScore = 0,
    this.bestDistance = 0,
    this.coins = 0,
    this.lifetimeCoins = 0,
    List<CoinHistoryEntry>? coinHistory,
    this.corn = 0,
    this.feathers = 0,
    this.cheese = 0,
    this.keys = 0,
    this.unlockedArea = 1,
    List<String>? unlockedSkins,
    this.selectedSkin = 'classic',
    Map<int, int>? areaBests,
    Map<String, bool>? skins,
    this.activeRun,
  })  : coinHistory = coinHistory ?? [],
        unlockedSkins = unlockedSkins ?? ['classic'],
        areaBests = areaBests ?? {},
        skins = skins ?? {};

  int version;
  int bestScore;
  int bestDistance;
  int coins;
  int lifetimeCoins;
  List<CoinHistoryEntry> coinHistory;
  int corn;
  int feathers;
  int cheese;
  int keys;
  int unlockedArea;
  List<String> unlockedSkins;
  String selectedSkin;
  Map<int, int> areaBests;
  Map<String, bool> skins;
  Map<String, dynamic>? activeRun;

  String get activeSkin => selectedSkin;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'version': version,
        'bestScore': bestScore,
        'bestDistance': bestDistance,
        'coins': coins,
        'lifetimeCoins': lifetimeCoins,
        'coinHistory': coinHistory
            .map((e) => <String, dynamic>{
                  'at': e.at,
                  'delta': e.delta,
                  'reason': e.reason,
                  'balance': e.balance,
                })
            .toList(),
        'corn': corn,
        'feathers': feathers,
        'cheese': cheese,
        'keys': keys,
        'unlockedArea': unlockedArea,
        'unlockedSkins': unlockedSkins,
        'selectedSkin': selectedSkin,
        'areaBests': areaBests,
        'skins': skins,
        'activeRun': activeRun,
      };
}

Progress defaultProgress() => Progress(
  unlockedSkins: ['classic'],
  unlockedArea: 1,
  skins: <String, bool>{'classic': true},
);

Skin findSkin(String id) => SKINS.firstWhere((s) => s.id == id, orElse: () => SKINS[0]);

Map<String, double> balanceFor(Progress p, int areaId) => defaultBalance();

Progress sanitizeProgress(dynamic saved) {
  if (saved == null) return defaultProgress();
  if (saved is Progress) return saved;
  if (saved is! Map) return defaultProgress();
  final s = Map<String, dynamic>.from(saved);
  if (s['version'] != 1) return defaultProgress();
  final numOr = (dynamic v, [int fallback = 0]) {
    if (v is! num) return fallback;
    return v.isFinite ? v.toDouble().clamp(0, 1e15).toInt() : fallback;
  };
  final Map<int, int> areaBests = {};
  if (s['areaBests'] is Map) {
    (s['areaBests'] as Map).forEach((k, v) => areaBests[int.parse(k.toString())] = numOr(v));
  }
  final unlockedSkins = s['unlockedSkins'] is List
      ? (s['unlockedSkins'] as List).where((id) => SKINS.any((sk) => sk.id == id)).cast<String>().toList()
      : ['classic'];
  final selectedSkin = SKINS.any((sk) => sk.id == s['selectedSkin']) ? s['selectedSkin'] : 'classic';
  final Map<String, bool> skins = {};
  if (s['skins'] is Map) {
    (s['skins'] as Map).forEach((k, v) {
      if (SKINS.any((sk) => sk.id == k)) skins[k.toString()] = v == true;
    });
  }
  final coinHistory = s['coinHistory'] is List
      ? (s['coinHistory'] as List)
          .where((e) => e is Map && e['delta'] is num)
          .map((e) => CoinHistoryEntry(
                at: numOr(e['at']),
                delta: (e['delta'] as num).toInt(),
                reason: (e['reason']?.toString() ?? 'Run').substring(0, 48),
                balance: numOr(e['balance']),
              ))
          .toList()
          .sublist(0, 20)
      : <CoinHistoryEntry>[];
  return Progress(
    bestScore: numOr(s['bestScore']),
    bestDistance: numOr(s['bestDistance']),
    coins: numOr(s['coins']),
    lifetimeCoins: numOr(s['lifetimeCoins'], numOr(s['coins'])),
    coinHistory: coinHistory,
    corn: numOr(s['corn']),
    feathers: numOr(s['feathers']),
    cheese: numOr(s['cheese']),
    keys: numOr(s['keys']),
    unlockedArea: (s['unlockedArea'] as int?) ?? 1,
    unlockedSkins: unlockedSkins,
    selectedSkin: selectedSkin,
    areaBests: areaBests,
    skins: skins,
    activeRun: s['activeRun'] is Map ? Map<String, dynamic>.from(s['activeRun']) : null,
  );
}

Map<String, double> defaultBalance() => {
      'runSpeed': 245.0,
      'gravity': 1650.0,
      'jumpForce': 610.0,
      'flapForce': 340.0,
      'spawnGap': 1.18,
      'baseSpeed': 245.0,
      'groundSpeed': 245.0,
      'effectsIntensity': 1.0,
      'musicVolume': 0.18,
    };

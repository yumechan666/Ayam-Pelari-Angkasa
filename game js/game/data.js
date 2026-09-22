export const SKINS = [
  { id: "classic", name: "Classic", passive: "Seimbang", power: "Chicken Dash", price: 0, color: "#f4c84b" },
  { id: "cocoa", name: "Cocoa", passive: "Tahan 1 hit", power: "Heavy Peck", price: 80, color: "#8b593d" },
  { id: "violet", name: "Violet", passive: "Kontrol udara +20%", power: "Blink", price: 130, color: "#9d73d8" },
  { id: "mint", name: "Mint", passive: "Energi +30%", power: "Wind Glide", price: 180, color: "#74c9a7" },
  { id: "sunset", name: "Sunset", passive: "Combo +15%", power: "Sunset Rush", price: 240, color: "#ed7b4d" },
  { id: "astronaut", name: "Astronaut", passive: "Gravitasi -20%", power: "Moon Flight", price: 320, color: "#dbe8ef" },
  { id: "pirate", name: "Pirate", passive: "Coin +25%", power: "Treasure Magnet", price: 410, color: "#d8bb81" },
  { id: "wizard", name: "Wizard", passive: "Durasi power +20%", power: "Magic Feather", price: 520, color: "#7470b9" },
  { id: "neon", name: "Neon", passive: "Speed +10%", power: "Overdrive", price: 680, color: "#37d9df" },
  { id: "golden", name: "Golden", passive: "Currency +20%", power: "Golden Storm", price: 900, color: "#f2b935" },
];

export const AREAS = [
  { id: 1, chapter: "THE FARM", name: "Chicken Farm", emoji: "🌾", theme: "farm", enemy: "bird", feature: "Fence • bucket • hay", palette: ["#85c9e8", "#f0c75b"] },
  { id: 2, chapter: "THE FARM", name: "Countryside", emoji: "🚜", theme: "farm", enemy: "dog", feature: "Mud • tractor • scarecrow", palette: ["#8bc8d9", "#9eb45a"] },
  { id: 3, chapter: "THE FARM", name: "Village", emoji: "🏘️", theme: "farm", enemy: "dog", boss: "giantDog", feature: "Rooftop • Giant Dog", palette: ["#7fbee0", "#c97854"] },
  { id: 4, chapter: "THE CITY", name: "Small City", emoji: "🏙️", theme: "city", enemy: "bird", feature: "Vent • moving roof", palette: ["#78b9cf", "#6d8491"] },
  { id: 5, chapter: "THE CITY", name: "Neon City", emoji: "🌆", theme: "city", enemy: "drone", feature: "Drone • laser sign", palette: ["#27345e", "#e25b9d"] },
  { id: 6, chapter: "THE CITY", name: "Metro City", emoji: "🚇", theme: "city", enemy: "drone", boss: "helicopter", feature: "Train • Helicopter", palette: ["#394b67", "#e5a84b"] },
  { id: 7, chapter: "THE SKY", name: "Mountain", emoji: "⛰️", theme: "sky", enemy: "eagle", feature: "Updraft • cliff", palette: ["#72c4e4", "#6f9f8a"] },
  { id: 8, chapter: "THE SKY", name: "Cloud Kingdom", emoji: "☁️", theme: "sky", enemy: "bird", feature: "Cloud • balloon", palette: ["#77ccea", "#f4eed7"] },
  { id: 9, chapter: "THE SKY", name: "Rainbow Sky", emoji: "🌈", theme: "sky", enemy: "eagle", boss: "skyEagle", feature: "Rainbow • Sky Eagle", palette: ["#7dcae8", "#e99182"] },
  { id: 10, chapter: "THE STORM", name: "Rain City", emoji: "🌧️", theme: "storm", enemy: "bat", feature: "Slippery • rain", palette: ["#526b80", "#d7a65a"] },
  { id: 11, chapter: "THE STORM", name: "Storm", emoji: "🌪️", theme: "storm", enemy: "bat", feature: "Crosswind • debris", palette: ["#3e526b", "#8d7199"] },
  { id: 12, chapter: "THE STORM", name: "Thunder Sky", emoji: "⚡", theme: "storm", enemy: "drone", boss: "stormBeast", feature: "Lightning • Storm Beast", palette: ["#35435f", "#e7b942"] },
  { id: 13, chapter: "BEYOND", name: "Moon", emoji: "🌙", theme: "beyond", enemy: "bat", feature: "Low gravity • crater", palette: ["#263c67", "#c7d1d9"] },
  { id: 14, chapter: "BEYOND", name: "Space", emoji: "🪐", theme: "beyond", enemy: "drone", feature: "Zero gravity • asteroid", palette: ["#181b40", "#9369b3"] },
  { id: 15, chapter: "BEYOND", name: "Sun Kingdom", emoji: "☀️", theme: "beyond", enemy: "eagle", boss: "skyDragon", feature: "Solar ring • Sky Dragon", palette: ["#79cde2", "#f2bd48"] },
  { id: 16, chapter: "WILD FRONTIER", name: "Crystal Canyon", emoji: "💎", theme: "beyond", enemy: "bat", feature: "Crystal arch • canyon wind", palette: ["#6fcbd5", "#b678b9"] },
  { id: 17, chapter: "WILD FRONTIER", name: "Floating Jungle", emoji: "🌿", theme: "sky", enemy: "bee", feature: "Vines • floating falls", palette: ["#77cbd2", "#4f9f72"] },
  { id: 18, chapter: "WILD FRONTIER", name: "Volcano Winds", emoji: "🌋", theme: "storm", enemy: "eagle", boss: "firePhoenix", feature: "Hot wind • Fire Phoenix", palette: ["#5d5865", "#ec7548"] },
  { id: 19, chapter: "MACHINE WORLD", name: "Ocean Cliffs", emoji: "🌊", theme: "sky", enemy: "bird", feature: "Sea gust • cliff rings", palette: ["#62c7dc", "#e6d69b"] },
  { id: 20, chapter: "MACHINE WORLD", name: "Clockwork Harbor", emoji: "⚙️", theme: "city", enemy: "drone", feature: "Brass crane • steam", palette: ["#75b9c5", "#bd7b43"] },
  { id: 21, chapter: "MACHINE WORLD", name: "Gearstorm Factory", emoji: "🏭", theme: "city", enemy: "drone", boss: "ironRooster", feature: "Gear lane • Iron Rooster", palette: ["#455c73", "#c37b3d"] },
  { id: 22, chapter: "SKY LEGENDS", name: "Ancient Ruins", emoji: "🏛️", theme: "farm", enemy: "dog", feature: "Stone arch • petals", palette: ["#82c6d8", "#b8a56d"] },
  { id: 23, chapter: "SKY LEGENDS", name: "Dream Forest", emoji: "🍄", theme: "sky", enemy: "bat", feature: "Dream mist • giant trees", palette: ["#5c6996", "#9a6fb0"] },
  { id: 24, chapter: "SKY LEGENDS", name: "Aurora Realm", emoji: "❄️", theme: "storm", enemy: "eagle", boss: "frostOwl", feature: "Ice gust • Frost Owl", palette: ["#466f91", "#80d4c3"] },
  { id: 25, chapter: "FINAL HORIZON", name: "Star Nest", emoji: "🌟", theme: "beyond", enemy: "eagle", boss: "celestialRoc", feature: "Star rings • Celestial Roc", palette: ["#242a5c", "#efb84c"] },
];

export const ENEMIES = {
  bird: { asset: "ENEMY_BIRD", animation: "flap", size: 62, flying: true },
  dog: { asset: "ENEMY_DOG", animation: "run", size: 76, flying: false },
  eagle: { asset: "ENEMY_EAGLE", animation: "flap", size: 82, flying: true },
  bee: { asset: "ENEMY_BEE", animation: "hover", size: 54, flying: true },
  bat: { asset: "ENEMY_BAT", animation: "flap", size: 62, flying: true },
  drone: { asset: "ENEMY_DRONE", animation: "hover", size: 68, flying: true },
};

export const BOSSES = {
  giantDog: { name: "GIANT DOG", asset: "BOSS_GIANT_DOG", animation: "run", windup: "leap", strike: "bite", grounded: true, sourceFacing: "left" },
  helicopter: { name: "HELICOPTER", asset: "BOSS_HELICOPTER", animation: "patrol", windup: "aim", strike: "fire", grounded: false, sourceFacing: "left" },
  skyEagle: { name: "SKY EAGLE", asset: "BOSS_SKY_EAGLE", animation: "cruise", windup: "windup", strike: "dive", grounded: false, sourceFacing: "left" },
  stormBeast: { name: "STORM BEAST", asset: "BOSS_STORM_BEAST", animation: "swirl", windup: "charge", strike: "strike", grounded: false, sourceFacing: "left" },
  skyDragon: { name: "SKY DRAGON", asset: "BOSS_SKY_DRAGON", animation: "fly", windup: "windup", strike: "breath", grounded: false, sourceFacing: "left" },
  firePhoenix: { name: "FIRE PHOENIX", asset: "BOSS_FIRE_PHOENIX", animation: "chase", windup: "windup", strike: "strike", grounded: false, sourceFacing: "right" },
  ironRooster: { name: "IRON ROOSTER", asset: "BOSS_IRON_ROOSTER", animation: "chase", windup: "windup", strike: "strike", grounded: true, sourceFacing: "right" },
  frostOwl: { name: "FROST OWL", asset: "BOSS_FROST_OWL", animation: "chase", windup: "windup", strike: "strike", grounded: false, sourceFacing: "right" },
  celestialRoc: { name: "CELESTIAL ROC", asset: "BOSS_CELESTIAL_ROC", animation: "chase", windup: "windup", strike: "strike", grounded: false, sourceFacing: "right" },
};

export const ITEM_NAMES = ["coin", "corn", "feather", "cheese", "key", "heart", "balloon", "wing", "rocket", "magnet", "eggshield", "electricegg"];

export function skinAsset(id, extra = false) {
  return `CHICKEN_${id.toUpperCase()}_${extra ? "EXTRA" : "MAIN"}`;
}

export function backgroundAsset(areaId) {
  return `BG_AREA_${String(areaId).padStart(2, "0")}`;
}

export function tileAsset(theme) {
  return { farm: "TILES_FARM", city: "TILES_CITY", sky: "TILES_SKY", storm: "TILES_STORM", beyond: "TILES_BEYOND" }[theme];
}

export function defaultProgress() {
  return {
    version: 1,
    bestScore: 0,
    bestDistance: 0,
    coins: 0,
    lifetimeCoins: 0,
    coinHistory: [],
    corn: 0,
    feathers: 0,
    cheese: 0,
    keys: 0,
    unlockedArea: 1,
    unlockedSkins: ["classic"],
    selectedSkin: "classic",
    areaBests: {},
    activeRun: null,
  };
}

export function sanitizeProgress(saved) {
  const base = defaultProgress();
  if (!saved || saved.version !== 1) return base;
  const number = (value, fallback = 0) => Number.isFinite(value) ? Math.max(0, value) : fallback;
  return {
    ...base,
    ...saved,
    bestScore: number(saved.bestScore),
    bestDistance: number(saved.bestDistance),
    coins: number(saved.coins),
    lifetimeCoins: number(saved.lifetimeCoins, number(saved.coins)),
    coinHistory: Array.isArray(saved.coinHistory)
      ? saved.coinHistory.slice(-20).filter((entry) => entry && Number.isFinite(entry.delta)).map((entry) => ({
        at: number(entry.at),
        delta: Math.trunc(entry.delta),
        reason: String(entry.reason || "Run" ).slice(0, 48),
        balance: number(entry.balance),
      }))
      : [],
    corn: number(saved.corn),
    feathers: number(saved.feathers),
    cheese: number(saved.cheese),
    keys: number(saved.keys),
    unlockedArea: Math.min(AREAS.length, Math.max(1, Math.floor(number(saved.unlockedArea, 1)))),
    unlockedSkins: Array.isArray(saved.unlockedSkins) ? saved.unlockedSkins.filter((id) => SKINS.some((skin) => skin.id === id)) : ["classic"],
    selectedSkin: SKINS.some((skin) => skin.id === saved.selectedSkin) ? saved.selectedSkin : "classic",
    areaBests: saved.areaBests && typeof saved.areaBests === "object" ? saved.areaBests : {},
    activeRun: saved.activeRun && typeof saved.activeRun === "object" ? saved.activeRun : null,
  };
}

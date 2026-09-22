import { createAssetStore } from "./assets.js";
import { createAudio } from "./audio.js";
import { AREAS, BOSSES, ENEMIES, SKINS, backgroundAsset, sanitizeProgress, skinAsset, tileAsset } from "./data.js";
import { createInput } from "./input.js";
import { createRenderer } from "./renderer.js";
import { createUI } from "./ui.js";
import { createWorld, performAction, setWorldEvents, updateWorld, worldSnapshot } from "./world.js";

const CHAPTER_AUDIO = { farm: "farm", city: "city", sky: "sky", storm: "storm", beyond: "beyond" };

export function createGame({ mount, sdk, tweaks, assets, saved }) {
  let cleanup = () => {};

  return {
    start() {
      const progress = sanitizeProgress(saved);
      const store = createAssetStore(assets);
      const balance = {
        runSpeed: Number(tweaks.get("runSpeed")),
        gravity: Number(tweaks.get("gravity")),
        jumpForce: Number(tweaks.get("jumpForce")),
        flapForce: Number(tweaks.get("flapForce")),
        spawnGap: Number(tweaks.get("spawnGap")),
        effectsIntensity: Number(tweaks.get("effectsIntensity")),
      };
      const audio = createAudio(sdk, Number(tweaks.get("musicVolume")));
      let world;
      let input;
      let raf = 0;
      let lastTime = performance.now();
      let saveClock = 0;
      let destroyed = false;
      let runFinalized = false;
      const unsubscribers = [];

      const ui = createUI(mount, handleUi);
      const renderer = createRenderer(ui.canvas, store);
      renderer.start();
      input = createInput(ui.root, handleAction);

      const tweakMap = {
        runSpeed: "runSpeed",
        gravity: "gravity",
        jumpForce: "jumpForce",
        flapForce: "flapForce",
        spawnGap: "spawnGap",
        effectsIntensity: "effectsIntensity",
      };
      Object.entries(tweakMap).forEach(([key, property]) => {
        unsubscribers.push(tweaks.subscribe(key, (value) => { balance[property] = Number(value); }));
      });
      unsubscribers.push(tweaks.subscribe("musicVolume", (value) => audio.setVolume(Number(value))));

      function chapterFor(area) {
        return CHAPTER_AUDIO[area.theme] || "farm";
      }

      function criticalAssets(nextWorld) {
        const enemy = ENEMIES[nextWorld.area.enemy];
        const keys = [
          skinAsset(nextWorld.skinId),
          backgroundAsset(nextWorld.area.id), tileAsset(nextWorld.area.theme),
          "ITEMS_ATLAS",
          enemy?.asset,
        ].filter(Boolean);
        if (nextWorld.area.boss) keys.push(BOSSES[nextWorld.area.boss].asset);
        return keys;
      }

      function preloadWorld(nextWorld) {
        void store.warm(criticalAssets(nextWorld));
        const nextArea = AREAS[nextWorld.areaIndex + 1];
        if (nextArea) void store.loadImage(backgroundAsset(nextArea.id)).catch(() => {});
      }

       function startRun({ mode = "explore", areaId = 1, restored = null } = {}) {
        runFinalized = false;
        input?.clear();
        world = createWorld({ areaId, mode, skinId: progress.selectedSkin, restored, balance });
        setWorldEvents(world, handleWorldEvent);
        renderer.resize();
        preloadWorld(world);
        audio.setChapter(chapterFor(world.area));
        ui.hideOverlay();
        ui.banner(world.area);
        ui.update(world, progress);
      }

      function spawnBurst(x, y, color, amount = 8) {
        const count = Math.max(2, Math.round(amount * balance.effectsIntensity));
        for (let i = 0; i < count; i += 1) {
          world.particles.push({ x, y, vx: (Math.random() - 0.5) * 210, vy: -60 - Math.random() * 150, age: 0, life: 0.45 + Math.random() * 0.3, size: 2 + Math.random() * 4, color });
        }
      }

      function haptic(pattern) {
        if (!sdk.device.haptics.isSupported()) return;
        void sdk.device.haptics.vibrate(pattern).catch(() => {});
      }

      function handleWorldEvent(event) {
        if (!world) return;
        switch (event.type) {
          case "start":
            void audio.unlock().catch(() => {});
            break;
          case "jump": audio.sfx.jump(); haptic(18); break;
          case "flap": audio.sfx.flap(); spawnBurst(world.player.x - 22, world.player.y - 22, "#f7efcf", 4); break;
          case "dash": audio.sfx.dash(); haptic(24); spawnBurst(world.player.x - 25, world.player.y - 28, "#d9fbff", 8); break;
          case "land": audio.sfx.land(); spawnBurst(world.player.x, world.player.y, "#e8d2a6", 6); break;
          case "coin": audio.sfx.coin(event.combo); break;
          case "feather": audio.sfx.feather(); spawnBurst(world.player.x, world.player.y - 25, "#c7fff1", 10); break;
          case "pickup": audio.sfx.coin(world.combo); if (event.item === "key") ui.toast("Kunci ditemukan!"); break;
          case "power": audio.sfx.skill(); ui.toast(String(event.item).toUpperCase()); haptic([20, 30, 20]); break;
          case "skill": audio.sfx.skill(); ui.toast((SKINS.find((skin) => skin.id === world.skinId) || SKINS[0]).power); haptic([24, 35, 28]); break;
          case "takeoff": audio.sfx.takeoff(); ui.toast("TAKE OFF"); haptic([18, 20, 28]); break;
          case "hit": audio.sfx.hit(); haptic([45, 30, 45]); spawnBurst(world.player.x, world.player.y - 30, "#ff766a", 12); break;
          case "shieldBreak": audio.sfx.hit(); haptic(32); ui.toast("EGG SHIELD PECAH"); break;
          case "smash": audio.sfx.hit(); spawnBurst(event.x, event.y, "#f2bd54", 12); break;
          case "magic": audio.sfx.skill(); break;
          case "bossStart": audio.sfx.warning(); ui.toast(`${event.name} MENDEKAT`); haptic([60, 45, 60]); break;
          case "bossAttack": audio.sfx.warning(); break;
          case "bossDefeat": audio.sfx.portal(); ui.toast(`${event.name} MUNDUR!`); haptic([25, 30, 25, 30, 50]); break;
          case "portal": audio.sfx.portal(); break;
          case "areaChange":
            bankLoot(`Checkpoint Area ${String(event.completedArea).padStart(2, "0")}`);
            progress.unlockedArea = Math.max(progress.unlockedArea, event.area.id);
            progress.areaBests[event.completedArea] = Math.max(progress.areaBests[event.completedArea] || 0, event.completedDistance);
            audio.setChapter(chapterFor(event.area));
            preloadWorld(world);
            ui.banner(event.area);
            void saveProgress(true);
            break;
          case "gameOver": finalizeRun(); break;
          default: break;
        }
      }

      function handleAction(action, down) {
        if (!down || !world || world.over || world.paused) return;
        performAction(world, action);
      }

      const onCanvasTap = (event) => {
        if (world?.paused || world?.over) return;
        event.preventDefault();
        handleAction("jump", true);
      };
      ui.canvas.addEventListener("pointerdown", onCanvasTap);

      async function saveProgress(includeRun = true) {
        if (!world) return;
        progress.activeRun = includeRun && world.started && !world.over ? worldSnapshot(world) : null;
        await sdk.gameState.save(progress).catch(() => ({ ok: false }));
      }

      function recordCoins(delta, reason) {
        if (!delta) return;
        progress.coinHistory.push({ at: Date.now(), delta, reason, balance: progress.coins });
        progress.coinHistory = progress.coinHistory.slice(-20);
      }

      function bankLoot(reason, reset = true) {
        const earnedCoins = world.collected.coins;
        if (earnedCoins > 0) {
          progress.coins += earnedCoins;
          progress.lifetimeCoins += earnedCoins;
          recordCoins(earnedCoins, reason);
        }
        progress.corn += world.collected.corn;
        progress.feathers += world.collected.feathers;
        progress.cheese += world.collected.cheese;
        progress.keys += world.collected.keys;
        if (reset) world.collected = { coins: 0, corn: 0, feathers: 0, cheese: 0, keys: 0 };
      }

      function finalizeRun() {
        if (runFinalized) return;
        runFinalized = true;
        const previousBest = progress.bestDistance;
        progress.bestDistance = Math.max(progress.bestDistance, world.distance);
        progress.bestScore = Math.max(progress.bestScore, world.score);
        progress.areaBests[world.area.id] = Math.max(progress.areaBests[world.area.id] || 0, world.localDistance);
        if (world.win) progress.unlockedArea = Math.min(AREAS.length, Math.max(progress.unlockedArea, world.area.id + 1));
        progress.activeRun = null;
        ui.showGameOver(world, previousBest);
        bankLoot(`Run Area ${String(world.area.id).padStart(2, "0")}`);
        void saveProgress(false);
        const score = Math.max(0, Math.min(Number.MAX_SAFE_INTEGER, Math.round(world.score)));
        void sdk.leaderboard.submit(score).catch(() => ({ accepted: false }));
      }

      function equipSkin(id) {
        const skin = SKINS.find((entry) => entry.id === id);
        if (!skin) return;
        if (!progress.unlockedSkins.includes(id)) {
          if (progress.coins < skin.price) { ui.toast(`Butuh ● ${skin.price} coin`); return; }
          progress.coins -= skin.price;
          recordCoins(-skin.price, `Beli ${skin.name}`);
          progress.unlockedSkins.push(id);
          ui.toast(`${skin.name} terbuka!`);
        }
        progress.selectedSkin = id;
        void store.warm([skinAsset(id), skinAsset(id, true)]);
        void saveProgress(false);
        startRun({ mode: world.mode, areaId: world.area.id });
      }

      function handleUi(action, data) {
        if (!world) return;
        if (action === "pause") {
          if (world.over) return;
          world.paused = true;
          ui.showPause(world);
        } else if (action === "resume") {
          world.paused = false;
          ui.hideOverlay();
        } else if (action === "close") {
          if (world.over) ui.showGameOver(world, progress.bestDistance);
          else { world.paused = false; ui.hideOverlay(); }
        } else if (action === "map") {
          world.paused = true;
          ui.showMap(progress);
        } else if (action === "shop") {
          world.paused = true;
          if (world.started && !world.over) {
            bankLoot("Masuk Kandang Ayam");
            void saveProgress(true);
          }
          ui.showShop(progress);
        } else if (action === "mode") {
          startRun({ mode: "explore", areaId: world.area.id });
        } else if (action === "area") {
          startRun({ mode: "explore", areaId: Number(data.area) });
        } else if (action === "skin") {
          equipSkin(data.skin);
        } else if (action === "retry") {
          startRun({ mode: world.mode, areaId: world.area.id });
        } else if (action === "quit") {
          world.over = true;
          world.lastThreat = "Run diakhiri";
          finalizeRun();
        } else if (action === "continue") {
          const run = progress.activeRun;
          progress.activeRun = null;
           startRun({ mode: "explore", areaId: run?.areaId || 1, restored: run });
        } else if (action === "new") {
          progress.activeRun = null;
           startRun({ mode: "explore", areaId: 1 });
          void saveProgress(false);
        }
      }

      function frame(now) {
        if (destroyed) return;
        const dt = Math.min(0.033, Math.max(0, (now - lastTime) / 1000));
        lastTime = now;
        updateWorld(world, dt, input, renderer.bounds);
        renderer.render(world);
        ui.update(world, progress);
        saveClock += dt;
        if (saveClock >= 5 && world.started && !world.over) { saveClock = 0; void saveProgress(true); }
        raf = requestAnimationFrame(frame);
      }

      const onVisibility = () => {
        if (document.hidden && world?.started && !world.over) void saveProgress(true);
      };
      document.addEventListener("visibilitychange", onVisibility);

       startRun({ mode: "explore", areaId: 1 });
      if (progress.activeRun) {
        world.paused = true;
        ui.showResume(progress.activeRun);
      }
      raf = requestAnimationFrame(frame);

      cleanup = () => {
        destroyed = true;
        cancelAnimationFrame(raf);
        if (world?.started && !world.over) void saveProgress(true);
        document.removeEventListener("visibilitychange", onVisibility);
        ui.canvas.removeEventListener("pointerdown", onCanvasTap);
        unsubscribers.forEach((unsubscribe) => unsubscribe?.());
        input.destroy();
        renderer.destroy();
        ui.destroy();
        void audio.destroy();
      };
    },
    destroy() {
      cleanup();
      cleanup = () => {};
    },
  };
}

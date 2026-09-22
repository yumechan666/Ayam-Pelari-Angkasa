import { AREAS, SKINS } from "./data.js";

const escapeHtml = (value) => String(value).replace(/[&<>"]/g, (character) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[character]);

export function createUI(mount, onUi) {
  const root = document.createElement("section");
  root.className = "game-shell";
  root.innerHTML = `
    <canvas class="game-surface" aria-label="Ayam Pelari Angkasa"></canvas>
    <div class="hud-layer">
      <div class="hud-row hud-primary">
        <div class="hud-cluster">
          <div id="heartPips" class="pip-row" aria-label="Nyawa"></div>
          <div class="badge stat-badge"><span class="stat-icon">●</span><strong id="coinValue">0</strong></div>
          <div class="badge stat-badge secondary-stat"><span>🌽</span><strong id="cornValue">0</strong></div>
        </div>
        <div class="hud-cluster hud-end">
          <div class="distance-block"><strong id="distanceValue">0m</strong><small id="bestValue">BEST 0m</small></div>
          <button class="icon-btn" data-ui="pause" aria-label="Jeda">Ⅱ</button>
        </div>
      </div>
      <div class="energy-wrap">
        <span class="energy-icon">🪽</span>
        <div class="energy-track"><span id="energyFill"></span></div>
        <span id="multiplierValue" class="multiplier">×1</span>
      </div>
      <div id="bossHud" class="boss-hud" hidden>
        <span id="bossName">BOSS</span><div class="boss-track"><span id="bossFill"></span></div>
      </div>
    </div>
    <div class="quick-tools">
      <button class="tool-btn" data-ui="map"><span>🗺️</span><small>PETA</small></button>
      <button class="tool-btn" data-ui="shop"><span>🐣</span><small>COOP</small></button>
    </div>
    <div id="startPrompt" class="start-prompt">
      <strong>BERGERAK UNTUK MULAI</strong>
      <span>lari → lompat → terbang</span>
    </div>
    <div id="areaBanner" class="area-banner" hidden></div>
    <div id="toast" class="toast" hidden></div>
    <div class="controls-row game-controls" aria-label="Kontrol permainan">
      <div class="control-group steer-group">
        <button class="control-btn steer-btn" data-action="left" aria-label="Kiri"><span class="control-label">◀</span></button>
        <button class="control-btn steer-btn" data-action="right" aria-label="Kanan"><span class="control-label">▶</span></button>
      </div>
      <div class="control-group action-group">
        <button id="jumpButton" class="control-btn jump-btn" data-action="jump"><span class="control-label">JUMP</span></button>
        <button id="downButton" class="control-btn down-btn" data-action="down" hidden><span class="control-label">▼</span></button>
        <button class="control-btn dash-btn" data-action="dash"><span class="control-label">DASH</span></button>
        <button id="skillButton" class="control-btn skill-btn" data-action="skill"><span class="control-label">SKILL</span></button>
      </div>
    </div>
    <div id="overlay" class="overlay" hidden><div id="overlayPanel" class="overlay-panel"></div></div>
  `;
  mount.replaceChildren(root);

  const $ = (selector) => root.querySelector(selector);
  const canvas = $("canvas");
  const overlay = $("#overlay");
  const panel = $("#overlayPanel");
  let toastTimer = 0;
  let bannerTimer = 0;
  let lastHp = null;

  root.addEventListener("click", (event) => {
    const button = event.target.closest("[data-ui]");
    if (!button) return;
    onUi(button.dataset.ui, button.dataset);
  });

  function hideOverlay() {
    overlay.hidden = true;
    panel.replaceChildren();
  }

  function setOverlay(html) {
    panel.innerHTML = html;
    overlay.hidden = false;
  }

  function showMap(progress) {
    const cards = AREAS.map((area) => {
      const unlocked = area.id <= progress.unlockedArea;
      const best = Math.round(progress.areaBests?.[area.id] || 0);
      return `<button class="area-card ${unlocked ? "unlocked" : "locked"}" ${unlocked ? `data-ui="area" data-area="${area.id}"` : "disabled"}>
        <span class="area-number">${String(area.id).padStart(2, "0")}</span><span class="area-emoji">${unlocked ? area.emoji : "🔒"}</span>
        <b>${area.name}</b><small>${unlocked ? (best ? `Best ${best}m` : area.feature) : `Buka Area ${area.id - 1}`}</small>
      </button>`;
    }).join("");
    setOverlay(`
      <div class="overlay-head"><div><small>25 AREA</small><h2>Peta penerbangan</h2></div><button class="icon-btn" data-ui="close">×</button></div>
      <div class="map-grid">${cards}</div>
    `);
  }

  function showShop(progress) {
    const cards = SKINS.map((skin) => {
      const owned = progress.unlockedSkins.includes(skin.id);
      const selected = progress.selectedSkin === skin.id;
      const label = selected ? "DIPAKAI" : owned ? "PAKAI" : `● ${skin.price}`;
      return `<button class="skin-card ${selected ? "selected" : ""}" data-ui="skin" data-skin="${skin.id}">
        <span class="skin-orb" style="--skin:${skin.color}">🐔</span><span class="skin-copy"><b>${skin.name}</b><small>${skin.passive}</small><em>${skin.power}</em></span><strong>${label}</strong>
      </button>`;
    }).join("");
    const history = progress.coinHistory?.slice(-4).reverse().map((entry) => `
      <div class="coin-history-row"><span>${escapeHtml(entry.reason)}</span><b class="${entry.delta >= 0 ? "plus" : "minus"}">${entry.delta >= 0 ? "+" : ""}${entry.delta}</b></div>
    `).join("") || `<div class="coin-history-empty">Belum ada transaksi coin</div>`;
    setOverlay(`
      <div class="overlay-head"><div><small>KANDANG AYAM • ● ${progress.coins} COIN</small><h2>Pilih ayam</h2></div><button class="icon-btn" data-ui="close">×</button></div>
      <div class="skin-list">${cards}</div>
      <div class="coin-history"><strong>RIWAYAT COIN</strong>${history}</div>
    `);
  }

  function showPause(world) {
    setOverlay(`
      <div class="overlay-head"><div><small>${world.area.chapter}</small><h2>${world.area.emoji} ${world.area.name}</h2></div></div>
      <div class="pause-stats"><b>${Math.round(world.distance)}m</b><span>Skor ${Math.round(world.score).toLocaleString("id-ID")}</span></div>
      <div class="overlay-actions"><button class="primary-btn" data-ui="resume">LANJUT</button><button data-ui="map">PILIH MAP</button><button data-ui="quit">AKHIRI RUN</button></div>
    `);
  }

  function showResume(activeRun) {
    setOverlay(`
      <div class="resume-mark">🐔🪽</div><small>RUN TERSIMPAN</small><h2>Lanjut terbang?</h2>
      <div class="resume-stats"><b>${Math.round(activeRun.distance || 0)}m</b><span>Area ${String(activeRun.areaId || 1).padStart(2, "0")}</span><span>❤️ ${activeRun.player?.hp || 3}</span></div>
      <div class="overlay-actions"><button class="primary-btn" data-ui="continue">CONTINUE</button><button data-ui="new">NEW RUN</button></div>
    `);
  }

  function showGameOver(world, bestDistance) {
    const isBest = world.distance >= bestDistance;
    setOverlay(`
      <div class="result-kicker">${world.win ? "CHECKPOINT TERCAPAI" : world.lastThreat ? `TERKENA ${String(world.lastThreat).toUpperCase()}` : "RUN SELESAI"}</div>
      <h2 class="result-distance">${Math.round(world.distance)}m</h2>
      <div class="result-row"><span>Skor <b>${Math.round(world.score).toLocaleString("id-ID")}</b></span><span>${isBest ? "REKOR BARU" : `Best ${Math.round(bestDistance)}m`}</span></div>
      <div class="loot-row"><span>● ${world.collected.coins}</span><span>🌽 ${world.collected.corn}</span><span>🪶 ${world.collected.feathers}</span><span>🧀 ${world.collected.cheese}</span></div>
      <div class="overlay-actions"><button class="primary-btn" data-ui="retry">COBA LAGI</button><button data-ui="map">PETA</button><button data-ui="shop">COOP</button></div>
    `);
  }

  function toast(message) {
    const element = $("#toast");
    window.clearTimeout(toastTimer);
    element.textContent = message;
    element.hidden = false;
    toastTimer = window.setTimeout(() => { element.hidden = true; }, 1500);
  }

  function banner(area) {
    const element = $("#areaBanner");
    window.clearTimeout(bannerTimer);
    element.innerHTML = `<small>${area.chapter}</small><b>${String(area.id).padStart(2, "0")} • ${area.name}</b>`;
    element.hidden = false;
    bannerTimer = window.setTimeout(() => { element.hidden = true; }, 1900);
  }

  function update(world, progress) {
    const pips = $("#heartPips");
    if (lastHp !== world.player.hp) {
      lastHp = world.player.hp;
      pips.innerHTML = Array.from({ length: 3 }, (_, index) => `<span class="pip heart-pip ${index >= world.player.hp ? "empty" : ""}">♥</span>`).join("");
    }
    $("#coinValue").textContent = progress.coins + world.collected.coins;
    $("#cornValue").textContent = progress.corn + world.collected.corn;
    $("#distanceValue").textContent = `${Math.round(world.distance)}m`;
    $("#bestValue").textContent = world.mode === "time" ? `${Math.ceil(world.timeLeft)}s` : `BEST ${Math.round(progress.bestDistance)}m`;
    $("#energyFill").style.width = `${Math.max(0, Math.min(100, world.player.energy / world.player.maxEnergy * 100))}%`;
    $("#multiplierValue").textContent = `×${world.multiplier.toFixed(world.multiplier % 1 ? 1 : 0)}`;
    $("#startPrompt").hidden = world.started || world.over || !overlay.hidden;
    const airborne = !world.player.onGround;
    $("#jumpButton .control-label").textContent = airborne ? "FLAP" : "JUMP";
    $("#downButton").hidden = !airborne;
    const skin = SKINS.find((entry) => entry.id === world.skinId) || SKINS[0];
    $("#skillButton .control-label").textContent = world.player.skillCooldown > 0 ? Math.ceil(world.player.skillCooldown) : skin.power.split(" ")[0].toUpperCase();
    $("#skillButton").classList.toggle("cooling", world.player.skillCooldown > 0);
    const bossHud = $("#bossHud");
    bossHud.hidden = !world.boss;
    if (world.boss) {
      $("#bossName").textContent = world.boss.name;
      $("#bossFill").style.width = `${world.boss.stamina}%`;
    }
  }

  function destroy() {
    window.clearTimeout(toastTimer);
    window.clearTimeout(bannerTimer);
    root.remove();
  }

  return { root, canvas, hideOverlay, showMap, showShop, showPause, showResume, showGameOver, toast, banner, update, destroy };
}

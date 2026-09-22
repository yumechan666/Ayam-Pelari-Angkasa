import sdk from "@playabl/sdk";
import assetsManifest from "./assets.json";
import { createGame } from "./game/game.js";
import tweaksManifest from "./tweaks.json";
import "./styles.css";

const app = document.querySelector("#app");

async function boot() {
  const ready = await sdk.ready();
  const saved = await sdk.gameState.load().catch(() => null);
  const tweaks = await sdk.tweaks.init(tweaksManifest);
  const assets = Object.keys(assetsManifest).length > 0
    ? await sdk.assets.register(assetsManifest)
    : undefined;

  // Keep bootstrap boring; build the actual game in src/game/game.js.
  const game = createGame({ mount: app, sdk, ready, tweaks, assets, saved });
  game.start();
}

boot().catch(() => {
  const failure = document.createElement("section");
  failure.className = "startup-failure";
  failure.innerHTML = `<strong>Ayam Pelari Angkasa belum siap terbang.</strong><span>Periksa koneksi Preview lalu coba lagi.</span><button type="button"><span class="control-label">COBA LAGI</span></button>`;
  failure.querySelector("button").addEventListener("click", () => window.location.reload());
  app.replaceChildren(failure);
});

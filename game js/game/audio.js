const CHAPTER_NOTES = {
  farm: [60, 64, 67, 72, 67, 64, 62, 67],
  city: [48, 55, 58, 60, 55, 63, 58, 55],
  sky: [65, 69, 72, 76, 74, 72, 69, 76],
  storm: [45, 52, 48, 55, 45, 57, 52, 48],
  beyond: [53, 60, 65, 67, 72, 65, 62, 69],
};

const midi = (note) => 440 * 2 ** ((note - 69) / 12);

export function createAudio(sdk, initialVolume = 0.18) {
  let managed = null;
  let context = null;
  let master = null;
  let timer = 0;
  let step = 0;
  let chapter = "farm";
  let volume = initialVolume;
  let unlockPromise = null;

  function unlock() {
    if (context?.state === "running") {
      startMusic();
      return Promise.resolve();
    }
    if (unlockPromise) return unlockPromise;
    unlockPromise = (async () => {
      if (!managed) managed = await sdk.audio.getContext();
      await managed.unlock();
      context = managed.context;
      if (!master) {
        master = context.createGain();
        master.gain.value = volume;
        master.connect(context.destination);
      }
      startMusic();
    })().finally(() => { unlockPromise = null; });
    return unlockPromise;
  }

  function tone(frequency, duration, { type = "sine", gain = 0.12, slide = 0 } = {}) {
    if (!context || context.state !== "running" || !master) return;
    const now = context.currentTime;
    const osc = context.createOscillator();
    const amp = context.createGain();
    osc.type = type;
    osc.frequency.setValueAtTime(Math.max(30, frequency), now);
    if (slide) osc.frequency.exponentialRampToValueAtTime(Math.max(30, frequency + slide), now + duration);
    amp.gain.setValueAtTime(0.0001, now);
    amp.gain.exponentialRampToValueAtTime(gain, now + 0.012);
    amp.gain.exponentialRampToValueAtTime(0.0001, now + duration);
    osc.connect(amp).connect(master);
    osc.start(now);
    osc.stop(now + duration + 0.02);
  }

  function noise(duration = 0.08, gain = 0.08) {
    if (!context || context.state !== "running" || !master) return;
    const size = Math.max(1, Math.floor(context.sampleRate * duration));
    const buffer = context.createBuffer(1, size, context.sampleRate);
    const data = buffer.getChannelData(0);
    for (let i = 0; i < size; i += 1) data[i] = (Math.random() * 2 - 1) * (1 - i / size);
    const source = context.createBufferSource();
    const amp = context.createGain();
    const filter = context.createBiquadFilter();
    filter.type = "lowpass";
    filter.frequency.value = 1800;
    amp.gain.value = gain;
    source.buffer = buffer;
    source.connect(filter).connect(amp).connect(master);
    source.start();
  }

  function musicTick() {
    if (!context || context.state !== "running") return;
    const notes = CHAPTER_NOTES[chapter] || CHAPTER_NOTES.farm;
    const note = notes[step % notes.length];
    tone(midi(note), 0.22, { type: chapter === "city" ? "square" : "triangle", gain: 0.035 });
    if (step % 4 === 0) tone(midi(note - 24), 0.35, { type: "sine", gain: 0.045 });
    step += 1;
  }

  function startMusic() {
    if (timer) return;
    musicTick();
    timer = window.setInterval(musicTick, 360);
  }

  function setChapter(next) {
    chapter = next;
    step = 0;
  }

  function setVolume(next) {
    volume = Math.max(0, Math.min(0.5, Number(next) || 0));
    if (master && context) master.gain.setTargetAtTime(volume, context.currentTime, 0.04);
  }

  const sfx = {
    jump: () => tone(360, 0.13, { type: "triangle", gain: 0.16, slide: 280 }),
    flap: () => { noise(0.07, 0.08); tone(220, 0.08, { type: "sine", gain: 0.06, slide: 90 }); },
    dash: () => { noise(0.16, 0.12); tone(180, 0.16, { type: "sawtooth", gain: 0.07, slide: 420 }); },
    coin: (combo = 0) => tone(660 * 1.03 ** combo, 0.08, { type: "square", gain: 0.09, slide: 80 }),
    feather: () => tone(760, 0.2, { type: "sine", gain: 0.11, slide: 420 }),
    hit: () => { noise(0.12, 0.18); tone(110, 0.18, { type: "square", gain: 0.13, slide: -40 }); },
    land: () => { noise(0.06, 0.06); tone(95, 0.08, { type: "sine", gain: 0.08 }); },
    takeoff: () => { noise(0.2, 0.1); tone(260, 0.35, { type: "triangle", gain: 0.1, slide: 520 }); },
    portal: () => { tone(330, 0.45, { type: "sine", gain: 0.1, slide: 660 }); tone(495, 0.4, { type: "triangle", gain: 0.05, slide: 500 }); },
    warning: () => tone(105, 0.32, { type: "sawtooth", gain: 0.13, slide: -25 }),
    skill: () => { tone(420, 0.22, { type: "triangle", gain: 0.12, slide: 540 }); noise(0.1, 0.06); },
  };

  async function destroy() {
    if (timer) window.clearInterval(timer);
    timer = 0;
    if (managed) await managed.dispose().catch(() => {});
    managed = null;
    unlockPromise = null;
    context = null;
    master = null;
  }

  return { unlock, setChapter, setVolume, sfx, destroy };
}

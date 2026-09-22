function frameUrl(url) {
  return url.replace(/\.webp(?:\?.*)?$/, ".frames.json");
}

export function createAssetStore(assetHandle) {
  const images = new Map();
  const sheets = new Map();
  const loading = new Map();

  const urlFor = (key) => assetHandle?.get(key) || "";

  function loadImage(key) {
    if (images.has(key)) return Promise.resolve(images.get(key));
    if (loading.has(`image:${key}`)) return loading.get(`image:${key}`);
    const url = urlFor(key);
    const promise = new Promise((resolve, reject) => {
      if (!url) return reject(new Error(`Asset tidak ditemukan: ${key}`));
      const image = new Image();
      image.decoding = "async";
      image.onload = () => { images.set(key, image); resolve(image); };
      image.onerror = () => reject(new Error(`Gagal memuat ${key}`));
      image.src = url;
    }).finally(() => loading.delete(`image:${key}`));
    loading.set(`image:${key}`, promise);
    return promise;
  }

  function loadSheet(key) {
    if (sheets.has(key)) return Promise.resolve(sheets.get(key));
    if (loading.has(`sheet:${key}`)) return loading.get(`sheet:${key}`);
    const url = urlFor(key);
    const promise = Promise.all([
      loadImage(key),
      fetch(frameUrl(url)).then((response) => {
        if (!response.ok) throw new Error(`Frame ${key} tidak ditemukan`);
        return response.json();
      }),
    ]).then(([image, meta]) => {
      const value = { image, meta };
      sheets.set(key, value);
      return value;
    }).finally(() => loading.delete(`sheet:${key}`));
    loading.set(`sheet:${key}`, promise);
    return promise;
  }

  function warm(keys) {
    return Promise.allSettled(keys.map((key) => key.startsWith("BG_") ? loadImage(key) : loadSheet(key)));
  }

  function getImage(key) {
    if (!images.has(key)) void loadImage(key).catch(() => {});
    return images.get(key);
  }

  function getSheet(key) {
    if (!sheets.has(key)) void loadSheet(key).catch(() => {});
    return sheets.get(key);
  }

  return { loadImage, loadSheet, warm, getImage, getSheet, urlFor };
}


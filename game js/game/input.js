const KEY_ACTIONS = {
  ArrowLeft: "left", a: "left", A: "left",
  ArrowRight: "right", d: "right", D: "right",
  ArrowUp: "up", w: "up", W: "up", " ": "jump",
  ArrowDown: "down", s: "down", S: "down",
  Shift: "dash", e: "skill", E: "skill",
};

export function createInput(root, onAction) {
  const held = new Set();
  const listeners = [];
  const listen = (target, type, fn, options) => {
    target.addEventListener(type, fn, options);
    listeners.push(() => target.removeEventListener(type, fn, options));
  };

  listen(window, "keydown", (event) => {
    const action = KEY_ACTIONS[event.key];
    if (!action) return;
    event.preventDefault();
    if (!held.has(action)) onAction(action, true);
    held.add(action);
  });
  listen(window, "keyup", (event) => {
    const action = KEY_ACTIONS[event.key];
    if (!action) return;
    held.delete(action);
    onAction(action, false);
  });

  root.querySelectorAll("[data-action]").forEach((button) => {
    const action = button.dataset.action;
    const release = (event) => {
      if (!held.has(action)) return;
      held.delete(action);
      onAction(action, false, event);
      button.classList.remove("is-pressed");
    };
    listen(button, "pointerdown", (event) => {
      event.preventDefault();
      button.setPointerCapture?.(event.pointerId);
      if (!held.has(action)) onAction(action, true, event);
      held.add(action);
      button.classList.add("is-pressed");
    });
    listen(button, "pointerup", release);
    listen(button, "pointercancel", release);
    listen(button, "lostpointercapture", release);
  });

  return {
    isHeld(action) { return held.has(action); },
    clear() { held.clear(); },
    destroy() { listeners.splice(0).forEach((off) => off()); },
  };
}

// ============================================
// UTILITY FUNCTIONS
// ============================================

// Math Utilities
export function clamp01(value) {
  return Math.min(1, Math.max(0, value));
}

export function clampFraction(value) {
  if (!Number.isFinite(value)) return 0;
  return Math.min(1, Math.max(0, value));
}

export function lerp(min, max, t) {
  return min + (max - min) * t;
}

// Color Utilities
export function hexToRgb(hex) {
  const normalized = hex.replace('#', '');
  const bigint = parseInt(normalized, 16);
  return {
    r: (bigint >> 16) & 255,
    g: (bigint >> 8) & 255,
    b: bigint & 255,
  };
}

export function rgbToHex(r, g, b) {
  const toHex = (value) => value.toString(16).padStart(2, '0');
  return `#${toHex(r)}${toHex(g)}${toHex(b)}`;
}

export function adjustColor(hex, factor) {
  const { r, g, b } = hexToRgb(hex);
  const mix = (channel) => {
    const mixed = channel * factor + 255 * (1 - factor);
    return Math.round(Math.max(0, Math.min(255, mixed)));
  };
  return rgbToHex(mix(r), mix(g), mix(b));
}

export function withAlpha(rgbaString, multiplier) {
  const match = rgbaString.match(/rgba?\(([^)]+)\)/i);
  if (!match) return rgbaString;
  const parts = match[1].split(',').map((part) => part.trim());
  if (parts.length < 3) return rgbaString;
  const [r, g, b, alpha = '1'] = parts;
  const a = Math.max(0, Math.min(1, parseFloat(alpha) * multiplier));
  return `rgba(${r}, ${g}, ${b}, ${a.toFixed(3)})`;
}

// Time Formatting
export function formatTime(seconds) {
  if (!isFinite(seconds)) return "0:00";
  const mins = Math.floor(seconds / 60);
  const secs = Math.floor(seconds % 60);
  return `${mins}:${secs.toString().padStart(2, "0")}`;
}

// Random Number Generator (Seeded)
export function pseudoRandom(seed) {
  let value = Math.sin(seed) * 10000;
  return (range = 1) => {
    value = Math.sin(value) * 10000;
    return (value - Math.floor(value)) * range;
  };
}

// Key Parsing
export function extractKeyRoot(key) {
  const match = key.match(/^([A-G])([♭#])?/);
  if (!match) return key;
  const base = match[1];
  const accidental = match[2];
  if (accidental === "#") return `${base}♯`;
  if (accidental === "♭") {
    const flats = {
      B: "A♯", E: "D♯", A: "G♯", D: "C♯",
      G: "F♯", C: "B", F: "E",
    };
    return flats[base] || base;
  }
  return base;
}

// URL Normalization
export function normalizeSoundUrl(identifier) {
  if (identifier == null) return null;
  const raw = String(identifier).trim();
  if (!raw) return null;

  if (/^\d+$/.test(raw)) {
    return `https://api.soundcloud.com/tracks/${raw}`;
  }

  try {
    const url = new URL(raw);
    return url.href;
  } catch {
    return null;
  }
}

// DOM Utilities
export function createSVGElement(tag) {
  return document.createElementNS("http://www.w3.org/2000/svg", tag);
}

export function ensureGradientDefs(svg) {
  if (!svg) return null;
  const existing = svg.querySelector('defs');
  if (existing) return existing;
  const defs = createSVGElement('defs');
  svg.insertBefore(defs, svg.firstChild);
  return defs;
}

// Debounce
export function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

// Error Display
export function showUserError(message) {
  const metaPanel = document.getElementById("track-meta");
  if (metaPanel) {
    metaPanel.innerHTML = `<p class="track-meta__error">${message}</p>`;
  }
  console.error(message);
}

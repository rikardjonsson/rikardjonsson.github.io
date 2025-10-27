// ============================================
// STARMAP CONSTANTS
// ============================================
// Centralized configuration for all magic numbers

// Canvas Configuration
export const CANVAS = {
  VIEWBOX_SIZE: 1000,
  PADDING: 0,
  OFFSET_LEFT: 0,
  OFFSET_TOP: 0,
};

// Animation Timings (milliseconds)
export const ANIMATION = {
  FADE_IN_STAGGER: 25,           // Delay between node fade-ins
  LAYOUT_CHANGE_STAGGER: 35,     // Delay between node movements
  RADIAL_DELAY_MULTIPLIER: 80,   // Delay multiplier based on distance from center
  LINK_APPEARANCE_DELAY: 120,    // Delay between link appearances
  TWINKLE_INTERVAL: 140,         // Delay between twinkle animation starts
  TWINKLE_DURATION: 4800,        // Total twinkle animation cycle (ms)
  TRANSITION_DURATION: 1700,     // Node movement transition duration
  OPACITY_TRANSITION: 840,       // Opacity fade transition
  FILTER_TRANSITION: 640,        // Filter effect transition
  META_FADE_DURATION: 500,       // Metadata fade in/out duration
  META_AUTO_HIDE: 4000,          // Time before metadata auto-hides
};

// Node Sizing
export const NODE = {
  MIN_BPM: 70,
  MAX_BPM: 130,
  MIN_RADIUS: 10,
  MAX_RADIUS: 17,
  HALO_SCALE: 2.4,
  FLARE_SCALE: 3.2,
  SPARK_SCALE: 0.25,
  HOVER_SCALE: 1.06,
  ACTIVE_SCALE: 1.1,
  PLAYING_HALO_SCALE: 1.28,
};

// Layout Configuration
export const LAYOUT = {
  CONSTELLATION: {
    OFFSET_X: 0.06,
    OFFSET_Y: 0.08,
    SCALE: 1.28,
    CENTER_X: 0.5,
    CENTER_Y: 0.5,
  },
  HELIX: {
    MIN_Y: 0.25,
    Y_RANGE: 0.5,
    BASE_RADIUS: 0.18,
    PULSE_RADIUS_MULTIPLIER: 0.14,
    ROTATIONS: 4,
  },
  SCATTER: {
    SEED: 1337,
    MIN_X: 0.15,
    X_RANGE: 0.7,
    MIN_Y: 0.2,
    Y_RANGE: 0.6,
    NEIGHBOR_CONNECTIONS: 2,
  },
  TEMPO_SPIRAL: {
    START_RADIUS: 0.04,
    RADIUS_GROWTH: 0.065,
    TOTAL_ROTATIONS: 2.8,
  },
};

// Color System
export const COLORS = {
  KEY_ORDER: ["C", "G", "D", "A", "E", "B", "F♯", "C♯", "G♯", "D♯", "A♯", "F"],
  MAJOR_BRIGHTNESS: 0.85,
  MINOR_BRIGHTNESS: 0.7,
  MAJOR_HALO_ALPHA: 1,
  MINOR_HALO_ALPHA: 0.85,
  BPM_GLOW_BASE: 10,
  BPM_GLOW_DIVISOR: 10,
};

// Halo Opacity Calculations
export const HALO = {
  BASE_OPACITY: 0.35,
  PULSE_MULTIPLIER: 0.25,
  HOVER_BONUS: 0.12,
  PLAY_BONUS: 0.28,
};

// Audio Player
export const AUDIO = {
  WIDGET_LOAD_RETRIES: 50,
  RETRY_INTERVAL: 100,          // ms between retries
  READY_TIMEOUT: 10000,         // ms before widget ready timeout
  SOUNDCLOUD_BASE_URL: "https://w.soundcloud.com/player/",
  SOUNDCLOUD_API_BASE: "https://api.soundcloud.com/tracks/",
};

// Performance
export const PERFORMANCE = {
  LINK_UPDATE_FRAME_BUDGET: 3,  // Max RAF frames for link updates
  RESIZE_DEBOUNCE: 100,         // ms to debounce resize events
};

// Validation
export const VALIDATION = {
  MIN_BPM: 40,
  MAX_BPM: 200,
  KEY_PATTERN: /^[A-G][♭#]?\s?(Maj|Min)$/,
};

// Color Palettes (indexed by key)
export const COLOR_PALETTES = [
  { inner: "#fff3fb", mid: "#ffd6f5", outer: "#f0b2f1", halo: "rgba(255, 190, 242, 0.42)", flare: "rgba(255, 220, 247, 0.18)", spark: "#fff8fe" },
  { inner: "#f9f5ff", mid: "#ded7ff", outer: "#b8b2ff", halo: "rgba(208, 198, 255, 0.38)", flare: "rgba(198, 206, 255, 0.16)", spark: "#f6f2ff" },
  { inner: "#f6fdff", mid: "#d7f2ff", outer: "#acdffe", halo: "rgba(170, 220, 255, 0.36)", flare: "rgba(190, 236, 255, 0.16)", spark: "#f3fbff" },
  { inner: "#fdf7ff", mid: "#f4d4ff", outer: "#e0b4ff", halo: "rgba(223, 185, 255, 0.38)", flare: "rgba(240, 210, 255, 0.18)", spark: "#fff6fe" },
  { inner: "#fff5f7", mid: "#ffd9e9", outer: "#f2b6cf", halo: "rgba(253, 194, 217, 0.4)", flare: "rgba(255, 210, 228, 0.18)", spark: "#fff1f6" },
  { inner: "#f7fbff", mid: "#d8ecff", outer: "#b3d4ff", halo: "rgba(176, 210, 255, 0.36)", flare: "rgba(195, 225, 255, 0.16)", spark: "#f4faff" },
  { inner: "#fff8f4", mid: "#ffe1ce", outer: "#f2c1a9", halo: "rgba(253, 200, 170, 0.34)", flare: "rgba(255, 220, 196, 0.15)", spark: "#fff3ea" },
  { inner: "#fef5ff", mid: "#e9d2ff", outer: "#c4b1ff", halo: "rgba(204, 176, 255, 0.38)", flare: "rgba(220, 200, 255, 0.16)", spark: "#faf0ff" },
  { inner: "#f5fdff", mid: "#caf3ff", outer: "#9fdefa", halo: "rgba(159, 222, 250, 0.34)", flare: "rgba(180, 236, 255, 0.15)", spark: "#effbff" },
  { inner: "#fff3f8", mid: "#ffd4ed", outer: "#f0abd9", halo: "rgba(246, 188, 224, 0.38)", flare: "rgba(255, 210, 235, 0.16)", spark: "#ffeef6" },
  { inner: "#f9f4ff", mid: "#e3d4ff", outer: "#c0b1ff", halo: "rgba(198, 176, 255, 0.38)", flare: "rgba(216, 198, 255, 0.16)", spark: "#f5efff" },
  { inner: "#f5fffb", mid: "#cefaea", outer: "#a6edd7", halo: "rgba(160, 238, 210, 0.34)", flare: "rgba(190, 246, 226, 0.16)", spark: "#effff9" },
];

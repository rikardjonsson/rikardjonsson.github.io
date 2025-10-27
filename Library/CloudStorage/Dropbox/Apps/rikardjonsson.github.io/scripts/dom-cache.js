// ============================================
// DOM CACHE & STATE MANAGEMENT
// ============================================
// Cached DOM references to avoid repeated queries

export const DOM = {
  // Canvas elements
  starmapSvg: null,
  nodeLayer: null,
  linkLayer: null,
  gradientDefs: null,

  // Player elements
  scWidget: null,
  playPauseBtn: null,
  progressBar: null,
  progressFill: null,
  progressHandle: null,
  currentTimeEl: null,
  durationEl: null,
  trackTitleEl: null,
  customPlayer: null,
  audioPlayer: null,

  // UI elements
  metaPanel: null,
  layoutButtons: null,

  // Modal elements
  aboutButton: null,
  aboutOverlay: null,
  aboutClose: null,
  aboutBackdrop: null,
  guideButton: null,
  guideOverlay: null,
  guideClose: null,
  guideBackdrop: null,
};

// Cached computed values
let cachedCanvasBounds = null;

export function getCachedBounds() {
  if (!cachedCanvasBounds && DOM.starmapSvg) {
    const bounds = DOM.starmapSvg.getBoundingClientRect();
    cachedCanvasBounds = {
      width: bounds.width || 1000,
      height: bounds.height || 1000,
    };
  }
  return cachedCanvasBounds;
}

export function invalidateCanvasBounds() {
  cachedCanvasBounds = null;
}

// Initialize all DOM references
export function initializeDOM() {
  // Canvas
  DOM.starmapSvg = document.getElementById("starmap-canvas");
  DOM.metaPanel = document.getElementById("track-meta");
  DOM.layoutButtons = Array.from(document.querySelectorAll(".layout-button"));

  // Player
  DOM.scWidget = document.getElementById("sc-widget");
  DOM.playPauseBtn = document.getElementById("play-pause-btn");
  DOM.progressBar = document.getElementById("progress-bar");
  DOM.progressFill = document.getElementById("progress-fill");
  DOM.progressHandle = document.getElementById("progress-handle");
  DOM.currentTimeEl = document.getElementById("current-time");
  DOM.durationEl = document.getElementById("duration");
  DOM.trackTitleEl = document.getElementById("current-track-title");
  DOM.customPlayer = document.querySelector(".custom-player");
  DOM.audioPlayer = document.getElementById("audio-player");

  // Modals
  DOM.aboutButton = document.getElementById("about-button");
  DOM.aboutOverlay = document.getElementById("about-overlay");
  DOM.aboutClose = document.getElementById("about-close");
  DOM.aboutBackdrop = document.getElementById("about-backdrop");
  DOM.guideButton = document.getElementById("guide-button");
  DOM.guideOverlay = document.getElementById("guide-overlay");
  DOM.guideClose = document.getElementById("guide-close");
  DOM.guideBackdrop = document.getElementById("guide-backdrop");

  // Validate critical elements
  if (!DOM.starmapSvg) {
    throw new Error("Critical DOM element missing: #starmap-canvas");
  }
  if (!DOM.scWidget) {
    console.warn("SoundCloud widget element not found");
  }

  console.log("✅ DOM cache initialized");
}

// Application State
export const state = {
  // Album data
  album: null,
  nodes: new Map(),
  positions: {},

  // Layout
  layout: "constellations",
  hasLoadedOnce: false,

  // Playback
  widget: null,
  widgetReady: false,
  playingId: null,
  isPlaying: false,
  currentTrackUrl: null,
  pendingTrack: null,
  defaultTrackId: null,

  // UI state
  currentMetaTrackId: null,
  trackOrder: [],
  lastNavigationMode: "pointer",

  // Performance tracking
  resizeObserver: null,
  linkPositionUpdater: { rafId: null, remaining: 0 },

  // Audio loading retries
  scLoadRetries: 0,
};

// State getters/setters with validation
export function setAlbum(album) {
  if (!album || !album.tracks) {
    throw new Error("Invalid album data");
  }
  state.album = album;
  state.trackOrder = album.tracks.map((track) => track.id);
}

export function getAlbum() {
  return state.album;
}

export function getNode(trackId) {
  return state.nodes.get(trackId);
}

export function setNode(trackId, nodeData) {
  state.nodes.set(trackId, nodeData);
}

export function clearNodes() {
  state.nodes.clear();
}

export function getCurrentTrackId() {
  return (
    state.playingId ??
    state.currentMetaTrackId ??
    state.defaultTrackId ??
    state.trackOrder[0] ??
    null
  );
}

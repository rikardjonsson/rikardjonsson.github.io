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
  starfieldCanvas: null,

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

  // Mobile specific elements
  main: null,
  mobileStatus: null,
  mobileLayoutLabel: null,
  mobileTrackLabel: null,
  mobileViewHint: null,
  mobileViewToggle: null,
  mobileViewButtons: [],
  mobileTrackPrev: null,
  mobileTrackNext: null,
  mobileLayoutPrev: null,
  mobileLayoutNext: null,
};

// Cached computed values
let cachedCanvasBounds = null;

export function getCachedBounds() {
  if (!cachedCanvasBounds && DOM.starmapSvg) {
    const bounds = DOM.starmapSvg.getBoundingClientRect();
    const width = bounds.width || 1000;
    const height = bounds.height || 1000;

    cachedCanvasBounds = { width, height };

    console.log('📐 Cached canvas bounds:', {
      raw: { width: bounds.width, height: bounds.height },
      cached: cachedCanvasBounds,
      clientDimensions: {
        width: DOM.starmapSvg.clientWidth,
        height: DOM.starmapSvg.clientHeight
      }
    });
  }
  return cachedCanvasBounds;
}

export function invalidateCanvasBounds() {
  cachedCanvasBounds = null;
}

// Initialize all DOM references
export function initializeDOM() {
  // Canvas
  DOM.starfieldCanvas = document.getElementById("starfield");
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

  // Mobile
  DOM.main = document.querySelector("main");
  DOM.mobileStatus = document.querySelector(".mobile-status");
  DOM.mobileLayoutLabel = document.getElementById("mobile-layout-label");
  DOM.mobileTrackLabel = document.getElementById("mobile-track-label");
  DOM.mobileViewHint = document.getElementById("mobile-view-hint");
  DOM.mobileViewToggle = document.getElementById("mobile-view-toggle");
  DOM.mobileViewButtons = Array.from(document.querySelectorAll(".mobile-view-toggle__btn"));
  DOM.mobileTrackPrev = document.getElementById("mobile-track-prev");
  DOM.mobileTrackNext = document.getElementById("mobile-track-next");
  DOM.mobileLayoutPrev = document.getElementById("mobile-layout-prev");
  DOM.mobileLayoutNext = document.getElementById("mobile-layout-next");

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
  keyboardFocusId: null,
  isMobile: false,
  mobileView: "constellation",

  // Performance tracking
  resizeObserver: null,
  linkPositionUpdater: { rafId: null, remaining: 0 },

  // Audio loading retries
  scLoadRetries: 0,

  // Background animation
  starfieldController: null,
};

// State getters/setters with validation
export function setAlbum(album) {
  if (!album || !album.tracks) {
    throw new Error("Invalid album data");
  }
  state.album = album;
  const orderedTracks = [...album.tracks].sort((a, b) => {
    const aNum = Number.isFinite(a.trackNumber) ? a.trackNumber : Number.POSITIVE_INFINITY;
    const bNum = Number.isFinite(b.trackNumber) ? b.trackNumber : Number.POSITIVE_INFINITY;

    if (aNum === bNum) {
      return album.tracks.indexOf(a) - album.tracks.indexOf(b);
    }
    return aNum - bNum;
  });
  state.trackOrder = orderedTracks.map((track) => track.id);
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

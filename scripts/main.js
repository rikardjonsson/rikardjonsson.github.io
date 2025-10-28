// ============================================
// STARMAP - MAIN ENTRY (Modular Architecture)
// ============================================
// Integrates refactored modules with gradual migration plan

import { CANVAS, ANIMATION, LAYOUT } from './constants.js';
import {
  clamp01,
  debounce,
  formatTime,
  normalizeSoundUrl,
  ensureGradientDefs,
  createSVGElement,
  showUserError,
} from './utils.js';
import { validateAlbum, sanitizeTrack } from './validation.js';
import {
  DOM,
  state,
  initializeDOM,
  setAlbum,
  getNode,
  setNode,
  clearNodes,
  getCurrentTrackId,
  getCachedBounds,
  invalidateCanvasBounds,
} from './dom-cache.js';
import {
  initMobileTracklist,
  updatePlayingCard,
} from './mobile-tracklist.js';
import {
  SoundCloudPlayer,
  createWidgetSrc,
  waitForSoundCloudAPI,
} from './soundcloud-player.js';
import { createNode, cleanupAllNodes } from './node-renderer.js';
import {
  renderLinks,
  scheduleLinksUpdateOnTransitionEnd,
  cancelPendingLinkUpdates,
  updateAllLinkPositions,
  revealLinks,
  mapToCanvasX,
  mapToCanvasY,
} from './link-renderer.js';
import { normalizePositions } from './layouts/layout-base.js';
import { createStarfieldController } from './starfield.js';

// ============================================
// LAYOUT ALGORITHMS
// ============================================

function constellationLayout(tracks) {
  const { OFFSET_X, OFFSET_Y, SCALE, CENTER_X, CENTER_Y } = LAYOUT.CONSTELLATION;

  const patterns = [
    {
      name: "Andromeda",
      points: [
        { x: CENTER_X + (0.18 - CENTER_X) * SCALE + OFFSET_X, y: CENTER_Y + (0.22 - CENTER_Y) * SCALE + OFFSET_Y },
        { x: CENTER_X + (0.26 - CENTER_X) * SCALE + OFFSET_X, y: CENTER_Y + (0.3 - CENTER_Y) * SCALE + OFFSET_Y },
        { x: CENTER_X + (0.34 - CENTER_X) * SCALE + OFFSET_X, y: CENTER_Y + (0.38 - CENTER_Y) * SCALE + OFFSET_Y },
        { x: CENTER_X + (0.46 - CENTER_X) * SCALE + OFFSET_X, y: CENTER_Y + (0.32 - CENTER_Y) * SCALE + OFFSET_Y },
      ],
      links: [[0, 1], [1, 2], [2, 3]],
    },
    {
      name: "Lyra",
      points: [
        { x: CENTER_X + (0.62 - CENTER_X) * SCALE + OFFSET_X, y: CENTER_Y + (0.24 - CENTER_Y) * SCALE + OFFSET_Y },
        { x: CENTER_X + (0.7 - CENTER_X) * SCALE + OFFSET_X, y: CENTER_Y + (0.18 - CENTER_Y) * SCALE + OFFSET_Y },
        { x: CENTER_X + (0.78 - CENTER_X) * SCALE + OFFSET_X, y: CENTER_Y + (0.28 - CENTER_Y) * SCALE + OFFSET_Y },
        { x: CENTER_X + (0.68 - CENTER_X) * SCALE + OFFSET_X, y: CENTER_Y + (0.36 - CENTER_Y) * SCALE + OFFSET_Y },
      ],
      links: [[0, 1], [1, 2], [2, 3], [3, 0]],
    },
    {
      name: "Pisces",
      points: [
        { x: CENTER_X + (0.28 - CENTER_X) * SCALE + OFFSET_X, y: CENTER_Y + (0.72 - CENTER_Y) * SCALE + OFFSET_Y },
        { x: CENTER_X + (0.36 - CENTER_X) * SCALE + OFFSET_X, y: CENTER_Y + (0.62 - CENTER_Y) * SCALE + OFFSET_Y },
        { x: CENTER_X + (0.44 - CENTER_X) * SCALE + OFFSET_X, y: CENTER_Y + (0.7 - CENTER_Y) * SCALE + OFFSET_Y },
      ],
      links: [[0, 1], [1, 2]],
    },
    {
      name: "Orion",
      points: [
        { x: CENTER_X + (0.58 - CENTER_X) * SCALE + OFFSET_X, y: CENTER_Y + (0.68 - CENTER_Y) * SCALE + OFFSET_Y },
        { x: CENTER_X + (0.66 - CENTER_X) * SCALE + OFFSET_X, y: CENTER_Y + (0.62 - CENTER_Y) * SCALE + OFFSET_Y },
        { x: CENTER_X + (0.74 - CENTER_X) * SCALE + OFFSET_X, y: CENTER_Y + (0.72 - CENTER_Y) * SCALE + OFFSET_Y },
      ],
      links: [[0, 1], [1, 2]],
    },
  ];

  const positions = {};
  const links = [];
  let trackIndex = 0;

  patterns.forEach((pattern) => {
    const assignedIds = [];
    pattern.points.forEach((point) => {
      if (trackIndex >= tracks.length) return;
      const track = tracks[trackIndex];
      positions[track.id] = {
        x: point.x,
        y: point.y,
        altitude: 0.4 + track.pulseValue * 0.5,
      };
      assignedIds.push(track.id);
      trackIndex += 1;
    });
    pattern.assignedIds = assignedIds;
  });

  const leftovers = tracks.slice(trackIndex);
  leftovers.forEach((track, idx) => {
    const spread = leftovers.length > 1 ? idx / (leftovers.length - 1) : 0.5;
    positions[track.id] = {
      x: 0.24 + OFFSET_X + spread * 0.52,
      y: 0.78 + OFFSET_Y - 0.05 * (idx % 3),
      altitude: 0.35 + track.pulseValue * 0.4,
    };
  });

  patterns.forEach((pattern) => {
    pattern.links.forEach(([fromOffset, toOffset]) => {
      const fromId = pattern.assignedIds?.[fromOffset];
      const toId = pattern.assignedIds?.[toOffset];
      if (fromId && toId) {
        links.push([fromId, toId]);
      }
    });
  });

  return { positions, links, normalize: false };
}

function helixLayout(tracks) {
  const positions = {};
  const links = [];

  if (!tracks || tracks.length === 0) {
    return { positions, links };
  }

  const presetPositions = {
    "kopfkino": { x: 0.82, y: 0.14 },
    "green-light": { x: 0.64, y: 0.26 },
    "think-thrice": { x: 0.28, y: 0.12 },
    "cherry-tree": { x: 0.32, y: 0.38 },
    "reverie": { x: 0.56, y: 0.5 },
    "hold-on": { x: 0.74, y: 0.47 },
    "meteor": { x: 0.3, y: 0.7 },
    "diamonds": { x: 0.48, y: 0.8 },
    "pendant": { x: 0.54, y: 0.64 },
    "hinterland": { x: 0.76, y: 0.7 },
    "au-revoir": { x: 0.62, y: 0.9 },
  };

  const defaultPosition = { x: 0.5, y: 0.5 };

  tracks.forEach((track) => {
    const preset = presetPositions[track.id] ?? defaultPosition;
    const altitude = clamp01(0.4 + (track.pulseValue ?? 0.5) * 0.4);
    const depth = clamp01(0.25 + (1 - preset.y) * 0.5);

    positions[track.id] = {
      x: clamp01(preset.x),
      y: clamp01(preset.y),
      altitude,
      depth,
    };
  });

  const helixOrder = [
    "kopfkino",
    "green-light",
    "think-thrice",
    "cherry-tree",
    "meteor",
    "diamonds",
    "pendant",
    "reverie",
    "hold-on",
    "hinterland",
    "au-revoir",
  ].filter((id) => positions[id]);

  helixOrder.forEach((trackId, index) => {
    if (index === 0) return;
    links.push([helixOrder[index - 1], trackId]);
  });

  return { positions, links, normalize: false };
}

function scatterLayout(tracks) {
  const positions = {};
  const links = [];
  const { SEED, MIN_X, X_RANGE, MIN_Y, Y_RANGE } = LAYOUT.SCATTER;

  const pseudoRandom = (seed) => {
    let value = Math.sin(seed) * 10000;
    return (range = 1) => {
      value = Math.sin(value) * 10000;
      return (value - Math.floor(value)) * range;
    };
  };

  tracks.forEach((track, idx) => {
    const r = pseudoRandom(SEED + idx);
    let x = MIN_X + r(X_RANGE);
    let y = MIN_Y + r(Y_RANGE);

    if (track.id === "au-revoir") y += 0.15;

    positions[track.id] = {
      x: x,
      y: y,
      altitude: 0.4 + track.pulseValue * 0.4,
    };
  });

  const trackIds = Object.keys(positions);
  trackIds.forEach((id) => {
    const pos = positions[id];
    const distances = trackIds
      .filter(otherId => otherId !== id)
      .map(otherId => {
        const otherPos = positions[otherId];
        const dx = pos.x - otherPos.x;
        const dy = pos.y - otherPos.y;
        return { id: otherId, dist: Math.sqrt(dx * dx + dy * dy) };
      })
      .sort((a, b) => a.dist - b.dist);

    for (let i = 0; i < Math.min(2, distances.length); i++) {
      const link = [id, distances[i].id];
      const reverseExists = links.some(([a, b]) => a === distances[i].id && b === id);
      if (!reverseExists) {
        links.push(link);
      }
    }
  });

  return { positions, links };
}

function tempoSpiralLayout(tracks) {
  const positions = {};
  const links = [];
  if (!tracks.length) return { positions, links };

  const { START_RADIUS, RADIUS_GROWTH, TOTAL_ROTATIONS } = LAYOUT.TEMPO_SPIRAL;

  const sorted = [...tracks].sort((a, b) => {
    const bpmA = Number.isFinite(a.bpm) ? a.bpm : 0;
    const bpmB = Number.isFinite(b.bpm) ? b.bpm : 0;
    return bpmA - bpmB;
  });

  const minBpm = sorted.reduce(
    (min, track) => (Number.isFinite(track.bpm) ? Math.min(min, track.bpm) : min),
    Number.POSITIVE_INFINITY
  );
  const maxBpm = sorted.reduce(
    (max, track) => (Number.isFinite(track.bpm) ? Math.max(max, track.bpm) : max),
    Number.NEGATIVE_INFINITY
  );
  const bpmRange = maxBpm - minBpm || 1;

  sorted.forEach((track, idx) => {
    const progress = idx / Math.max(1, sorted.length - 1);
    const relativeBpm = Number.isFinite(track.bpm)
      ? (track.bpm - minBpm) / bpmRange
      : progress;

    const angle = progress * Math.PI * 2 * TOTAL_ROTATIONS;
    const radius = START_RADIUS + (progress * RADIUS_GROWTH * TOTAL_ROTATIONS);

    const x = clamp01(0.5 + Math.cos(angle) * radius);
    const y = clamp01(0.5 + Math.sin(angle) * radius);

    positions[track.id] = {
      x,
      y,
      altitude: 0.35 + relativeBpm * 0.5,
      depth: 0.3 + relativeBpm * 0.4,
      rotation: (angle * 180) / Math.PI,
    };

    if (idx > 0) links.push([sorted[idx - 1].id, track.id]);
  });

  const manualAdjustments = {
    pendant: { dx: 0.055, dy: 0 },
    meteor: { dx: 0, dy: 0.055 },
    diamonds: { dx: -0.06, dy: 0 },
    "cherry-tree": { dx: -0.05, dy: 0 },
  };

  Object.entries(manualAdjustments).forEach(([trackId, { dx, dy }]) => {
    const coords = positions[trackId];
    if (!coords) return;
    const adjustedX = clamp01(coords.x + dx);
    const adjustedY = clamp01(coords.y + (dy ?? 0));
    positions[trackId] = {
      ...coords,
      x: adjustedX,
      y: adjustedY,
    };
  });

  return { positions, links };
}

function getLayout(layoutId, tracks) {
  switch (layoutId) {
    case "helix":
      return helixLayout(tracks);
    case "scatter":
      return scatterLayout(tracks);
    case "tempo-spiral":
      return tempoSpiralLayout(tracks);
    case "constellations":
    default:
      return constellationLayout(tracks);
  }
}

// ============================================
// INITIALIZATION
// ============================================

const MOBILE_MEDIA_QUERY = '(max-width: 768px)';
const SWIPE_THRESHOLD = 40;
const MOBILE_VIEW_HINTS = {
  constellation: '↑↓ Layouts  ←→ Tracks',
  insight: '',
};

let player = null;
let resizeHandler = null;
let mobileMediaQuery = null;
let mobileMediaHandler = null;
let touchStartX = 0;
let touchStartY = 0;
let isTouching = false;

async function init() {
  console.log("🚀 Starmap Initializing (Modular)...");
  console.log("Location:", window.location.href);

  try {
    initializeDOM();

    if (DOM.starfieldCanvas) {
      const controller = createStarfieldController(DOM.starfieldCanvas);
      if (controller) {
        state.starfieldController = controller;
        controller.start();
      }
    }

    window.addEventListener('pointerdown', () => {
      state.lastNavigationMode = 'pointer';
      setKeyboardFocus(null);
    });

    resizeHandler = debounce(() => {
      invalidateCanvasBounds();
      if (state.starfieldController) {
        state.starfieldController.resize();
      }
      if (state.album) {
        applyLayout(state.layout);
      }
    }, CANVAS.RESIZE_DEBOUNCE);

    window.addEventListener("resize", resizeHandler);

    if (typeof ResizeObserver !== "undefined" && DOM.starmapSvg) {
      state.resizeObserver = new ResizeObserver(() => {
        invalidateCanvasBounds();
        scheduleLinksUpdateOnTransitionEnd();
      });
      state.resizeObserver.observe(DOM.starmapSvg);
    }

    // Ensure SVG has proper attributes for visibility
    if (DOM.starmapSvg) {
      DOM.starmapSvg.setAttribute('width', '100%');
      DOM.starmapSvg.setAttribute('height', '100%');
      DOM.starmapSvg.setAttribute('preserveAspectRatio', 'xMidYMid meet');
      console.log('📐 SVG initialized:', DOM.starmapSvg.getAttribute('viewBox'));
    }

    DOM.linkLayer = createSVGElement("g");
    DOM.linkLayer.classList.add("links-layer");
    DOM.starmapSvg.appendChild(DOM.linkLayer);

    DOM.nodeLayer = createSVGElement("g");
    DOM.nodeLayer.classList.add("nodes-layer");
    DOM.starmapSvg.appendChild(DOM.nodeLayer);

    DOM.gradientDefs = ensureGradientDefs(DOM.starmapSvg);

    console.log('📊 SVG layers created:', {
      linkLayer: !!DOM.linkLayer,
      nodeLayer: !!DOM.nodeLayer,
      gradientDefs: !!DOM.gradientDefs
    });

    setupKeyboardNavigation();
    setupMobileSupport();

    await loadAlbum();
    setupLayoutControls();
    setupModals();
    await setupAudioPlayer();

    console.log("✅ Starmap initialized successfully");
  } catch (error) {
    console.error("❌ Initialization failed:", error);
    showUserError("Failed to initialize application. Please refresh the page.");
  }
}

// ============================================
// ALBUM LOADING
// ============================================

async function loadAlbum() {
  try {
    const response = await fetch("data/album.json");

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    const album = await response.json();
    const errors = validateAlbum(album);
    if (errors.length > 0) {
      console.warn("⚠️ Album validation issues:", errors);
    }

    album.tracks = album.tracks.map(sanitizeTrack);

    const defaultTrack =
      album.tracks.find((track) => track.id === "kopfkino") ??
      album.tracks.find((track) => normalizeSoundUrl(track.soundcloudId)) ??
      album.tracks[0];

    if (!defaultTrack) {
      throw new Error("No valid tracks found in album");
    }

    setAlbum(album);
    await initializeSoundCloudEmbed(defaultTrack);
    renderAllNodes(album.tracks);
    applyLayout(state.layout);
    setInitialTrack(defaultTrack);

    // Initialize mobile tracklist if on mobile
    if (state.isMobile) {
      const activeId = state.playingId ?? state.defaultTrackId;
      initMobileTracklist(album.tracks, handleTrackSelection, activeId);
    }

    console.log("✅ Album loaded:", album.tracks.length, "tracks");
  } catch (error) {
    console.error("❌ Failed to load album:", error);
    showUserError("Could not load album data. Please refresh the page.");
    throw error;
  }
}

// ============================================
// NODE RENDERING
// ============================================

function renderAllNodes(tracks) {
  if (!DOM.nodeLayer || !DOM.gradientDefs) return;

  cleanupAllNodes();
  clearNodes();

  if (DOM.gradientDefs) {
    DOM.gradientDefs.textContent = "";
  }

  const handlers = {
    onSelect: (trackId) => handleTrackSelection(trackId),
    onHover: (track) => updateMeta(track),
    onFocus: (track) => handleNodeFocus(track),
    onBlur: (track) => handleNodeBlur(track),
  };

  tracks.forEach((track, index) => {
    const nodeData = createNode(track, index, DOM.gradientDefs, handlers);
    setNode(track.id, nodeData);
    DOM.nodeLayer.appendChild(nodeData.group);
  });

  console.log("✅ Rendered", tracks.length, "nodes to", DOM.nodeLayer);
}

// ============================================
// LAYOUT APPLICATION
// ============================================

function applyLayout(layoutId) {
  if (!state.album) return;

  state.layout = layoutId;
  setActiveLayoutButton(layoutId);

  const { tracks } = state.album;
  const layout = getLayout(layoutId, tracks);

  const shouldNormalize =
    layout && Object.prototype.hasOwnProperty.call(layout, "normalize")
      ? layout.normalize !== false
      : true;

  const positions = shouldNormalize
    ? normalizePositions(layout.positions)
    : layout.positions || {};

  state.positions = positions;

  renderLinks(layout.links || []);

  const bounds = getCachedBounds();
  if (!bounds) {
    console.warn('⚠️ No canvas bounds available');
    return;
  }

  const { width, height } = bounds;
  console.log('📏 Canvas bounds:', { width, height });

  const isInitialLoad = !state.hasLoadedOnce;
  if (isInitialLoad) {
    state.hasLoadedOnce = true;
    console.log('🎬 Initial load - animating nodes');
  }

  let positionedCount = 0;
  let maxMovementDuration = 0;
  const transitioningGroups = [];

  tracks.forEach((track, index) => {
    const nodeData = getNode(track.id);
    if (!nodeData) return;

    const coords = positions[track.id];
    if (!coords) return;

    const { group, ring } = nodeData;

    group.style.setProperty(
      "--depth",
      coords.depth != null ? coords.depth : 0
    );

    const x = mapToCanvasX(coords.x, width);
    const y = mapToCanvasY(coords.y, height);

    positionedCount++;
    if (index === 0) {
      console.log('🎯 First node positioned:', { x, y, coords, width, height });
    }

    group.dataset.x = String(x);
    group.dataset.y = String(y);

    const haloScale = 0.9 + coords.altitude * 0.2;
    ring.style.transform = `scale(${haloScale})`;

    if (isInitialLoad) {
      const fadeInDelay = index * ANIMATION.FADE_IN_STAGGER;
      const nodeRevealTime = fadeInDelay + ANIMATION.OPACITY_TRANSITION;
      if (nodeRevealTime > maxMovementDuration) {
        maxMovementDuration = nodeRevealTime;
      }

      group.style.setProperty("--stagger-delay", "0ms");
      group.style.transition = "none";
      group.style.transform = `translate(${x}px, ${y}px)`;
      group.setAttribute("transform", `translate(${x} ${y})`);
      group.style.transformOrigin = `${x}px ${y}px`;

      group.getBoundingClientRect();

      requestAnimationFrame(() => {
        group.style.transition = "";
        group.style.setProperty("--stagger-delay", `${fadeInDelay}ms`);
        group.classList.add("track-node--loaded");
      });
    } else {
      const staggerDelay = index * ANIMATION.LAYOUT_CHANGE_STAGGER;
      const distanceFromCenter = Math.sqrt(
        Math.pow(coords.x - 0.5, 2) + Math.pow(coords.y - 0.5, 2)
      );
      const radiusDelay = distanceFromCenter * ANIMATION.RADIAL_DELAY_MULTIPLIER;

      group.style.setProperty("--stagger-delay", `${staggerDelay}ms`);
      group.style.setProperty("--radius-delay", `${radiusDelay}ms`);
      group.style.transform = `translate(${x}px, ${y}px)`;
      group.setAttribute("transform", `translate(${x} ${y})`);
      group.style.transformOrigin = `${x}px ${y}px`;

      const movementEnd = staggerDelay + ANIMATION.TRANSITION_DURATION;
      if (movementEnd > maxMovementDuration) {
        maxMovementDuration = movementEnd;
      }

      transitioningGroups.push(group);
    }
  });

  requestAnimationFrame(() => {
    requestAnimationFrame(() => {
      updateAllLinkPositions();
    });
  });
  scheduleLinksUpdateOnTransitionEnd();

  const revealBuffer = 200;
  const fallbackDelay = Math.max(0, maxMovementDuration) + revealBuffer;

  if (isInitialLoad) {
    revealLinks(fallbackDelay);
  } else {
    let revealTriggered = false;
    const transitionListeners = [];
    let fallbackTimer = null;

    const clearFallbackTimer = () => {
      if (fallbackTimer !== null) {
        window.clearTimeout(fallbackTimer);
        fallbackTimer = null;
      }
    };

    const triggerReveal = () => {
      if (revealTriggered) return;
      revealTriggered = true;
      clearFallbackTimer();
      transitionListeners.forEach(({ group, handler }) => {
        group.removeEventListener("transitionend", handler);
      });
      revealLinks(revealBuffer);
    };

    if (transitioningGroups.length === 0) {
      triggerReveal();
    } else {
      let remaining = transitioningGroups.length;
      fallbackTimer = window.setTimeout(triggerReveal, fallbackDelay);
      transitioningGroups.forEach((group) => {
        const handler = (event) => {
          if (event.propertyName !== "transform") return;
          group.removeEventListener("transitionend", handler);
          remaining -= 1;
          if (remaining <= 0) {
            triggerReveal();
          }
        };
        transitionListeners.push({ group, handler });
        group.addEventListener("transitionend", handler);
      });
    }
  }

  console.log("✅ Applied layout:", layoutId, `(${positionedCount}/${tracks.length} nodes positioned)`);
}

function setActiveLayoutButton(layoutId) {
  DOM.layoutButtons.forEach((btn) => {
    btn.classList.toggle("is-active", btn.dataset.layout === layoutId);
  });
  updateMobileLayoutLabel();
}

function setupLayoutControls() {
  DOM.layoutButtons.forEach((button) => {
    button.addEventListener("click", () => {
      const targetLayout = button.dataset.layout;
      if (!targetLayout || targetLayout === state.layout) return;
      applyLayout(targetLayout);
    });
  });
}

// ============================================
// SOUNDCLOUD INITIALIZATION
// ============================================

async function initializeSoundCloudEmbed(track) {
  if (!track) return;
  const normalized = normalizeSoundUrl(track.soundcloudId);
  if (!normalized) return;

  if (DOM.scWidget) {
    DOM.scWidget.setAttribute("src", createWidgetSrc(normalized, false));
  }

  state.pendingTrack = {
    url: normalized,
    autoPlay: false,
  };

  state.currentTrackUrl = normalized;
  resetProgressUI();
}

async function setupAudioPlayer() {
  if (!DOM.scWidget) {
    console.warn("SoundCloud widget iframe not found");
    showUserError("Audio player not available");
    return;
  }

  await waitForSoundCloudAPI();

  player = new SoundCloudPlayer(DOM.scWidget);
  await player.ensureReady();
  state.widget = player.widget;
  state.widgetReady = true;

  if (state.pendingTrack?.url) {
    const { url, autoPlay } = state.pendingTrack;
    state.pendingTrack = null;
    await player.load(url, { autoPlay });
    state.currentTrackUrl = url;
    await updateDurationDisplay();
  } else {
    await updateDurationDisplay();
  }

  DOM.playPauseBtn?.addEventListener("click", async () => {
    if (!player) return;
    const paused = await player.togglePlayPause();
    if (!paused) {
      setActiveNode(state.playingId);
    } else {
      setPlayingState(state.playingId, false);
    }
  });

  if (player) {
    player.on("PLAY", () => {
      DOM.customPlayer?.classList.add("is-playing");
      setPlayingState(state.playingId, true);
    });

    player.on("PAUSE", () => {
      DOM.customPlayer?.classList.remove("is-playing");
      setPlayingState(state.playingId, false);
    });

    player.on("FINISH", () => {
      const finishedId = state.playingId;
      setPlayingState(finishedId, false);
      setActiveNode(null);
      DOM.customPlayer?.classList.remove("is-playing");
      resetProgressUI();
    });

    player.on("PLAY_PROGRESS", (event) => {
      const fraction = clamp01(
        typeof event.relativePosition === "number" && !Number.isNaN(event.relativePosition)
          ? event.relativePosition
          : event.duration
          ? event.currentPosition / event.duration
          : 0
      );
      setProgressUI(fraction);
      if (DOM.currentTimeEl) DOM.currentTimeEl.textContent = formatTime(event.currentPosition / 1000);
    });

    player.on("ERROR", (error) => {
      console.error("SoundCloud Widget Error:", error);
      showUserError("Unable to load track");
    });
  }

  setupProgressBar();
  console.log("✅ Audio player ready");
}

function setupProgressBar() {
  if (!DOM.progressBar || !player) return;

  let isSeeking = false;

  const seek = async (e) => {
    if (!player) return;
    const rect = DOM.progressBar.getBoundingClientRect();
    const percent = clamp01((e.clientX - rect.left) / rect.width);
    setProgressUI(percent);
    try {
      const duration = await player.getDuration();
      await player.seekTo(percent * duration);
    } catch (error) {
      console.error("Seek error:", error);
    }
  };

  DOM.progressBar.addEventListener("mousedown", (e) => {
    isSeeking = true;
    DOM.progressBar.classList.add("is-seeking");
    seek(e);
  });

  window.addEventListener("mousemove", (e) => {
    if (isSeeking) seek(e);
  });

  window.addEventListener("mouseup", () => {
    if (isSeeking) {
      isSeeking = false;
      DOM.progressBar.classList.remove("is-seeking");
    }
  });

  DOM.progressBar.addEventListener("click", seek);
}

function setProgressUI(fraction) {
  const clamped = clamp01(fraction);
  const percent = clamped * 100;
  if (DOM.progressFill) {
    DOM.progressFill.style.setProperty("--progress-percent", `${percent}%`);
    DOM.progressFill.style.opacity = clamped > 0 ? "1" : "0.4";
  }
  if (DOM.progressHandle) DOM.progressHandle.style.left = `${percent}%`;
}

function resetProgressUI() {
  setProgressUI(0);
  if (DOM.currentTimeEl) DOM.currentTimeEl.textContent = "0:00";
}

async function updateDurationDisplay() {
  if (!player || !DOM.durationEl) return;
  try {
    const duration = await player.getDuration();
    DOM.durationEl.textContent = formatTime(duration / 1000);
  } catch (error) {
    console.error("Duration display error:", error);
  }
}

// ============================================
// TRACK INTERACTION
// ============================================

function setInitialTrack(track) {
  if (!track) return;

  state.defaultTrackId = track.id;

  if (DOM.trackTitleEl) {
    DOM.trackTitleEl.textContent = track.title;
  }

  updateMeta(track, true);
  DOM.metaPanel?.classList.add("is-active");

  updateMobileTrackLabel(track.title);

  if (DOM.durationEl && track.duration) {
    DOM.durationEl.textContent = track.duration;
  }
}

function handleTrackSelection(trackId) {
  const nodeData = getNode(trackId);
  if (!nodeData) return;
  const { track } = nodeData;
  updateMeta(track, true);
  toggleTrackPlayback(trackId);

  // Update mobile tracklist playing state
  if (state.isMobile) {
    updatePlayingCard(trackId);
  }
}

function handleNodeFocus(track) {
  if (!track) return;
  if (state.lastNavigationMode === "keyboard") {
    setKeyboardFocus(track.id);
    playTrackImmediately(track.id, { forceMeta: true });
  } else {
    setKeyboardFocus(null);
    updateMeta(track);
  }
}

function handleNodeBlur(track) {
  if (!track) return;
  if (state.keyboardFocusId === track.id) {
    setKeyboardFocus(null);
  }
}

async function toggleTrackPlayback(trackId) {
  if (!player) return;

  const isCurrentTrack = state.playingId === trackId;

  if (isCurrentTrack) {
    try {
      const paused = await player.togglePlayPause();
      if (!paused) {
        setActiveNode(trackId);
      } else {
        setPlayingState(trackId, false);
      }
    } catch (error) {
      console.error("Toggle playback error:", error);
    }
  } else {
    setActiveNode(trackId);
    setPlayingState(null, false);
    await playTrack(trackId);
  }
}

async function playTrack(trackId) {
  const nodeData = getNode(trackId);
  if (!nodeData) return;

  const { track } = nodeData;
  const sanitized = normalizeSoundUrl(track.soundcloudId);
  if (!sanitized) {
    console.warn("Invalid SoundCloud ID:", track.soundcloudId);
    return;
  }

  if (DOM.trackTitleEl) {
    DOM.trackTitleEl.textContent = track.title;
  }

  resetProgressUI();

  try {
    if (player && state.widgetReady) {
      if (sanitized === state.currentTrackUrl) {
        const paused = await player.isPaused();
        if (paused) {
          await player.play();
        }
        return;
      }

      state.pendingTrack = null;
      await player.load(sanitized, { autoPlay: true });
      state.currentTrackUrl = sanitized;
      await updateDurationDisplay();
    } else {
      state.pendingTrack = { url: sanitized, autoPlay: true };
      if (DOM.scWidget) {
        const src = createWidgetSrc(sanitized, true);
        DOM.scWidget.setAttribute("src", src);
      }
    }
  } catch (error) {
    console.error("❌ Failed to play track:", error);
    showUserError("Unable to load track. Please try another.");
  }
}

function playTrackImmediately(trackId, { forceMeta = false } = {}) {
  if (!trackId) return;

  const nodeData = getNode(trackId);
  if (!nodeData) return;

  setPlayingState(null, false);
  setActiveNode(trackId);
  playTrack(trackId);

  if (forceMeta || nodeData.track) {
    updateMeta(nodeData.track, { persistent: true, force: forceMeta });
  }
}

function stepThroughTracks(direction) {
  if (!state.trackOrder.length || !Number.isFinite(direction)) return;

  const currentId = getCurrentTrackId();
  const order = state.trackOrder;
  const currentIndex = currentId ? order.indexOf(currentId) : -1;
  const normalizedIndex = currentIndex >= 0 ? currentIndex : 0;
  const nextIndex = (normalizedIndex + direction + order.length) % order.length;
  const nextId = order[nextIndex];

  if (!nextId || nextId === currentId) return;

  playTrackImmediately(nextId, { forceMeta: true });
}

function setActiveNode(trackId) {
  let focusTarget = null;

  state.nodes.forEach(({ group }, id) => {
    const isTarget = id === trackId;
    group.classList.toggle("is-active", isTarget);

    if (isTarget) {
      focusTarget = group;
    } else if (state.lastNavigationMode === "keyboard" && group === document.activeElement) {
      if (typeof group.blur === 'function') {
        group.blur();
      }
    }
  });

  if (focusTarget && state.lastNavigationMode === "keyboard") {
    if (typeof focusTarget.focus === 'function') {
      focusTarget.focus({ preventScroll: true });
    }
  }

  if (state.lastNavigationMode === 'keyboard') {
    setKeyboardFocus(trackId);
  } else {
    setKeyboardFocus(null);
  }

  state.playingId = trackId;

  if (state.isMobile) {
    updatePlayingCard(trackId ?? null);
  }

  const nodeData = trackId ? getNode(trackId) : null;
  if (nodeData?.track) {
    updateMobileTrackLabel(nodeData.track.title);
  }
}

function setPlayingState(trackId, isPlaying) {
  state.nodes.forEach(({ group }, id) => {
    const shouldGlow = Boolean(isPlaying && trackId && id === trackId);
    group.classList.toggle("is-playing", shouldGlow);
  });
  state.isPlaying = Boolean(isPlaying && trackId);
}

// ============================================
// METADATA DISPLAY
// ============================================

function updateMeta(track, persistent = false) {
  if (!track || !DOM.metaPanel) return;

  const options =
    typeof persistent === "object"
      ? { persistent: Boolean(persistent.persistent), force: Boolean(persistent.force) }
      : { persistent: Boolean(persistent), force: false };
  const { persistent: persistFlag, force } = options;

  const existingTitle = DOM.metaPanel.querySelector("h3");
  const existingDl = DOM.metaPanel.querySelector("dl");
  const newTitle = track.title;

  if (
    !force &&
    state.currentMetaTrackId === track.id &&
    existingDl &&
    existingTitle?.textContent === newTitle &&
    DOM.metaPanel.classList.contains("is-active")
  ) {
    return;
  }

  const displayKey = track.key.replace(/♭/g, 'b');

  const metaEntries = [
    { label: "Duration", value: track.duration ?? "—" },
    { label: "BPM", value: Number.isFinite(track.bpm) ? track.bpm : "—" },
    { label: "Key", value: displayKey ?? "—" },
    {
      label: "Focus",
      value:
        track.focus && Number.isFinite(track.focusValue)
          ? `${track.focus} (${Math.round(track.focusValue * 100)}%)`
          : track.focus ?? "—",
    },
    {
      label: "Pulse",
      value:
        track.pulse && Number.isFinite(track.pulseValue)
          ? `${track.pulse} (${Math.round(track.pulseValue * 100)}%)`
          : track.pulse ?? "—",
    },
    {
      label: "Track",
      value: track.trackNumber != null ? track.trackNumber : "—",
    },
  ];

  const newValues = metaEntries.map((entry) => String(entry.value));

  if (existingDl) {
    const ddElements = existingDl.querySelectorAll("dd");

    if (existingTitle) existingTitle.style.opacity = "0";
    ddElements.forEach((dd) => {
      dd.style.opacity = "0";
    });

    if (ddElements.length === metaEntries.length) {
      setTimeout(() => {
        if (existingTitle) {
          existingTitle.textContent = newTitle;
          existingTitle.style.opacity = "1";
        }
        ddElements.forEach((dd, index) => {
          dd.textContent = newValues[index];
          dd.style.opacity = "1";
        });
      }, ANIMATION.META_FADE_DURATION);
    } else {
      DOM.metaPanel.innerHTML = createMetaMarkup(newTitle, metaEntries);
    }
  } else {
    DOM.metaPanel.innerHTML = createMetaMarkup(newTitle, metaEntries);
  }

  DOM.metaPanel.classList.add("is-active");
  state.currentMetaTrackId = track.id;

  updateMobileTrackLabel(track.title);

  if (!persistFlag) {
    setTimeout(() => {
      if (state.playingId !== track.id) {
        DOM.metaPanel.classList.remove("is-active");
      }
    }, ANIMATION.META_AUTO_HIDE_DELAY);
  }
}

function createMetaMarkup(title, entries) {
  const dlContent = entries
    .map(
      ({ label, value }) =>
        `<div><dt>${label}</dt><dd>${String(value)}</dd></div>`
    )
    .join("");

  return `<h3>${title}</h3><dl>${dlContent}</dl>`;
}

// ============================================
// KEYBOARD NAVIGATION
// ============================================

function setupKeyboardNavigation() {
  document.addEventListener("keydown", (e) => {
    if (["INPUT", "TEXTAREA"].includes(e.target.tagName)) return;
    if (document.querySelector(".about-overlay.is-open, .guide-overlay.is-open")) return;

    if (e.key === "Tab") {
      state.lastNavigationMode = "keyboard";
    } else if (["ArrowLeft", "ArrowRight", "Space", "ArrowUp", "ArrowDown"].includes(e.key)) {
      state.lastNavigationMode = "keyboard";
    }

    switch (e.key) {
      case " ":
      case "Spacebar": {
        e.preventDefault();
        toggleTrackPlayback(state.playingId ?? state.defaultTrackId ?? state.trackOrder[0] ?? null);
        break;
      }
      case "ArrowRight": {
        e.preventDefault();
        stepThroughTracks(1);
        break;
      }
      case "ArrowLeft": {
        e.preventDefault();
        stepThroughTracks(-1);
        break;
      }
      case "ArrowUp": {
        e.preventDefault();
        cycleLayout(-1);
        break;
      }
      case "ArrowDown": {
        e.preventDefault();
        cycleLayout(1);
        break;
      }
      default:
        break;
    }
  });
}

function cycleLayout(direction) {
  if (!state.album) return;

  const layouts = ["constellations", "helix", "scatter", "tempo-spiral"];
  const currentIndex = layouts.indexOf(state.layout);
  const normalizedIndex = currentIndex === -1 ? 0 : currentIndex;
  const nextIndex = (normalizedIndex + direction + layouts.length) % layouts.length;
  const nextLayout = layouts[nextIndex];

  if (nextLayout && nextLayout !== state.layout) {
    applyLayout(nextLayout);
  }
}

// ============================================
// MODALS
// ============================================

function setupModals() {
  setupAboutModal();
  setupGuideModal();
}

function setupAboutModal() {
  if (!DOM.aboutOverlay) return;

  function openAbout() {
    DOM.aboutOverlay.classList.add("is-open");
    document.body.style.overflow = "hidden";
  }

  function closeAbout() {
    DOM.aboutOverlay.classList.remove("is-open");
    document.body.style.overflow = "";
  }

  // Wire up both header and footer about buttons
  const aboutButtons = [
    DOM.aboutButton,
    document.getElementById('footer-about-button')
  ].filter(Boolean);

  aboutButtons.forEach(btn => {
    btn.addEventListener("click", openAbout);
  });

  DOM.aboutClose?.addEventListener("click", closeAbout);
  DOM.aboutBackdrop?.addEventListener("click", closeAbout);

  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape" && DOM.aboutOverlay.classList.contains("is-open")) {
      closeAbout();
    }
  });
}

function setupGuideModal() {
  if (!DOM.guideOverlay) return;

  function openGuide() {
    DOM.guideOverlay.classList.add("is-open");
    document.body.style.overflow = "hidden";
  }

  function closeGuide() {
    DOM.guideOverlay.classList.remove("is-open");
    document.body.style.overflow = "";
  }

  // Wire up both header and footer guide buttons
  const guideButtons = [
    DOM.guideButton,
    document.getElementById('footer-guide-button')
  ].filter(Boolean);

  guideButtons.forEach(btn => {
    btn.addEventListener("click", openGuide);
  });

  DOM.guideClose?.addEventListener("click", closeGuide);
  DOM.guideBackdrop?.addEventListener("click", closeGuide);

  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape" && DOM.guideOverlay.classList.contains("is-open")) {
      closeGuide();
    }
  });
}

// ============================================
// CLEANUP
// ============================================

function cleanupResources() {
  if (resizeHandler) {
    window.removeEventListener("resize", resizeHandler);
    resizeHandler = null;
  }

  if (mobileMediaQuery && mobileMediaHandler) {
    if (mobileMediaQuery.removeEventListener) {
      mobileMediaQuery.removeEventListener('change', mobileMediaHandler);
    } else {
      mobileMediaQuery.removeListener(mobileMediaHandler);
    }
  }

  if (DOM.main) {
    DOM.main.removeEventListener('touchstart', handleTouchStart);
    DOM.main.removeEventListener('touchend', handleTouchEnd);
  }

  if (state.resizeObserver) {
    state.resizeObserver.disconnect();
    state.resizeObserver = null;
  }

  cancelPendingLinkUpdates();
  cleanupAllNodes();

  if (player) {
    player.cleanup();
  }

  console.log("✅ Resources cleaned up");
}

window.addEventListener("beforeunload", cleanupResources);
window.addEventListener("pagehide", cleanupResources);

// ============================================
// START APPLICATION
// ============================================

window.addEventListener("load", () => {
  init().catch(error => {
    console.error("❌ Fatal initialization error:", error);
    showUserError("Application failed to start. Please refresh the page.");
  });
});

console.log("✅ Starmap modular entry loaded");

// ============================================
// MOBILE SUPPORT
// ============================================

function setupMobileSupport() {
  if (!window.matchMedia) return;

  mobileMediaQuery = window.matchMedia(MOBILE_MEDIA_QUERY);
  mobileMediaHandler = (event) => {
    setMobileMode(event.matches);
  };

  if (mobileMediaQuery.addEventListener) {
    mobileMediaQuery.addEventListener('change', mobileMediaHandler);
  } else {
    mobileMediaQuery.addListener(mobileMediaHandler);
  }

  setMobileMode(mobileMediaQuery.matches);

  if (DOM.mobileViewButtons?.length) {
    DOM.mobileViewButtons.forEach((button) => {
      button.addEventListener('click', () => {
        if (!state.isMobile) return;
        const targetView = button.dataset.view === 'insight' ? 'insight' : 'constellation';
        setMobileView(targetView, { userInitiated: true });
      });
    });
  }

  DOM.mobileTrackPrev?.addEventListener('click', () => {
    if (!state.isMobile) return;
    stepThroughTracks(-1);
  });
  DOM.mobileTrackNext?.addEventListener('click', () => {
    if (!state.isMobile) return;
    stepThroughTracks(1);
  });
  DOM.mobileLayoutPrev?.addEventListener('click', () => {
    if (!state.isMobile) return;
    cycleLayout(-1);
  });
  DOM.mobileLayoutNext?.addEventListener('click', () => {
    if (!state.isMobile) return;
    cycleLayout(1);
  });

  if (DOM.main) {
    DOM.main.addEventListener('touchstart', handleTouchStart, { passive: true });
    DOM.main.addEventListener('touchend', handleTouchEnd, { passive: true });
  }
}

function setMobileMode(isMobile) {
  state.isMobile = Boolean(isMobile);
  document.body.classList.toggle('is-mobile', state.isMobile);

  if (state.isMobile) {
    // Mobile is constellation-only, always force constellation view
    state.mobileView = 'constellation';
    updateMobileLayoutLabel();

    if (state.album) {
      const activeId = state.playingId ?? state.defaultTrackId;
      initMobileTracklist(state.album.tracks, handleTrackSelection, activeId);
    }
  } else {
    document.body.classList.remove('mobile-view-constellation', 'mobile-view-insight');
  }
}

function setMobileView(view, { userInitiated = false } = {}) {
  const normalized = view === 'insight' ? 'insight' : 'constellation';
  state.mobileView = normalized;

  if (!state.isMobile) {
    return;
  }

  document.body.classList.toggle('mobile-view-constellation', normalized === 'constellation');
  document.body.classList.toggle('mobile-view-insight', normalized === 'insight');

  if (DOM.mobileViewButtons?.length) {
    DOM.mobileViewButtons.forEach((button) => {
      const isActive = button.dataset.view === normalized;
      button.classList.toggle('is-active', isActive);
      button.setAttribute('aria-selected', String(isActive));
    });
  }

  if (DOM.mobileViewHint) {
    DOM.mobileViewHint.textContent = MOBILE_VIEW_HINTS[normalized] ?? '';
  }

  if (userInitiated && normalized === 'constellation') {
    state.lastNavigationMode = 'pointer';
  }
}

function updateMobileLayoutLabel() {
  if (!DOM.mobileLayoutLabel) return;
  const activeButton = DOM.layoutButtons.find((btn) => btn.classList.contains('is-active'));
  if (activeButton) {
    DOM.mobileLayoutLabel.textContent = activeButton.textContent.trim();
  }
}

function updateMobileTrackLabel(title) {
  if (!DOM.mobileTrackLabel || !title) return;
  DOM.mobileTrackLabel.textContent = title;
}

function setKeyboardFocus(trackId) {
  state.keyboardFocusId = trackId;
  state.nodes.forEach(({ group }, id) => {
    group.classList.toggle('is-key-focus', trackId != null && id === trackId);
  });
}

function handleTouchStart(event) {
  if (!state.isMobile) return;
  const touch = event.changedTouches[0];
  touchStartX = touch.clientX;
  touchStartY = touch.clientY;
  isTouching = true;
}

function handleTouchEnd(event) {
  if (!state.isMobile || !isTouching) return;
  const touch = event.changedTouches[0];
  const deltaX = touch.clientX - touchStartX;
  const deltaY = touch.clientY - touchStartY;
  isTouching = false;

  if (Math.abs(deltaX) < SWIPE_THRESHOLD && Math.abs(deltaY) < SWIPE_THRESHOLD) {
    return;
  }

  // Horizontal swipe - track navigation
  if (Math.abs(deltaX) > Math.abs(deltaY)) {
    if (deltaX > 0) {
      stepThroughTracks(-1);
    } else {
      stepThroughTracks(1);
    }
  }
  // Vertical swipe - layout navigation only (no insight view on mobile)
  else {
    if (deltaY > 0) {
      // Swipe down - previous layout
      cycleLayout(-1);
    } else {
      // Swipe up - next layout
      cycleLayout(1);
    }
  }
}

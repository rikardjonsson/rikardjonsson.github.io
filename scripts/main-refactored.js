// ============================================
// STARMAP - REFACTORED MAIN
// ============================================
// Clean, modular architecture using ES6 modules

import { CANVAS, ANIMATION, AUDIO } from './constants.js';
import {
  formatTime,
  normalizeSoundUrl,
  createSVGElement,
  ensureGradientDefs,
  debounce,
  showUserError
} from './utils.js';
import { validateAlbum, sanitizeTrack } from './validation.js';
import {
  DOM,
  state,
  initializeDOM,
  setAlbum,
  getNode,
  setNode,
  getCurrentTrackId,
  getCachedBounds,
  invalidateCanvasBounds
} from './dom-cache.js';
import {
  SoundCloudPlayer,
  createWidgetSrc,
  waitForSoundCloudAPI
} from './soundcloud-player.js';
import {
  createNode,
  updateNode,
  cleanupNode,
  cleanupAllNodes
} from './node-renderer.js';
import {
  renderLinks,
  updateAllLinkPositions,
  scheduleLinksUpdateOnTransitionEnd,
  cancelPendingLinkUpdates,
  mapToCanvasX,
  mapToCanvasY
} from './link-renderer.js';
import { normalizePositions } from './layouts/layout-base.js';
import { LAYOUT } from './constants.js';

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

  // Leftover tracks
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
  const total = tracks.length;

  tracks.forEach((track, idx) => {
    const progress = idx / total;
    const angle = progress * Math.PI * 4;
    const depth = Math.sin(angle) * 0.5 + 0.5;
    const radius = 0.18 + track.pulseValue * 0.14;

    let y = 0.25 + progress * 0.5;
    if (track.id === "hinterland") y += 0.08;
    else if (track.id === "think-thrice") y -= 0.08;

    positions[track.id] = {
      x: 0.5 + Math.cos(angle) * (radius + 0.2),
      y: y,
      altitude: depth,
      depth,
    };

    if (idx > 0) links.push([tracks[idx - 1].id, track.id]);
  });

  return { positions, links };
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

  // Connect nearest neighbors
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

    const clamp01 = (v) => Math.min(1, Math.max(0, v));
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

async function init() {
  console.log("🚀 Starmap Initializing (Refactored)...");
  console.log("Location:", window.location.href);

  try {
    // Initialize DOM cache
    initializeDOM();

    // Setup resize handling
    const handleResize = debounce(() => {
      invalidateCanvasBounds();
      if (state.album) {
        applyLayout(state.layout);
      }
    }, 100);

    window.addEventListener("resize", handleResize);

    // Setup ResizeObserver for canvas
    if (typeof ResizeObserver !== "undefined" && DOM.starmapSvg) {
      state.resizeObserver = new ResizeObserver(() => {
        invalidateCanvasBounds();
        scheduleLinksUpdateOnTransitionEnd();
      });
      state.resizeObserver.observe(DOM.starmapSvg);
    }

    // Initialize SVG layers
    DOM.linkLayer = createSVGElement("g");
    DOM.linkLayer.classList.add("links-layer");
    DOM.starmapSvg.appendChild(DOM.linkLayer);

    DOM.nodeLayer = createSVGElement("g");
    DOM.nodeLayer.classList.add("nodes-layer");
    DOM.starmapSvg.appendChild(DOM.nodeLayer);

    DOM.gradientDefs = ensureGradientDefs(DOM.starmapSvg);

    // Setup keyboard navigation
    setupKeyboardNavigation();

    // Load album and setup
    await loadAlbum();
    setupLayoutControls();
    await setupAudioPlayer();
    setupModals();

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

    // Validate album data
    const errors = validateAlbum(album);
    if (errors.length > 0) {
      console.warn("⚠️ Album validation issues:", errors);
    }

    // Sanitize tracks
    album.tracks = album.tracks.map(sanitizeTrack);

    // Find default track
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

  // Clean up existing nodes
  cleanupAllNodes();

  // Clear gradient defs
  if (DOM.gradientDefs) {
    DOM.gradientDefs.textContent = "";
  }

  // Create event handlers
  const handlers = {
    onSelect: (trackId) => handleTrackSelection(trackId),
    onHover: (track) => updateMeta(track),
    onFocus: (track) => handleNodeFocus(track),
  };

  // Create all nodes
  tracks.forEach((track, index) => {
    const nodeData = createNode(track, index, DOM.gradientDefs, handlers);
    setNode(track.id, nodeData);
    DOM.nodeLayer.appendChild(nodeData.group);
  });

  console.log("✅ Rendered", tracks.length, "nodes");
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

  // Render links
  renderLinks(layout.links || []);

  const bounds = getCachedBounds();
  if (!bounds) return;

  const { width, height } = bounds;

  // Detect initial load vs layout change
  const isInitialLoad = !state.hasLoadedOnce;
  if (isInitialLoad) {
    state.hasLoadedOnce = true;
  }

  // Position all nodes
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

    group.dataset.x = String(x);
    group.dataset.y = String(y);

    const haloScale = 0.9 + coords.altitude * 0.2;
    ring.style.transform = `scale(${haloScale})`;

    if (isInitialLoad) {
      // Initial load: position immediately, then fade in
      group.style.setProperty("--stagger-delay", "0ms");
      group.style.transition = "none";
      group.style.transform = `translate(${x}px, ${y}px)`;
      group.setAttribute("transform", `translate(${x} ${y})`);
      group.style.transformOrigin = `${x}px ${y}px`;

      group.getBoundingClientRect(); // Force reflow

      requestAnimationFrame(() => {
        const fadeInDelay = index * ANIMATION.FADE_IN_STAGGER;
        group.style.transition = "";
        group.style.setProperty("--stagger-delay", `${fadeInDelay}ms`);
        group.classList.add("track-node--loaded");
      });
    } else {
      // Layout change: animate
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
    }
  });

  // Update link positions after layout
  scheduleLinksUpdateOnTransitionEnd();

  console.log("✅ Applied layout:", layoutId);
}

function setActiveLayoutButton(layoutId) {
  DOM.layoutButtons.forEach((btn) => {
    btn.classList.toggle("is-active", btn.dataset.layout === layoutId);
  });
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
// AUDIO PLAYER
// ============================================

let player = null;

async function initializeSoundCloudEmbed(track) {
  if (!track) return;

  const normalized = normalizeSoundUrl(track.soundcloudId);
  if (!normalized) {
    console.warn("No valid SoundCloud ID for track:", track.title);
    return;
  }

  // Set iframe src
  const iframe = DOM.scWidget;
  if (iframe) {
    const src = createWidgetSrc(normalized, false);
    iframe.setAttribute("src", src);
  }

  state.pendingTrack = {
    url: normalized,
    autoPlay: false,
  };

  resetProgressUI();
}

async function setupAudioPlayer() {
  try {
    // Wait for SoundCloud API to load
    await waitForSoundCloudAPI();

    // Create player
    player = new SoundCloudPlayer(DOM.scWidget);
    await player.initialize();

    state.widget = player.widget;
    state.widgetReady = true;

    // Load pending track
    if (state.pendingTrack) {
      const { url, autoPlay } = state.pendingTrack;
      state.pendingTrack = null;
      await player.load(url, { autoPlay });
      state.currentTrackUrl = url;
      await updateDurationDisplay();
    }

    // Setup event handlers
    player.on('PLAY', () => {
      DOM.customPlayer?.classList.add("is-playing");
      setPlayingState(state.playingId, true);
    });

    player.on('PAUSE', () => {
      DOM.customPlayer?.classList.remove("is-playing");
      setPlayingState(state.playingId, false);
    });

    player.on('FINISH', () => {
      const finishedId = state.playingId;
      setPlayingState(finishedId, false);
      setActiveNode(null);
      DOM.customPlayer?.classList.remove("is-playing");
      resetProgressUI();
    });

    player.on('PLAY_PROGRESS', (event) => {
      const fraction = event.relativePosition ||
        (event.duration ? event.currentPosition / event.duration : 0);
      setProgressUI(fraction);
      if (DOM.currentTimeEl) {
        DOM.currentTimeEl.textContent = formatTime(event.currentPosition / 1000);
      }
    });

    // Setup controls
    DOM.playPauseBtn?.addEventListener("click", async () => {
      try {
        await player.togglePlayPause();
      } catch (error) {
        console.error("Play/pause error:", error);
      }
    });

    // Setup progress bar
    setupProgressBar();

    console.log("✅ Audio player initialized");
  } catch (error) {
    console.error("❌ Audio player initialization failed:", error);
    showUserError("Audio player unavailable. Please refresh the page.");
  }
}

function setupProgressBar() {
  let isSeeking = false;

  const seek = async (e) => {
    const rect = DOM.progressBar.getBoundingClientRect();
    const percent = Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width));
    setProgressUI(percent);

    try {
      const duration = await player.getDuration();
      await player.seekTo(percent * duration);
    } catch (error) {
      console.error("Seek error:", error);
    }
  };

  DOM.progressBar?.addEventListener("mousedown", (e) => {
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
      DOM.progressBar?.classList.remove("is-seeking");
    }
  });

  DOM.progressBar?.addEventListener("click", seek);
}

function setProgressUI(fraction) {
  const percent = Math.max(0, Math.min(1, fraction)) * 100;
  if (DOM.progressFill) DOM.progressFill.style.width = `${percent}%`;
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
}

function handleNodeFocus(track) {
  if (!track) return;
  if (state.lastNavigationMode === "keyboard") {
    playTrackImmediately(track.id, { forceMeta: true });
  } else {
    updateMeta(track);
  }
}

async function toggleTrackPlayback(trackId) {
  if (!player) return;

  const isCurrentTrack = state.playingId === trackId;

  if (isCurrentTrack) {
    try {
      await player.togglePlayPause();
      const paused = await player.isPaused();
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

  // Update track title
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
      const iframe = DOM.scWidget;
      if (iframe) {
        const src = createWidgetSrc(sanitized, true);
        iframe.setAttribute("src", src);
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
  state.nodes.forEach(({ group }, id) => {
    group.classList.toggle("is-active", id === trackId);
  });
  state.playingId = trackId;
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
    ddElements.forEach(dd => {
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

  if (!persistFlag) {
    setTimeout(() => {
      if (state.playingId !== track.id) {
        DOM.metaPanel?.classList.remove("is-active");
      }
    }, ANIMATION.META_AUTO_HIDE);
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
  window.addEventListener("pointerdown", () => {
    state.lastNavigationMode = "pointer";
  });

  window.addEventListener("keydown", (e) => {
    const tag = e.target.tagName;
    if (["INPUT", "TEXTAREA"].includes(tag)) return;

    if (e.key === "Tab") {
      state.lastNavigationMode = "keyboard";
      return;
    }

    if (["ArrowLeft", "ArrowRight", "Space"].includes(e.key)) {
      state.lastNavigationMode = "keyboard";
    }

    // Check if modals are open
    const modalOpen = document.querySelector(".about-overlay.is-open, .guide-overlay.is-open");
    if (modalOpen) return;

    switch (e.code) {
      case "Space": {
        e.preventDefault();
        if (player && state.widgetReady) {
          player.togglePlayPause().catch(err => {
            console.error("Toggle playback error:", err);
          });
        }
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
// MODAL DIALOGS
// ============================================

function setupModals() {
  setupAboutModal();
  setupGuideModal();
}

function setupAboutModal() {
  if (!DOM.aboutButton || !DOM.aboutOverlay) return;

  function openAbout() {
    DOM.aboutOverlay.classList.add("is-open");
    document.body.style.overflow = "hidden";
  }

  function closeAbout() {
    DOM.aboutOverlay.classList.remove("is-open");
    document.body.style.overflow = "";
  }

  DOM.aboutButton.addEventListener("click", openAbout);

  if (DOM.aboutClose) {
    DOM.aboutClose.addEventListener("click", closeAbout);
  }

  if (DOM.aboutBackdrop) {
    DOM.aboutBackdrop.addEventListener("click", closeAbout);
  }

  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape" && DOM.aboutOverlay.classList.contains("is-open")) {
      closeAbout();
    }
  });
}

function setupGuideModal() {
  if (!DOM.guideButton || !DOM.guideOverlay) return;

  function openGuide() {
    DOM.guideOverlay.classList.add("is-open");
    document.body.style.overflow = "hidden";
  }

  function closeGuide() {
    DOM.guideOverlay.classList.remove("is-open");
    document.body.style.overflow = "";
  }

  DOM.guideButton.addEventListener("click", openGuide);

  if (DOM.guideClose) {
    DOM.guideClose.addEventListener("click", closeGuide);
  }

  if (DOM.guideBackdrop) {
    DOM.guideBackdrop.addEventListener("click", closeGuide);
  }

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

console.log("✅ Starmap refactored module loaded");

const VIEWBOX_SIZE = 1000;
const STARMAP_PADDING = 0;
const STARMAP_OFFSET_LEFT = 0;
const STARMAP_OFFSET_TOP = 0;
const SOUND_CLOUD_EMBED_BASE = "https://w.soundcloud.com/player/";

const layoutButtons = Array.from(document.querySelectorAll(".layout-button"));
const starmapSvg = document.getElementById("starmap-canvas");
const gradientDefs = ensureGradientDefs();
const metaPanel = document.getElementById("track-meta");

const linkLayer = document.createElementNS("http://www.w3.org/2000/svg", "g");
linkLayer.classList.add("links-layer");
starmapSvg.appendChild(linkLayer);

const nodeLayer = document.createElementNS("http://www.w3.org/2000/svg", "g");
nodeLayer.classList.add("nodes-layer");
starmapSvg.appendChild(nodeLayer);

const state = {
  album: null,
  nodes: new Map(),
  layout: "constellations",
  widget: null,
  widgetReady: false,
  playingId: null,
  positions: {},
  pendingTrack: null,
  defaultTrackId: null,
  ui: {},
  hasLoadedOnce: false,
  currentMetaTrackId: null,
  isPlaying: false,
  trackOrder: [],
  lastNavigationMode: "pointer",
};

function ensureGradientDefs() {
  if (!starmapSvg) return null;
  const existing = starmapSvg.querySelector('defs');
  if (existing) return existing;
  const defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs');
  starmapSvg.insertBefore(defs, starmapSvg.firstChild);
  return defs;
}

function normalizeSoundUrl(identifier) {
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

function createWidgetSrc(soundUrl, autoPlay = false) {
  const params = new URLSearchParams({
    url: soundUrl,
    color: "#94bfff",
    auto_play: autoPlay ? "true" : "false",
    hide_related: "true",
    show_comments: "false",
    show_user: "false",
    show_reposts: "false",
    show_teaser: "false",
    visual: "true",
    show_artwork: "false",
    buying: "false",
    sharing: "false",
    download: "false",
    show_playcount: "false",
  });
  return `${SOUND_CLOUD_EMBED_BASE}?${params.toString()}`;
}

function setInitialTrack(track) {
  if (!track) return;
  state.defaultTrackId = track.id;

  const titleEl = document.getElementById("current-track-title");
  if (titleEl) {
    titleEl.textContent = track.title;
  }

  updateMeta(track, true);
  metaPanel.classList.add("is-active");

  const durationEl = state.ui.durationEl || document.getElementById("duration");
  if (durationEl && track.duration) {
    durationEl.textContent = track.duration;
  }
  if (state.widget && state.widgetReady && durationEl) {
    updateDurationDisplay(state.widget, durationEl);
  }
}

function clampFraction(value) {
  if (!Number.isFinite(value)) return 0;
  return Math.min(1, Math.max(0, value));
}

function mapToCanvasX(value, width) {
  const effectiveWidth = Math.max(width, STARMAP_OFFSET_LEFT + 1);
  return STARMAP_OFFSET_LEFT + (effectiveWidth - STARMAP_OFFSET_LEFT) * clamp01(value);
}

function mapToCanvasY(value, height) {
  const effectiveHeight = Math.max(height, STARMAP_OFFSET_TOP + 1);
  return STARMAP_OFFSET_TOP + (effectiveHeight - STARMAP_OFFSET_TOP) * clamp01(value);
}

function setProgressUI(fraction) {
  const percent = clampFraction(fraction) * 100;
  const { progressFill, progressHandle } = state.ui;
  if (progressFill) progressFill.style.width = `${percent}%`;
  if (progressHandle) progressHandle.style.left = `${percent}%`;
}

function resetProgressUI() {
  setProgressUI(0);
  const { currentTimeEl } = state.ui;
  if (currentTimeEl) currentTimeEl.textContent = "0:00";
}

async function init() {
  window.addEventListener("resize", handleResize);
  handleResize();

  // Add spacebar play/pause functionality
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

    switch (e.code) {
      case "Space": {
        e.preventDefault();
        if (state.widget && state.widgetReady) {
          state.widget.isPaused((paused) => {
            if (paused) {
              state.widget.play();
            } else {
              state.widget.pause();
            }
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
      default:
        break;
    }
  });

  await loadAlbum();
  setupLayoutControls();
  setupAudioPlayer();
}

async function loadAlbum() {
  try {
    const response = await fetch("data/album.json");
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const album = await response.json();
    const defaultTrack =
      album.tracks.find((track) => track.id === "kopfkino") ??
      album.tracks.find((track) => normalizeSoundUrl(track.soundcloudId)) ??
      album.tracks[0];

    state.album = album;
    state.trackOrder = album.tracks.map((track) => track.id);
    initializeSoundCloudEmbed(defaultTrack);
    renderNodes(album.tracks);
    applyLayout(state.layout);
    setInitialTrack(defaultTrack);
  } catch (error) {
    console.error("Failed to load album data", error);
    metaPanel.innerHTML =
      '<p class="track-meta__error">Could not load album data. Check console for details.</p>';
  }
}

function initializeSoundCloudEmbed(track) {
  if (!track) return;
  const normalized = normalizeSoundUrl(track.soundcloudId);
  if (!normalized) return;
  setSoundCloudEmbedSrc(normalized);
  state.pendingTrack = {
    url: normalized,
    autoPlay: false,
  };
  resetProgressUI();
}

function setSoundCloudEmbedSrc(trackUrl, autoPlay = false) {
  const iframe = document.getElementById("sc-widget");
  if (!iframe) return;

  const sanitized = normalizeSoundUrl(trackUrl);
  if (!sanitized) return;

  const nextSrc = createWidgetSrc(sanitized, autoPlay);
  if (iframe.getAttribute("src") !== nextSrc) {
    iframe.setAttribute("src", nextSrc);
  }
}

function setupAudioPlayer() {
  const iframe = document.getElementById("sc-widget");
  const playPauseBtn = document.getElementById("play-pause-btn");
  const progressBar = document.getElementById("progress-bar");
  const progressFill = document.getElementById("progress-fill");
  const progressHandle = document.getElementById("progress-handle");
  const currentTimeEl = document.getElementById("current-time");
  const durationEl = document.getElementById("duration");
  const customPlayer = document.querySelector(".custom-player");

  state.ui = {
    progressFill,
    progressHandle,
    currentTimeEl,
    durationEl,
  };
  resetProgressUI();

  if (!iframe || typeof SC === "undefined") {
    console.error("SoundCloud Widget not available");
    return;
  }

  const widget = SC.Widget(iframe);
  state.widget = widget;

  const updateDuration = () => updateDurationDisplay(widget, durationEl);

  // Wait for widget to be ready
  widget.bind(SC.Widget.Events.READY, () => {
    state.widgetReady = true;
    resetProgressUI();
    if (state.pendingTrack?.url) {
      const { url, autoPlay } = state.pendingTrack;
      state.pendingTrack = null;
      widget.load(url, {
        auto_play: autoPlay,
        callback: updateDuration,
      });
    } else {
      updateDuration();
    }
  });

  // Play/Pause button
  playPauseBtn?.addEventListener("click", () => {
    widget.isPaused((paused) => {
      if (paused) {
        widget.play();
      } else {
        widget.pause();
      }
    });
  });

  // Widget events
  widget.bind(SC.Widget.Events.PLAY, () => {
    customPlayer?.classList.add("is-playing");
    setPlayingState(state.playingId, true);
  });

  widget.bind(SC.Widget.Events.PAUSE, () => {
    customPlayer?.classList.remove("is-playing");
    setPlayingState(state.playingId, false);
  });

  widget.bind(SC.Widget.Events.FINISH, () => {
    const finishedId = state.playingId;
    setPlayingState(finishedId, false);
    setActiveNode(null);
    customPlayer?.classList.remove("is-playing");
    resetProgressUI();
  });

  // Update progress bar
  widget.bind(SC.Widget.Events.PLAY_PROGRESS, (event) => {
    const fraction = clampFraction(
      typeof event.relativePosition === "number" && !Number.isNaN(event.relativePosition)
        ? event.relativePosition
        : event.duration
        ? event.currentPosition / event.duration
        : 0
    );
    setProgressUI(fraction);
    if (currentTimeEl) currentTimeEl.textContent = formatTime(event.currentPosition / 1000);
  });

  // Progress bar seeking
  let isSeeking = false;

  const seek = (e) => {
    const rect = progressBar.getBoundingClientRect();
    const percent = clampFraction((e.clientX - rect.left) / rect.width);
    setProgressUI(percent);

    widget.getDuration((duration) => {
      widget.seekTo(percent * duration);
    });
  };

  progressBar?.addEventListener("mousedown", (e) => {
    isSeeking = true;
    progressBar.classList.add("is-seeking");
    seek(e);
  });

  window.addEventListener("mousemove", (e) => {
    if (isSeeking) seek(e);
  });

  window.addEventListener("mouseup", () => {
    if (isSeeking) {
      isSeeking = false;
      progressBar?.classList.remove("is-seeking");
    }
  });

  progressBar?.addEventListener("click", seek);
}

function formatTime(seconds) {
  if (!isFinite(seconds)) return "0:00";
  const mins = Math.floor(seconds / 60);
  const secs = Math.floor(seconds % 60);
  return `${mins}:${secs.toString().padStart(2, "0")}`;
}

function updateDurationDisplay(widget, targetEl) {
  if (!widget || !targetEl) return;
  widget.getDuration((duration) => {
    targetEl.textContent = formatTime(duration / 1000);
  });
}

function getKeyColors(key) {
  const root = extractKeyRoot(key);
  const isMajor = key?.includes("Maj");

  const keyOrder = ["C", "G", "D", "A", "E", "B", "F♯", "C♯", "G♯", "D♯", "A♯", "F"];
  const palettes = [
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

  const idx = keyOrder.indexOf(root);
  const palette = palettes[idx >= 0 ? idx : 0];

  const adjust = (hex, factor) => {
    const { r, g, b } = hexToRgb(hex);
    const mix = (channel) => {
      const mixed = channel * factor + 255 * (1 - factor);
      return Math.round(Math.max(0, Math.min(255, mixed)));
    };
    return rgbToHex(mix(r), mix(g), mix(b));
  };

  const brightness = isMajor ? 0.85 : 0.7;
  const haloAlpha = isMajor ? 1 : 0.85;

  return {
    coreInner: adjust(palette.inner, brightness),
    coreMid: adjust(palette.mid, brightness),
    coreOuter: adjust(palette.outer, brightness),
    haloFill: withAlpha(palette.halo, haloAlpha),
    flareFill: palette.flare,
    sparkFill: adjust(palette.spark, isMajor ? 0.9 : 0.75),
  };
}

function hexToRgb(hex) {
  const normalized = hex.replace('#', '');
  const bigint = parseInt(normalized, 16);
  return {
    r: (bigint >> 16) & 255,
    g: (bigint >> 8) & 255,
    b: bigint & 255,
  };
}

function rgbToHex(r, g, b) {
  const toHex = (value) => value.toString(16).padStart(2, '0');
  return `#${toHex(r)}${toHex(g)}${toHex(b)}`;
}

function withAlpha(rgbaString, multiplier) {
  const match = rgbaString.match(/rgba?\(([^)]+)\)/i);
  if (!match) return rgbaString;
  const parts = match[1].split(',').map((part) => part.trim());
  if (parts.length < 3) return rgbaString;
  const [r, g, b, alpha = '1'] = parts;
  const a = Math.max(0, Math.min(1, parseFloat(alpha) * multiplier));
  return `rgba(${r}, ${g}, ${b}, ${a.toFixed(3)})`;
}

function renderNodes(tracks) {
  nodeLayer.innerHTML = "";
  linkLayer.innerHTML = "";
  state.nodes.clear();
  if (gradientDefs) {
    gradientDefs.textContent = "";
  }

  tracks.forEach((track, index) => {
    const group = document.createElementNS("http://www.w3.org/2000/svg", "g");
    group.classList.add("track-node");
    group.dataset.id = track.id;
    group.setAttribute("tabindex", "0");

    // BPM-based sizing
    const radius = nodeRadius(track);

    // Key-based coloring
    const colors = getKeyColors(track.key);
    const glowSize = 10 + (track.bpm - 70) / 10; // BPM influences glow intensity

    // Set CSS custom properties for colors and glow
    group.style.setProperty("--core-spark", colors.sparkFill);
    group.style.setProperty("--node-halo-fill", colors.haloFill);
    group.style.setProperty("--node-flare-fill", colors.flareFill);
    group.style.setProperty("--glow-size", `${glowSize}px`);
    group.style.setProperty("--node-index", index);
    const pulseIntensity = Number.isFinite(track.pulseValue) ? track.pulseValue : 0;
    const haloOpacity = Math.max(0, Math.min(1, 0.35 + pulseIntensity * 0.25));
    const hoverOpacity = Math.min(1, haloOpacity + 0.12);
    const playOpacity = Math.min(1, haloOpacity + 0.28);
    group.style.setProperty("--halo-active-opacity", haloOpacity.toFixed(3));
    group.style.setProperty("--halo-hover-opacity", hoverOpacity.toFixed(3));
    group.style.setProperty("--halo-play-opacity", playOpacity.toFixed(3));

    const gradientId = `node-gradient-${track.id}`;
    const gradient = document.createElementNS("http://www.w3.org/2000/svg", "radialGradient");
    gradient.setAttribute("id", gradientId);
    gradient.setAttribute("cx", "50%");
    gradient.setAttribute("cy", "45%");
    gradient.setAttribute("r", "65%");

    const stopInner = document.createElementNS("http://www.w3.org/2000/svg", "stop");
    stopInner.setAttribute("offset", "0%");
    stopInner.setAttribute("stop-color", colors.coreInner);

    const stopMid = document.createElementNS("http://www.w3.org/2000/svg", "stop");
    stopMid.setAttribute("offset", "48%");
    stopMid.setAttribute("stop-color", colors.coreMid);
    stopMid.setAttribute("stop-opacity", "0.85");

    const stopOuter = document.createElementNS("http://www.w3.org/2000/svg", "stop");
    stopOuter.setAttribute("offset", "100%");
    stopOuter.setAttribute("stop-color", colors.coreOuter);
    stopOuter.setAttribute("stop-opacity", "0");

    gradient.appendChild(stopInner);
    gradient.appendChild(stopMid);
    gradient.appendChild(stopOuter);
    if (gradientDefs) {
      gradientDefs.appendChild(gradient);
    }

    const circle = document.createElementNS(
      "http://www.w3.org/2000/svg",
      "circle"
    );
    circle.classList.add("track-node__core");
    circle.setAttribute("r", radius);
    circle.setAttribute("fill", `url(#${gradientId})`);

    const ring = document.createElementNS("http://www.w3.org/2000/svg", "circle");
    ring.classList.add("track-node__halo");
    ring.setAttribute("r", radius * 2.4); // Subtle halo for Gaussian blur glow

    const flare = document.createElementNS("http://www.w3.org/2000/svg", "circle");
    flare.classList.add("track-node__flare");
    flare.setAttribute("r", radius * 3.2);

    const spark = document.createElementNS("http://www.w3.org/2000/svg", "circle");
    spark.classList.add("track-node__spark");
    spark.setAttribute("r", radius * 0.45);

    const label = document.createElementNS(
      "http://www.w3.org/2000/svg",
      "text"
    );
    label.classList.add("track-node__label");
    label.textContent = track.title;
    label.setAttribute("text-anchor", "middle");
    label.setAttribute("dy", `${radius + 18}`);

    group.appendChild(flare);
    group.appendChild(ring);
    group.appendChild(circle);
    group.appendChild(spark);
    group.appendChild(label);
    nodeLayer.appendChild(group);
    group.classList.add("track-node--loaded");

    group.addEventListener("click", () => handleTrackSelection(track.id));
    group.addEventListener("keydown", (event) => {
      if (event.key === "Enter" || event.key === " ") {
        event.preventDefault();
        handleTrackSelection(track.id);
      }
    });
    group.addEventListener("pointerenter", () => updateMeta(track));
    group.addEventListener("focus", () => handleNodeFocus(track));
    group.addEventListener("pointerleave", () => {
      // Don't remove is-active class - keep metadata visible
      // This prevents fade in/out when re-hovering the same node
    });

    state.nodes.set(track.id, {
      group,
      circle,
      ring,
      flare,
      spark,
      track,
    });
  });
}

function handleTrackSelection(trackId) {
  const trackNode = state.nodes.get(trackId);
  if (!trackNode) return;
  const { track } = trackNode;
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

function setActiveNode(trackId) {
  state.nodes.forEach(({ group }, id) => {
    group.classList.toggle("is-active", id === trackId);
  });
  state.playingId = trackId;
  highlightLinks(trackId);
}

function setPlayingState(trackId, isPlaying) {
  state.nodes.forEach(({ group }, id) => {
    const shouldGlow = Boolean(isPlaying && trackId && id === trackId);
    group.classList.toggle("is-playing", shouldGlow);
  });
  state.isPlaying = Boolean(isPlaying && trackId);
}

function getCurrentTrackId() {
  return (
    state.playingId ??
    state.currentMetaTrackId ??
    state.defaultTrackId ??
    state.trackOrder[0] ??
    null
  );
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

function playTrackImmediately(trackId, { forceMeta = false } = {}) {
  if (!trackId) return;
  const entry = state.nodes.get(trackId);
  if (!entry) return;

  setPlayingState(null, false);
  setActiveNode(trackId);
  playTrack(trackId);

  if (forceMeta) {
    updateMeta(entry.track, { persistent: true, force: true });
  } else if (entry.track) {
    updateMeta(entry.track);
  }
}

function playTrack(trackId) {
  const trackEntry = state.nodes.get(trackId);
  const track = trackEntry?.track;
  const sanitized = normalizeSoundUrl(track?.soundcloudId);
  if (!sanitized) return;

  // Update track title in player
  const trackTitleEl = document.getElementById("current-track-title");
  if (trackTitleEl) {
    trackTitleEl.textContent = track.title;
  }

  const loadOptions = {
    auto_play: true,
    callback: () => {
      const durationEl = document.getElementById("duration");
      updateDurationDisplay(state.widget, durationEl);
    },
  };

  resetProgressUI();

  if (state.widget && state.widgetReady) {
    state.pendingTrack = null;
    state.widget.load(sanitized, loadOptions);
  } else {
    state.pendingTrack = { url: sanitized, autoPlay: true };
    setSoundCloudEmbedSrc(sanitized, true);
  }
}

function toggleTrackPlayback(trackId) {
  const widget = state.widget;
  if (!widget) return;

  const isCurrentTrack = state.playingId === trackId;

  const resumeOrPlay = () => {
    setActiveNode(trackId);
    setPlayingState(null, false);
    playTrack(trackId);
  };

  if (isCurrentTrack && state.widgetReady) {
    widget.isPaused((paused) => {
      if (paused) {
        widget.play();
        setActiveNode(trackId);
      } else {
        widget.pause();
        setPlayingState(trackId, false);
      }
    });
  } else {
    resumeOrPlay();
  }
}


function nodeRadius(track) {
  // Base size influenced by BPM
  const minBpm = 70;
  const maxBpm = 130;
  const minRadius = 12;
  const maxRadius = 22;

  // Normalize BPM to 0-1 range
  const bpmNormalized = Math.max(0, Math.min(1, (track.bpm - minBpm) / (maxBpm - minBpm)));

  // Calculate radius: slower tracks are smaller, faster tracks are larger
  return minRadius + bpmNormalized * (maxRadius - minRadius);
}

function setupLayoutControls() {
  layoutButtons.forEach((button) => {
    button.addEventListener("click", () => {
      const targetLayout = button.dataset.layout;
      if (targetLayout === state.layout) return;
      layoutButtons.forEach((btn) =>
        btn.classList.toggle("is-active", btn === button)
      );
      applyLayout(targetLayout);
    });
  });
}

function applyLayout(layoutId) {
  state.layout = layoutId;
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

  updateLinks(layout.links || []);

  const bounds = starmapSvg.getBoundingClientRect();
  const width = bounds.width || VIEWBOX_SIZE;
  const height = bounds.height || VIEWBOX_SIZE;

  // Detect initial load vs layout change
  const isInitialLoad = !state.hasLoadedOnce;
  if (isInitialLoad) {
    state.hasLoadedOnce = true;
  }

  // Add organic staggered animation
  tracks.forEach((track, index) => {
    const node = state.nodes.get(track.id);
    if (!node) return;
    const coords = positions[track.id];
    if (!coords) return;

    node.group.style.setProperty(
      "--depth",
      coords.depth != null ? coords.depth : 0
    );

    const x = mapToCanvasX(coords.x, width);
    const y = mapToCanvasY(coords.y, height);

    node.group.dataset.x = String(x);
    node.group.dataset.y = String(y);

    const haloScale = 0.9 + coords.altitude * 0.2;
    node.ring.style.transform = `scale(${haloScale})`;
    node.ring.setAttribute("r", radius => radius);

    if (isInitialLoad) {
      // Initial load: position immediately, no stagger, then fade in
      node.group.style.setProperty("--stagger-delay", "0ms");
      node.group.style.transition = "none";
      node.group.style.transform = `translate(${x}px, ${y}px)`;
      node.group.setAttribute("transform", `translate(${x} ${y})`);
      node.group.style.transformOrigin = `${x}px ${y}px`;

      // Force reflow to apply position immediately
      node.group.getBoundingClientRect();

      // Restore transitions and fade in with stagger
      requestAnimationFrame(() => {
        const fadeInDelay = index * 25; // Faster stagger for fade-in
        node.group.style.transition = "";
        node.group.style.setProperty("--stagger-delay", `${fadeInDelay}ms`);
        node.group.classList.add("track-node--loaded");
      });
    } else {
      // Layout change: animate with full stagger effect
      const staggerDelay = index * 35; // 35ms between each node
      const distanceFromCenter = Math.sqrt(
        Math.pow(coords.x - 0.5, 2) + Math.pow(coords.y - 0.5, 2)
      );
      const radiusDelay = distanceFromCenter * 80; // Delay based on distance from center

      // Force browser to read current position before applying new transform
      // This prevents the "jump" at the start of transition
      const currentTransform = window.getComputedStyle(node.group).transform;

      node.group.style.setProperty("--stagger-delay", `${staggerDelay}ms`);
      node.group.style.setProperty("--radius-delay", `${radiusDelay}ms`);
      node.group.style.transform = `translate(${x}px, ${y}px)`;
      node.group.setAttribute("transform", `translate(${x} ${y})`);
      node.group.style.transformOrigin = `${x}px ${y}px`;
    }
  });

  if (state.playingId) {
    highlightLinks(state.playingId);
  }
}

function updateLinks(links) {
  linkLayer.innerHTML = "";
  if (!links.length) return;

  links.forEach(([fromId, toId], index) => {
    const fromNode = state.nodes.get(fromId);
    const toNode = state.nodes.get(toId);
    if (!fromNode || !toNode) return;

    const line = document.createElementNS(
      "http://www.w3.org/2000/svg",
      "line"
    );
    line.classList.add("starmap-link");
    line.dataset.from = fromId;
    line.dataset.to = toId;

    // Stagger link appearance for organic feel
    setTimeout(() => {
      line.style.opacity = "1";
    }, index * 120 + 400);

    linkLayer.appendChild(line);
  });

  requestAnimationFrame(updateLinkPositions);
}

function normalizePositions(sourcePositions) {
  const normalized = {};
  const entries = Object.entries(sourcePositions || {});
  if (!entries.length) return normalized;

  let minX = Infinity;
  let maxX = -Infinity;
  let minY = Infinity;
  let maxY = -Infinity;

  entries.forEach(([id, pos]) => {
    if (!pos) return;
    const x = Number.isFinite(pos.x) ? pos.x : 0.5;
    const y = Number.isFinite(pos.y) ? pos.y : 0.5;
    if (x < minX) minX = x;
    if (x > maxX) maxX = x;
    if (y < minY) minY = y;
    if (y > maxY) maxY = y;
  });

  const rangeX = maxX - minX || 1;
  const rangeY = maxY - minY || 1;
  const margin = 0;

  entries.forEach(([id, pos]) => {
    if (!pos) return;
    const baseX = Number.isFinite(pos.x) ? pos.x : 0.5;
    const baseY = Number.isFinite(pos.y) ? pos.y : 0.5;
    const normalizedX = clamp01((baseX - minX) / rangeX);
    const normalizedY = clamp01((baseY - minY) / rangeY);
    const scaledX = margin + normalizedX * (1 - margin * 2);
    const scaledY = margin + normalizedY * (1 - margin * 2);

    normalized[id] = {
      ...pos,
      x: clamp01(scaledX),
      y: clamp01(scaledY),
    };
  });

  return normalized;
}

function updateLinkPositions() {
  const bounds = starmapSvg.getBoundingClientRect();
  const width = bounds.width || VIEWBOX_SIZE;
  const height = bounds.height || VIEWBOX_SIZE;

  const lines = linkLayer.querySelectorAll(".starmap-link");
  lines.forEach((line) => {
    const fromId = line.dataset.from;
    const toId = line.dataset.to;
    const fromNode = state.nodes.get(fromId);
    const toNode = state.nodes.get(toId);
    if (!fromNode || !toNode) return;

    const fallbackFromX = mapToCanvasX(state.positions[fromId]?.x ?? 0.5, width);
    const fallbackFromY = mapToCanvasY(state.positions[fromId]?.y ?? 0.5, height);
    const fallbackToX = mapToCanvasX(state.positions[toId]?.x ?? 0.5, width);
    const fallbackToY = mapToCanvasY(state.positions[toId]?.y ?? 0.5, height);

    const x1 = Number(fromNode.group.dataset.x) || fallbackFromX;
    const y1 = Number(fromNode.group.dataset.y) || fallbackFromY;
    const x2 = Number(toNode.group.dataset.x) || fallbackToX;
    const y2 = Number(toNode.group.dataset.y) || fallbackToY;

    line.setAttribute("x1", x1);
    line.setAttribute("y1", y1);
    line.setAttribute("x2", x2);
    line.setAttribute("y2", y2);
  });

  if (lines.length) {
    requestAnimationFrame(updateLinkPositions);
  }
}

function highlightLinks(activeId) {
  const lines = linkLayer.querySelectorAll(".starmap-link");
  lines.forEach((line) => {
    const fromId = line.dataset.from;
    const toId = line.dataset.to;
    const isActive = activeId && (fromId === activeId || toId === activeId);
    line.classList.toggle("is-active", Boolean(isActive));
  });
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

function updateMeta(track, persistent = false) {
  if (!track) return;

  const options =
    typeof persistent === "object"
      ? { persistent: Boolean(persistent.persistent), force: Boolean(persistent.force) }
      : { persistent: Boolean(persistent), force: false };
  const { persistent: persistFlag, force } = options;

  const existingTitle = metaPanel.querySelector("h3");
  const existingDl = metaPanel.querySelector("dl");
  const newTitle = track.title;

  if (
    !force &&
    state.currentMetaTrackId === track.id &&
    existingDl &&
    existingTitle?.textContent === newTitle &&
    metaPanel.classList.contains("is-active")
  ) {
    return;
  }

  // Replace ♭ with regular b in the key
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

  // If metadata already exists, fade title and dd elements together
  if (existingDl) {
    const ddElements = existingDl.querySelectorAll("dd");

    // Fade out title and dd values together
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
      }, 500);
    } else {
      metaPanel.innerHTML = createMetaMarkup(newTitle, metaEntries);
    }
  } else {
    metaPanel.innerHTML = createMetaMarkup(newTitle, metaEntries);
  }

  metaPanel.classList.add("is-active");
  state.currentMetaTrackId = track.id;

  if (!persistFlag) {
    setTimeout(() => {
      if (state.playingId !== track.id) {
        metaPanel.classList.remove("is-active");
      }
    }, 4000);
  }
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

function constellationLayout(tracks) {
  // Offset to center the constellation pattern
  const offsetX = 0.06;
  const offsetY = 0.08;

  // Scale factor to spread nodes further apart
  const scale = 1.28;
  const centerX = 0.5;
  const centerY = 0.5;

  const patterns = [
    {
      name: "Andromeda",
      points: [
        { x: centerX + (0.18 - centerX) * scale + offsetX, y: centerY + (0.22 - centerY) * scale + offsetY },
        { x: centerX + (0.26 - centerX) * scale + offsetX, y: centerY + (0.3 - centerY) * scale + offsetY },
        { x: centerX + (0.34 - centerX) * scale + offsetX, y: centerY + (0.38 - centerY) * scale + offsetY },
        { x: centerX + (0.46 - centerX) * scale + offsetX, y: centerY + (0.32 - centerY) * scale + offsetY },
      ],
      links: [
        [0, 1],
        [1, 2],
        [2, 3],
      ],
    },
    {
      name: "Lyra",
      points: [
        { x: centerX + (0.62 - centerX) * scale + offsetX, y: centerY + (0.24 - centerY) * scale + offsetY },
        { x: centerX + (0.7 - centerX) * scale + offsetX, y: centerY + (0.18 - centerY) * scale + offsetY },
        { x: centerX + (0.78 - centerX) * scale + offsetX, y: centerY + (0.28 - centerY) * scale + offsetY },
        { x: centerX + (0.68 - centerX) * scale + offsetX, y: centerY + (0.36 - centerY) * scale + offsetY },
      ],
      links: [
        [0, 1],
        [1, 2],
        [2, 3],
        [3, 0],
      ],
    },
    {
      name: "Pisces",
      points: [
        { x: centerX + (0.28 - centerX) * scale + offsetX, y: centerY + (0.72 - centerY) * scale + offsetY },
        { x: centerX + (0.36 - centerX) * scale + offsetX, y: centerY + (0.62 - centerY) * scale + offsetY },
        { x: centerX + (0.44 - centerX) * scale + offsetX, y: centerY + (0.7 - centerY) * scale + offsetY },
      ],
      links: [
        [0, 1],
        [1, 2],
      ],
    },
    {
      name: "Orion",
      points: [
        { x: centerX + (0.58 - centerX) * scale + offsetX, y: centerY + (0.68 - centerY) * scale + offsetY },
        { x: centerX + (0.66 - centerX) * scale + offsetX, y: centerY + (0.62 - centerY) * scale + offsetY },
        { x: centerX + (0.74 - centerX) * scale + offsetX, y: centerY + (0.72 - centerY) * scale + offsetY },
      ],
      links: [
        [0, 1],
        [1, 2],
      ],
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

  // if tracks remain, scatter them softly at bottom hemisphere
  const leftovers = tracks.slice(trackIndex);
  leftovers.forEach((track, idx) => {
    const spread = leftovers.length > 1 ? idx / (leftovers.length - 1) : 0.5;
    positions[track.id] = {
      x: 0.24 + offsetX + spread * 0.52,
      y: 0.78 + offsetY - 0.05 * (idx % 3),
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

    // Adjust specific tracks
    if (track.id === "hinterland") {
      y += 0.08;
    } else if (track.id === "think-thrice") {
      y -= 0.08;
    }

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
  const seed = 1337;

  tracks.forEach((track, idx) => {
    const r = pseudoRandom(seed + idx);
    let x = 0.15 + r(0.7);
    let y = 0.2 + r(0.6);

    // Move Au Revoir further down
    if (track.id === "au-revoir") {
      y += 0.15;
    }

    positions[track.id] = {
      x: x,
      y: y,
      altitude: 0.4 + track.pulseValue * 0.4,
    };
  });

  return { positions, links: [] };
}

function tempoSpiralLayout(tracks) {
  const positions = {};
  const links = [];
  if (!tracks.length) return { positions, links };

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

  // Archimedean spiral: radius grows linearly with angle
  const startRadius = 0.04;
  const radiusGrowth = 0.065; // How much radius increases per full rotation
  const totalRotations = 2.8; // Number of complete spirals

  sorted.forEach((track, idx) => {
    const progress = idx / Math.max(1, sorted.length - 1);
    const relativeBpm = Number.isFinite(track.bpm)
      ? (track.bpm - minBpm) / bpmRange
      : progress;

    // Angle increases linearly with progress (creates the spiral)
    const angle = progress * Math.PI * 2 * totalRotations;

    // Radius increases linearly with progress (outward spiral)
    const radius = startRadius + (progress * radiusGrowth * totalRotations);

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

function pseudoRandom(seed) {
  let value = Math.sin(seed) * 10000;
  return (range = 1) => {
    value = Math.sin(value) * 10000;
    return (value - Math.floor(value)) * range;
  };
}

function extractKeyRoot(key) {
  const match = key.match(/^([A-G])([♭#])?/);
  if (!match) return key;
  const base = match[1];
  const accidental = match[2];
  if (accidental === "#") return `${base}♯`;
  if (accidental === "♭") {
    const flats = {
      B: "A♯",
      E: "D♯",
      A: "G♯",
      D: "C♯",
      G: "F♯",
      C: "B",
      F: "E",
    };
    return flats[base] || base;
  }
  return base;
}

function lerp(min, max, t) {
  return min + (max - min) * t;
}

function clamp01(value) {
  return Math.min(1, Math.max(0, value));
}

function handleResize() {
  if (state.album) {
    applyLayout(state.layout);
  }
}

// About modal functionality
function setupAboutModal() {
  const aboutButton = document.getElementById("about-button");
  const aboutOverlay = document.getElementById("about-overlay");
  const aboutClose = document.getElementById("about-close");
  const aboutBackdrop = document.getElementById("about-backdrop");

  if (!aboutButton || !aboutOverlay) return;

  function openAbout() {
    aboutOverlay.classList.add("is-open");
    document.body.style.overflow = "hidden";
  }

  function closeAbout() {
    aboutOverlay.classList.remove("is-open");
    document.body.style.overflow = "";
  }

  // Open on button click
  aboutButton.addEventListener("click", openAbout);

  // Close on close button click
  if (aboutClose) {
    aboutClose.addEventListener("click", closeAbout);
  }

  // Close on backdrop click
  if (aboutBackdrop) {
    aboutBackdrop.addEventListener("click", closeAbout);
  }

  // Close on ESC key
  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape" && aboutOverlay.classList.contains("is-open")) {
      closeAbout();
    }
  });
}

window.addEventListener("load", () => {
  init();
  setupAboutModal();
  setupGuideModal();
  setupKeyboardShortcuts();
});

// Guide modal functionality
function setupGuideModal() {
  const guideButton = document.getElementById("guide-button");
  const guideOverlay = document.getElementById("guide-overlay");
  const guideClose = document.getElementById("guide-close");
  const guideBackdrop = document.getElementById("guide-backdrop");

  if (!guideButton || !guideOverlay) return;

  function openGuide() {
    guideOverlay.classList.add("is-open");
    document.body.style.overflow = "hidden";
  }

  function closeGuide() {
    guideOverlay.classList.remove("is-open");
    document.body.style.overflow = "";
  }

  // Open on button click
  guideButton.addEventListener("click", openGuide);

  // Close on close button click
  if (guideClose) {
    guideClose.addEventListener("click", closeGuide);
  }

  // Close on backdrop click
  if (guideBackdrop) {
    guideBackdrop.addEventListener("click", closeGuide);
  }

  // Close on ESC key
  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape" && guideOverlay.classList.contains("is-open")) {
      closeGuide();
    }
  });
}

// Keyboard shortcuts for navigation
function setupKeyboardShortcuts() {
  const layouts = ["constellations", "helix", "scatter", "tempo-spiral"];
  let currentLayoutIndex = 0;

  document.addEventListener("keydown", (e) => {
    // Ignore if typing in input fields or modals are open
    if (["INPUT", "TEXTAREA"].includes(e.target.tagName)) return;
    if (document.querySelector(".about-overlay.is-open, .guide-overlay.is-open")) return;

    // Up/Down arrow keys for constellation patterns (cycle through 1-4)
    if (e.key === "ArrowUp" || e.key === "ArrowDown") {
      if (!state.album) return;

      if (e.key === "ArrowDown") {
        // Go down: 1 -> 2 -> 3 -> 4 -> 1
        currentLayoutIndex = (currentLayoutIndex + 1) % layouts.length;
      } else {
        // Go up: 4 -> 3 -> 2 -> 1 -> 4
        currentLayoutIndex = (currentLayoutIndex - 1 + layouts.length) % layouts.length;
      }

      applyLayout(layouts[currentLayoutIndex]);
      // Update button states
      layoutButtons.forEach((btn, idx) => {
        btn.classList.toggle("is-active", idx === currentLayoutIndex);
      });
    }

    // Left/Right arrow keys for previous/next track
    if (e.key === "ArrowLeft" || e.key === "ArrowRight") {
      if (!state.album) return;
      const tracks = state.album.tracks;
      const currentIndex = tracks.findIndex(t => t.id === state.playingId);

      let newIndex;
      if (e.key === "ArrowLeft") {
        newIndex = currentIndex > 0 ? currentIndex - 1 : tracks.length - 1;
      } else {
        newIndex = currentIndex < tracks.length - 1 ? currentIndex + 1 : 0;
      }

      if (tracks[newIndex]) {
        handleTrackSelection(tracks[newIndex].id);
      }
    }
  });
}

// ============================================
// SOUNDCLOUD PLAYER (Async/Await Wrapper)
// ============================================
import { AUDIO } from './constants.js';
import { normalizeSoundUrl } from './utils.js';

export class SoundCloudPlayer {
  constructor(iframe) {
    if (!iframe) {
      throw new Error("SoundCloud iframe element is required");
    }
    this.iframe = iframe;
    this.widget = null;
    this.isReady = false;
    this.readyPromise = null;
    this.eventHandlers = new Map();
  }

  // Initialize widget and wait for ready
  async initialize() {
    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        reject(new Error("SoundCloud Widget failed to initialize"));
      }, AUDIO.READY_TIMEOUT);

      // Check if SC is available
      if (typeof SC === "undefined") {
        clearTimeout(timeout);
        reject(new Error("SoundCloud API not loaded"));
        return;
      }

      this.widget = SC.Widget(this.iframe);

      this.widget.bind(SC.Widget.Events.READY, () => {
        clearTimeout(timeout);
        this.isReady = true;
        console.log("✅ SoundCloud Widget initialized");
        resolve();
      });
    });
  }

  // Promise-based play
  async play() {
    await this.ensureReady();
    return new Promise((resolve) => {
      this.widget.play();
      resolve();
    });
  }

  // Promise-based pause
  async pause() {
    await this.ensureReady();
    return new Promise((resolve) => {
      this.widget.pause();
      resolve();
    });
  }

  // Promise-based toggle
  async togglePlayPause() {
    await this.ensureReady();
    const paused = await this.isPaused();
    if (paused) {
      await this.play();
    } else {
      await this.pause();
    }
    return !paused;
  }

  // Check if paused
  async isPaused() {
    await this.ensureReady();
    return new Promise((resolve) => {
      this.widget.isPaused(resolve);
    });
  }

  // Load track
  async load(url, options = {}) {
    await this.ensureReady();
    const sanitized = normalizeSoundUrl(url);
    if (!sanitized) {
      throw new Error(`Invalid SoundCloud URL: ${url}`);
    }

    return new Promise((resolve, reject) => {
      this.widget.load(sanitized, {
        auto_play: options.autoPlay || false,
        callback: (error) => {
          if (error) {
            reject(new Error(`Failed to load track: ${error}`));
          } else {
            resolve();
          }
        },
      });
    });
  }

  // Get duration
  async getDuration() {
    await this.ensureReady();
    return new Promise((resolve) => {
      this.widget.getDuration(resolve);
    });
  }

  // Seek to position
  async seekTo(milliseconds) {
    await this.ensureReady();
    return new Promise((resolve) => {
      this.widget.seekTo(milliseconds);
      resolve();
    });
  }

  // Get current position
  async getPosition() {
    await this.ensureReady();
    return new Promise((resolve) => {
      this.widget.getPosition(resolve);
    });
  }

  // Bind event with cleanup tracking
  on(eventName, handler) {
    if (!this.widget) {
      throw new Error("Widget not initialized");
    }

    const scEvent = SC.Widget.Events[eventName];
    if (!scEvent) {
      throw new Error(`Unknown SoundCloud event: ${eventName}`);
    }

    this.widget.bind(scEvent, handler);

    // Track for cleanup
    if (!this.eventHandlers.has(eventName)) {
      this.eventHandlers.set(eventName, []);
    }
    this.eventHandlers.get(eventName).push(handler);
  }

  // Remove event handler
  off(eventName, handler) {
    if (!this.widget) return;

    const scEvent = SC.Widget.Events[eventName];
    if (!scEvent) return;

    this.widget.unbind(scEvent);

    // Remove from tracking
    const handlers = this.eventHandlers.get(eventName);
    if (handlers) {
      const index = handlers.indexOf(handler);
      if (index > -1) {
        handlers.splice(index, 1);
      }
    }
  }

  // Cleanup all event handlers
  cleanup() {
    if (!this.widget) return;

    this.eventHandlers.forEach((handlers, eventName) => {
      const scEvent = SC.Widget.Events[eventName];
      if (scEvent) {
        this.widget.unbind(scEvent);
      }
    });

    this.eventHandlers.clear();
    console.log("✅ SoundCloud player cleaned up");
  }

  // Ensure widget is ready before operation
  async ensureReady() {
    if (this.isReady) return;

    if (this.readyPromise) {
      return this.readyPromise;
    }

    this.readyPromise = this.initialize();
    return this.readyPromise;
  }
}

// Create SoundCloud embed URL
export function createWidgetSrc(soundUrl, autoPlay = false) {
  const params = new URLSearchParams({
    url: soundUrl,
    color: "#94bfff",
    auto_play: autoPlay ? "true" : "false",
    hide_related: "true",
    show_comments: "false",
    show_user: "false",
    show_reposts: "false",
    show_teaser: "false",
    visual: "false",
    show_artwork: "false",
    buying: "false",
    sharing: "false",
    download: "false",
    show_playcount: "false",
  });
  return `${AUDIO.SOUNDCLOUD_BASE_URL}?${params.toString()}`;
}

// Retry helper for loading SoundCloud API
export async function waitForSoundCloudAPI() {
  let retries = 0;
  while (typeof SC === "undefined" && retries < AUDIO.WIDGET_LOAD_RETRIES) {
    await new Promise(resolve => setTimeout(resolve, AUDIO.RETRY_INTERVAL));
    retries++;
  }

  if (typeof SC === "undefined") {
    throw new Error("SoundCloud API failed to load after retries");
  }

  return true;
}

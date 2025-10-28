// ============================================
// MOBILE RADIO STATION RENDERER
// ============================================
import { getKeyColors } from './color-system.js';

// Layout ID to display name mapping
const LAYOUT_NAMES = {
  'constellations': 'Zodiac Weave',
  'helix': 'Spiral Helix',
  'scatter': 'Lunar Drift',
  'tempo-spiral': 'Tempo Ascendant'
};

export function getLayoutName(layoutId) {
  return LAYOUT_NAMES[layoutId] || 'Constellation';
}

let revealObserver = null;

function clamp01(value, fallback = 0.5) {
  if (Number.isFinite(value)) {
    if (value < 0) return 0;
    if (value > 1) return 1;
    return value;
  }
  return fallback;
}

/**
 * Convert hex color to RGB components for CSS custom properties
 */
function hexToRgb(hex) {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result ? {
    r: parseInt(result[1], 16),
    g: parseInt(result[2], 16),
    b: parseInt(result[3], 16)
  } : { r: 224, g: 160, b: 255 }; // Fallback purple
}

/**
 * Create a single-track radio station display
 */
export function createRadioStationView(track, layoutName = 'Constellation') {
  const view = document.createElement('div');
  view.className = 'radio-station';
  view.dataset.trackId = track.id;

  const displayNumber = Number.isFinite(track.trackNumber) ? track.trackNumber : '—';
  const duration = track.duration || '0:00';
  const bpm = Number.isFinite(track.bpm) ? track.bpm : '—';
  const key = track.key || '—';
  const focusValue = clamp01(track.focusValue, 0.5);
  const pulseValue = clamp01(track.pulseValue, 0.5);
  const focusPercent = Math.round(focusValue * 100);
  const pulsePercent = Math.round(pulseValue * 100);
  const focusLabel = track.focus || 'Focus';
  const pulseLabel = track.pulse || 'Pulse';

  // Get key-based colors
  const colors = getKeyColors(track.key);
  const rgb = hexToRgb(colors.coreInner);

  // Set CSS custom properties
  view.style.setProperty('--station-color', colors.coreInner);
  view.style.setProperty('--station-color-rgb', `${rgb.r}, ${rgb.g}, ${rgb.b}`);

  // Build radio station HTML
  view.innerHTML = `
    <div class="radio-station__glow" aria-hidden="true"></div>

    <div class="radio-station__header">
      <div class="radio-station__station-id">
        <span class="radio-station__label">You're listening to</span>
        <h2 class="radio-station__station-name">${layoutName}</h2>
      </div>
    </div>

    <div class="radio-station__content">
      <h3 class="radio-station__title">${track.title}</h3>

      <div class="radio-station__meta-grid">
        <div class="radio-station__meta-item">
          <span class="radio-station__meta-label">Duration</span>
          <span class="radio-station__meta-value">${duration}</span>
        </div>
        <div class="radio-station__meta-item">
          <span class="radio-station__meta-label">BPM</span>
          <span class="radio-station__meta-value">${bpm}</span>
        </div>
        <div class="radio-station__meta-item">
          <span class="radio-station__meta-label">Key</span>
          <span class="radio-station__meta-value">${key}</span>
        </div>
        <div class="radio-station__meta-item">
          <span class="radio-station__meta-label">Track</span>
          <span class="radio-station__meta-value">${displayNumber}</span>
        </div>
      </div>

      <div class="radio-station__stats">
        <div class="radio-station__stat">
          <div class="radio-station__stat-header">
            <span class="radio-station__stat-label">Focus</span>
            <span class="radio-station__stat-name">${focusLabel} (${focusPercent}%)</span>
          </div>
          <div class="radio-station__stat-bar">
            <div class="radio-station__stat-fill" style="width: ${focusPercent}%"></div>
          </div>
        </div>

        <div class="radio-station__stat">
          <div class="radio-station__stat-header">
            <span class="radio-station__stat-label">Pulse</span>
            <span class="radio-station__stat-name">${pulseLabel} (${pulsePercent}%)</span>
          </div>
          <div class="radio-station__stat-bar">
            <div class="radio-station__stat-fill" style="width: ${pulsePercent}%"></div>
          </div>
        </div>
      </div>
    </div>
  `;

  return view;
}

/**
 * Render radio station view with single track display
 */
export function renderMobileTracklist(tracks, container, currentTrackId = null, layoutName = 'Zodiac Weave') {
  if (!container) {
    console.warn('Mobile tracklist container not found');
    return null;
  }

  // Clear existing content
  container.innerHTML = '';

  // Find the track to display (current playing or first track)
  let trackToDisplay = tracks.find(t => t.id === currentTrackId) || tracks[0];
  if (!trackToDisplay && tracks.length > 0) {
    trackToDisplay = tracks[0];
  }

  if (!trackToDisplay) {
    console.warn('No track to display in radio station view');
    return null;
  }

  // Create and append radio station view
  const stationView = createRadioStationView(trackToDisplay, layoutName);
  container.appendChild(stationView);

  // Fade in animation
  requestAnimationFrame(() => {
    stationView.classList.add('is-visible');
  });

  console.log(`✅ Rendered radio station view: ${trackToDisplay.title}`);

  return stationView;
}

/**
 * Update radio station view to show current track
 */
export function updatePlayingCard(trackId, tracks = null, layoutName = 'Zodiac Weave') {
  const container = document.getElementById('mobile-tracklist');
  if (!container || !trackId || !tracks) return null;

  const track = tracks.find(t => t.id === trackId);
  if (!track) return null;

  // Check if station view already exists
  const existingStation = container.querySelector('.radio-station');

  if (!existingStation) {
    // First time - render full view
    return renderMobileTracklist(tracks, container, trackId, layoutName);
  }

  // Update only the data that changes, not titles
  updateStationData(existingStation, track, layoutName);

  return existingStation;
}

/**
 * Update station data without re-rendering titles
 */
function updateStationData(stationView, track, layoutName) {
  const displayNumber = Number.isFinite(track.trackNumber) ? track.trackNumber : '—';
  const duration = track.duration || '0:00';
  const bpm = Number.isFinite(track.bpm) ? track.bpm : '—';
  const key = track.key || '—';
  const focusValue = clamp01(track.focusValue, 0.5);
  const pulseValue = clamp01(track.pulseValue, 0.5);
  const focusPercent = Math.round(focusValue * 100);
  const pulsePercent = Math.round(pulseValue * 100);
  const focusLabel = track.focus || 'Focus';
  const pulseLabel = track.pulse || 'Pulse';

  // Get key-based colors
  const colors = getKeyColors(track.key);
  const rgb = hexToRgb(colors.coreInner);

  // Update CSS custom properties
  stationView.style.setProperty('--station-color', colors.coreInner);
  stationView.style.setProperty('--station-color-rgb', `${rgb.r}, ${rgb.g}, ${rgb.b}`);
  stationView.dataset.trackId = track.id;

  // Update station name (without fade)
  const stationNameEl = stationView.querySelector('.radio-station__station-name');
  if (stationNameEl && stationNameEl.textContent !== layoutName) {
    stationNameEl.textContent = layoutName;
  }

  // Update track title (without fade)
  const titleEl = stationView.querySelector('.radio-station__title');
  if (titleEl && titleEl.textContent !== track.title) {
    titleEl.textContent = track.title;
  }

  // Update meta values with smooth transitions
  const metaItems = stationView.querySelectorAll('.radio-station__meta-item');
  const metaValues = [duration, bpm, key, displayNumber];
  metaItems.forEach((item, index) => {
    const valueEl = item.querySelector('.radio-station__meta-value');
    if (valueEl) {
      valueEl.style.opacity = '0.5';
      setTimeout(() => {
        valueEl.textContent = metaValues[index];
        valueEl.style.opacity = '1';
      }, 150);
    }
  });

  // Update focus stat
  const focusStatName = stationView.querySelector('.radio-station__stat:first-child .radio-station__stat-name');
  const focusFill = stationView.querySelector('.radio-station__stat:first-child .radio-station__stat-fill');
  if (focusStatName && focusFill) {
    focusStatName.style.opacity = '0.5';
    setTimeout(() => {
      focusStatName.textContent = `${focusLabel} (${focusPercent}%)`;
      focusStatName.style.opacity = '1';
    }, 150);
    focusFill.style.width = `${focusPercent}%`;
  }

  // Update pulse stat
  const pulseStatName = stationView.querySelector('.radio-station__stat:last-child .radio-station__stat-name');
  const pulseFill = stationView.querySelector('.radio-station__stat:last-child .radio-station__stat-fill');
  if (pulseStatName && pulseFill) {
    pulseStatName.style.opacity = '0.5';
    setTimeout(() => {
      pulseStatName.textContent = `${pulseLabel} (${pulsePercent}%)`;
      pulseStatName.style.opacity = '1';
    }, 150);
    pulseFill.style.width = `${pulsePercent}%`;
  }
}

/**
 * Initialize mobile radio station (call this on page load for mobile)
 */
export function initMobileTracklist(tracks, onTrackSelect, activeTrackId = null, layoutName = 'Zodiac Weave') {
  const container = document.getElementById('mobile-tracklist');
  if (!container) {
    console.warn('Mobile tracklist not available (desktop mode?)');
    return;
  }

  renderMobileTracklist(tracks, container, activeTrackId, layoutName);

  console.log('✅ Mobile radio station initialized');
}

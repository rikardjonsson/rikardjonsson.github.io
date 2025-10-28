// ============================================
// MOBILE TRACKLIST RENDERER
// ============================================
import { getKeyColors } from './color-system.js';

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
 * Create a single track card element
 */
export function createTrackCard(track, index) {
  const card = document.createElement('div');
  card.className = 'track-card';
  card.dataset.trackId = track.id;
  card.dataset.index = index;
  card.dataset.sequence = String(index);
  card.setAttribute('role', 'button');
  card.setAttribute('tabindex', '0');
  card.setAttribute('aria-pressed', 'false');

  const displayNumber = Number.isFinite(track.trackNumber) ? track.trackNumber : index + 1;
  const paddedNumber = String(displayNumber).padStart(2, '0');
  const duration = track.duration || '0:00';
  const bpm = Number.isFinite(track.bpm) ? track.bpm : '—';
  const focusValue = clamp01(track.focusValue, 0.5);
  const pulseValue = clamp01(track.pulseValue, 0.5);
  const focusPercent = Math.round(focusValue * 100);
  const pulsePercent = Math.round(pulseValue * 100);
  const focusLabel = track.focus || 'Focus';
  const pulseLabel = track.pulse || 'Pulse';

  card.setAttribute('aria-label', `${track.title} — ${duration}`);
  card.dataset.trackNumber = String(displayNumber);

  // Get key-based colors
  const colors = getKeyColors(track.key);
  const rgb = hexToRgb(colors.coreInner);

  // Set CSS custom properties for this card
  card.style.setProperty('--card-key-color', colors.coreInner);
  card.style.setProperty('--card-key-color-rgb', `${rgb.r}, ${rgb.g}, ${rgb.b}`);

  // Build card HTML
  card.innerHTML = `
    <div class="track-card__halo" aria-hidden="true"></div>
    <div class="track-card__header">
      <div class="track-card__heading">
        <span class="track-card__number">${paddedNumber}</span>
        <div class="track-card__title-wrap">
          <h3 class="track-card__title">${track.title}</h3>
          <p class="track-card__meta">${track.key} • ${bpm} BPM</p>
        </div>
      </div>
      <div class="track-card__duration" aria-label="Duration">${duration}</div>
    </div>

    <div class="track-card__stats">
      <div class="track-card__stat track-card__stat--focus">
        <div class="track-card__stat-head">
          <span class="track-card__stat-label">Focus</span>
          <span class="track-card__stat-name">${focusLabel}</span>
          <span class="track-card__stat-value">${focusPercent}%</span>
        </div>
        <div
          class="track-card__stat-bar"
          role="progressbar"
          aria-label="Focus ${focusLabel}"
          aria-valuemin="0"
          aria-valuemax="100"
          aria-valuenow="${focusPercent}"
        >
          <div class="track-card__stat-fill" style="--stat-fill: ${focusPercent}%"></div>
        </div>
      </div>

      <div class="track-card__stat track-card__stat--pulse">
        <div class="track-card__stat-head">
          <span class="track-card__stat-label">Pulse</span>
          <span class="track-card__stat-name">${pulseLabel}</span>
          <span class="track-card__stat-value">${pulsePercent}%</span>
        </div>
        <div
          class="track-card__stat-bar"
          role="progressbar"
          aria-label="Pulse ${pulseLabel}"
          aria-valuemin="0"
          aria-valuemax="100"
          aria-valuenow="${pulsePercent}"
        >
          <div class="track-card__stat-fill" style="--stat-fill: ${pulsePercent}%"></div>
        </div>
      </div>
    </div>

    <div class="track-card__state" aria-hidden="true">
      <span class="track-card__state-icon track-card__state-icon--play">▶</span>
      <span class="track-card__state-icon track-card__state-icon--pause">❚❚</span>
    </div>
  `;

  return card;
}

/**
 * Render all track cards into the mobile tracklist container
 */
export function renderMobileTracklist(tracks, container) {
  if (!container) {
    console.warn('Mobile tracklist container not found');
    return [];
  }

  if (revealObserver) {
    revealObserver.disconnect();
    revealObserver = null;
  }

  // Clear existing content
  container.innerHTML = '';

  // Sort tracks by track number to mirror album sequencing
  const orderedTracks = [...tracks].sort((a, b) => {
    const aNum = Number.isFinite(a.trackNumber) ? a.trackNumber : Number.POSITIVE_INFINITY;
    const bNum = Number.isFinite(b.trackNumber) ? b.trackNumber : Number.POSITIVE_INFINITY;
    if (aNum === bNum) {
      return tracks.indexOf(a) - tracks.indexOf(b);
    }
    return aNum - bNum;
  });

  // Create and append track cards
  orderedTracks.forEach((track, index) => {
    const card = createTrackCard(track, index);
    container.appendChild(card);
  });

  console.log(`✅ Rendered ${tracks.length} track cards to mobile tracklist`);

  const cards = Array.from(container.querySelectorAll('.track-card'));

  if (typeof IntersectionObserver === 'undefined') {
    requestAnimationFrame(() => {
      cards.forEach((card) => card.classList.add('is-visible'));
    });
    return cards;
  }

  const scrollRoot = container.closest('.mobile-tracklist') ?? null;
  revealObserver = new IntersectionObserver((entries, observer) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add('is-visible');
        observer.unobserve(entry.target);
      }
    });
  }, {
    root: scrollRoot,
    threshold: 0.25,
    rootMargin: '0px 0px -10% 0px',
  });

  cards.forEach((card) => {
    card.classList.remove('is-visible');
    revealObserver.observe(card);
  });

  return cards;
}

/**
 * Update playing state for track cards
 */
export function updatePlayingCard(trackId) {
  const allCards = document.querySelectorAll('.track-card');
  let activeCard = null;

  allCards.forEach(card => {
    if (card.dataset.trackId === trackId) {
      card.classList.add('is-playing');
      card.setAttribute('aria-pressed', 'true');
      activeCard = card;
      // Scroll card into view if not visible
      requestAnimationFrame(() => {
        card.scrollIntoView({ behavior: 'smooth', block: 'center' });
      });
    } else {
      card.classList.remove('is-playing');
      card.setAttribute('aria-pressed', 'false');
    }
  });

  return activeCard;
}

/**
 * Attach click handlers to track cards
 */
export function attachTrackCardHandlers(onTrackSelect) {
  const container = document.getElementById('mobile-tracklist');
  if (!container) return;

  if (container.dataset.handlersBound === 'true') {
    console.log('ℹ️ Track card handlers already bound, skipping rebind');
    return;
  }

  // Use event delegation for performance
  container.addEventListener('click', (event) => {
    const card = event.target.closest('.track-card');
    if (card) {
      const trackId = card.dataset.trackId;
      if (trackId && onTrackSelect) {
        onTrackSelect(trackId);
      }
    }
  });

  container.addEventListener('keydown', (event) => {
    if (event.key !== 'Enter' && event.key !== ' ' && event.key !== 'Spacebar') return;
    const card = event.target.closest('.track-card');
    if (!card) return;
    const trackId = card.dataset.trackId;
    if (!trackId) return;
    event.preventDefault();
    if (onTrackSelect) {
      onTrackSelect(trackId);
    }
  });

  console.log('✅ Track card click handlers attached');
  container.dataset.handlersBound = 'true';
}

/**
 * Initialize mobile tracklist (call this on page load for mobile)
 */
export function initMobileTracklist(tracks, onTrackSelect, activeTrackId = null) {
  const container = document.getElementById('mobile-tracklist');
  if (!container) {
    console.warn('Mobile tracklist not available (desktop mode?)');
    return;
  }

  renderMobileTracklist(tracks, container);
  attachTrackCardHandlers(onTrackSelect);

  if (activeTrackId) {
    updatePlayingCard(activeTrackId);
  }

  console.log('✅ Mobile tracklist initialized');
}

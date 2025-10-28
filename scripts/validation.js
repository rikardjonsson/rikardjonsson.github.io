// ============================================
// DATA VALIDATION
// ============================================
import { VALIDATION } from './constants.js';

const TRACK_SCHEMA = {
  id: { type: 'string', required: true },
  title: { type: 'string', required: true },
  trackNumber: { type: 'number', required: true },
  duration: { type: 'string', required: false },
  bpm: { type: 'number', min: VALIDATION.MIN_BPM, max: VALIDATION.MAX_BPM, required: true },
  key: { type: 'string', pattern: VALIDATION.KEY_PATTERN, required: true },
  soundcloudId: { type: 'string', required: true },
  focus: { type: 'string', required: false },
  focusValue: { type: 'number', min: 0, max: 1, required: false },
  pulse: { type: 'string', required: false },
  pulseValue: { type: 'number', min: 0, max: 1, required: false },
};

export function validateTrack(track, index) {
  const errors = [];

  if (!track || typeof track !== 'object') {
    errors.push(`Track ${index}: Invalid track object`);
    return errors;
  }

  for (const [field, rules] of Object.entries(TRACK_SCHEMA)) {
    const value = track[field];

    if (rules.required && (value === undefined || value === null || value === '')) {
      errors.push(`Track ${index} (${track.title || 'Unknown'}): Missing required field "${field}"`);
      continue;
    }

    if (value !== undefined && value !== null && value !== '') {
      if (rules.type && typeof value !== rules.type) {
        errors.push(`Track ${index} (${track.title}): "${field}" must be ${rules.type}, got ${typeof value}`);
      }

      if (rules.type === 'number') {
        if (!Number.isFinite(value)) {
          errors.push(`Track ${index} (${track.title}): "${field}" must be a finite number`);
        } else {
          if (rules.min !== undefined && value < rules.min) {
            errors.push(`Track ${index} (${track.title}): "${field}" must be >= ${rules.min}`);
          }
          if (rules.max !== undefined && value > rules.max) {
            errors.push(`Track ${index} (${track.title}): "${field}" must be <= ${rules.max}`);
          }
        }
      }

      if (rules.pattern && !rules.pattern.test(String(value))) {
        errors.push(`Track ${index} (${track.title}): "${field}" has invalid format (expected pattern: ${rules.pattern})`);
      }
    }
  }

  return errors;
}

export function validateAlbum(album) {
  const errors = [];

  if (!album) {
    throw new Error('Album data is null or undefined');
  }

  if (!album.tracks || !Array.isArray(album.tracks)) {
    throw new Error('Album must have a tracks array');
  }

  if (album.tracks.length === 0) {
    throw new Error('Album must have at least one track');
  }

  // Validate each track
  album.tracks.forEach((track, i) => {
    errors.push(...validateTrack(track, i + 1));
  });

  // Check for duplicate IDs
  const ids = new Set();
  album.tracks.forEach((track, i) => {
    if (track.id) {
      if (ids.has(track.id)) {
        errors.push(`Track ${i + 1} (${track.title}): Duplicate ID "${track.id}"`);
      }
      ids.add(track.id);
    }
  });

  // Check for duplicate track numbers
  const trackNumbers = new Set();
  album.tracks.forEach((track, i) => {
    if (track.trackNumber) {
      if (trackNumbers.has(track.trackNumber)) {
        errors.push(`Track ${i + 1} (${track.title}): Duplicate track number ${track.trackNumber}`);
      }
      trackNumbers.add(track.trackNumber);
    }
  });

  if (errors.length > 0) {
    console.warn('⚠️ Album validation issues found:', errors);
  } else {
    console.log('✅ Album data validation passed');
  }

  return errors;
}

export function sanitizeTrack(track) {
  // Ensure required fields have defaults
  return {
    ...track,
    focusValue: Number.isFinite(track.focusValue) ? track.focusValue : 0.5,
    pulseValue: Number.isFinite(track.pulseValue) ? track.pulseValue : 0.5,
    bpm: Number.isFinite(track.bpm) ? track.bpm : 100,
  };
}

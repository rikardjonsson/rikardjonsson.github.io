// ============================================
// COLOR SYSTEM
// ============================================
import { COLORS, COLOR_PALETTES, HALO } from './constants.js';
import { extractKeyRoot, adjustColor, withAlpha } from './utils.js';

export function getKeyColors(key) {
  const root = extractKeyRoot(key);
  const isMajor = key?.includes("Maj");

  const idx = COLORS.KEY_ORDER.indexOf(root);
  const palette = COLOR_PALETTES[idx >= 0 ? idx : 0];

  const brightness = isMajor ? COLORS.MAJOR_BRIGHTNESS : COLORS.MINOR_BRIGHTNESS;
  const haloAlpha = isMajor ? COLORS.MAJOR_HALO_ALPHA : COLORS.MINOR_HALO_ALPHA;

  return {
    coreInner: adjustColor(palette.inner, brightness),
    coreMid: adjustColor(palette.mid, brightness),
    coreOuter: adjustColor(palette.outer, brightness),
    haloFill: withAlpha(palette.halo, haloAlpha),
    flareFill: palette.flare,
    sparkFill: adjustColor(palette.spark, isMajor ? 0.9 : 0.75),
  };
}

export function calculateHaloOpacity(pulseValue) {
  const pulseVal = Number.isFinite(pulseValue) ? pulseValue : 0;
  const baseOpacity = HALO.BASE_OPACITY + pulseVal * HALO.PULSE_MULTIPLIER;
  const hoverOpacity = Math.min(1, baseOpacity + HALO.HOVER_BONUS);
  const playOpacity = Math.min(1, baseOpacity + HALO.PLAY_BONUS);

  return {
    active: Math.max(0, Math.min(1, baseOpacity)),
    hover: hoverOpacity,
    play: playOpacity,
  };
}

export function calculateGlowSize(bpm) {
  return COLORS.BPM_GLOW_BASE + (bpm - 70) / COLORS.BPM_GLOW_DIVISOR;
}

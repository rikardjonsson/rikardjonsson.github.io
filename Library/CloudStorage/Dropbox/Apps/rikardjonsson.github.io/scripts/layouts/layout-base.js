// ============================================
// LAYOUT BASE UTILITIES
// ============================================
import { clamp01 } from '../utils.js';

export function normalizePositions(sourcePositions) {
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

export function getLayout(layoutId, tracks) {
  // Dynamic imports would be better, but for now we'll handle this in main
  return null;
}

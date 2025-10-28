// ============================================
// LINK RENDERER (Event-Driven Updates)
// ============================================
import { ANIMATION, CANVAS } from './constants.js';
import { createSVGElement, clamp01 } from './utils.js';
import { state, DOM, getCachedBounds } from './dom-cache.js';

let pendingLinkUpdate = null;

export function mapToCanvasX(value, width) {
  const effectiveWidth = Math.max(width, CANVAS.OFFSET_LEFT + 1);
  return CANVAS.OFFSET_LEFT + (effectiveWidth - CANVAS.OFFSET_LEFT) * clamp01(value);
}

export function mapToCanvasY(value, height) {
  const effectiveHeight = Math.max(height, CANVAS.OFFSET_TOP + 1);
  return CANVAS.OFFSET_TOP + (effectiveHeight - CANVAS.OFFSET_TOP) * clamp01(value);
}

export function createLink(fromId, toId) {
  const line = createSVGElement("line");
  line.classList.add("starmap-link");
  line.dataset.from = fromId;
  line.dataset.to = toId;
  return line;
}

export function updateLinkPosition(line) {
  const fromId = line.dataset.from;
  const toId = line.dataset.to;
  const fromNode = state.nodes.get(fromId);
  const toNode = state.nodes.get(toId);

  if (!fromNode || !toNode) return;

  const bounds = getCachedBounds();
  if (!bounds) return;

  const { width, height } = bounds;

  // Try to use cached positions from dataset first
  let x1 = Number(fromNode.group.dataset.x);
  let y1 = Number(fromNode.group.dataset.y);
  let x2 = Number(toNode.group.dataset.x);
  let y2 = Number(toNode.group.dataset.y);

  // Fallback to calculating from state positions
  if (!Number.isFinite(x1) || !Number.isFinite(y1)) {
    const fromPos = state.positions[fromId];
    if (fromPos) {
      x1 = mapToCanvasX(fromPos.x, width);
      y1 = mapToCanvasY(fromPos.y, height);
    }
  }

  if (!Number.isFinite(x2) || !Number.isFinite(y2)) {
    const toPos = state.positions[toId];
    if (toPos) {
      x2 = mapToCanvasX(toPos.x, width);
      y2 = mapToCanvasY(toPos.y, height);
    }
  }

  // Only update if we have valid coordinates
  if (Number.isFinite(x1) && Number.isFinite(y1) &&
      Number.isFinite(x2) && Number.isFinite(y2)) {
    line.setAttribute("x1", x1);
    line.setAttribute("y1", y1);
    line.setAttribute("x2", x2);
    line.setAttribute("y2", y2);
  }
}

export function updateAllLinkPositions() {
  if (!DOM.linkLayer) return;

  const lines = DOM.linkLayer.querySelectorAll(".starmap-link");
  lines.forEach(updateLinkPosition);
}

// Event-driven link updates (replaces RAF polling)
export function scheduleLinksUpdateOnTransitionEnd() {
  if (pendingLinkUpdate) {
    cancelAnimationFrame(pendingLinkUpdate);
  }

  // Attach transitionend listeners to all nodes
  state.nodes.forEach(({ group }) => {
    const handler = (e) => {
      if (e.propertyName === 'transform' || e.propertyName === 'translate') {
        requestLinkUpdate();
      }
    };

    group.addEventListener('transitionend', handler, { once: true });
  });

  // Also update immediately for initial positioning
  requestLinkUpdate();
}

function requestLinkUpdate() {
  if (pendingLinkUpdate) return;

  pendingLinkUpdate = requestAnimationFrame(() => {
    updateAllLinkPositions();
    pendingLinkUpdate = null;
  });
}

export function cancelPendingLinkUpdates() {
  if (pendingLinkUpdate) {
    cancelAnimationFrame(pendingLinkUpdate);
    pendingLinkUpdate = null;
  }
}

export function renderLinks(links) {
  if (!DOM.linkLayer) return;

  DOM.linkLayer.innerHTML = "";

  if (!links || links.length === 0) return;

  links.forEach(([fromId, toId], index) => {
    const fromNode = state.nodes.get(fromId);
    const toNode = state.nodes.get(toId);

    if (!fromNode || !toNode) return;

    const line = createLink(fromId, toId);

    const baseDelay = index * ANIMATION.LINK_APPEARANCE_DELAY + 200;
    line.dataset.appearanceDelay = String(baseDelay);
    line.style.opacity = "0";
    line.style.transitionDelay = "0s";

    DOM.linkLayer.appendChild(line);
  });

  // Update positions after links are created
  scheduleLinksUpdateOnTransitionEnd();
}

export function revealLinks(delayMs = 0) {
  if (!DOM.linkLayer) return;

  const lines = DOM.linkLayer.querySelectorAll(".starmap-link");
  const baseDelay = Math.max(0, Number(delayMs));

  lines.forEach((line) => {
    const appearanceDelay = Number(line.dataset.appearanceDelay) || 0;
    line.style.transitionDelay = `${(baseDelay + appearanceDelay) / 1000}s`;
    line.style.opacity = "1";
  });
}

export function highlightActiveLinks(activeId) {
  if (!DOM.linkLayer) return;

  const lines = DOM.linkLayer.querySelectorAll(".starmap-link");

  lines.forEach((line) => {
    const fromId = line.dataset.from;
    const toId = line.dataset.to;
    const isActive = activeId && (fromId === activeId || toId === activeId);
    line.classList.toggle("is-active", isActive);
  });
}

export function clearLinks() {
  if (DOM.linkLayer) {
    DOM.linkLayer.innerHTML = "";
  }
  cancelPendingLinkUpdates();
}

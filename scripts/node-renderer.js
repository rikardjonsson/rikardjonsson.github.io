// ============================================
// NODE RENDERER (with proper cleanup)
// ============================================
import { NODE, ANIMATION } from './constants.js';
import { createSVGElement } from './utils.js';
import { getKeyColors, calculateHaloOpacity, calculateGlowSize } from './color-system.js';
import { state, getNode, setNode, clearNodes } from './dom-cache.js';

// Track event listeners for cleanup
const nodeListeners = new WeakMap();

export function calculateNodeRadius(track) {
  const minBpm = NODE.MIN_BPM;
  const maxBpm = NODE.MAX_BPM;
  const minRadius = NODE.MIN_RADIUS;
  const maxRadius = NODE.MAX_RADIUS;

  // Normalize BPM to 0-1 range
  const bpmNormalized = Math.max(0, Math.min(1, (track.bpm - minBpm) / (maxBpm - minBpm)));

  // Calculate radius: slower tracks are smaller, faster tracks are larger
  return minRadius + bpmNormalized * (maxRadius - minRadius);
}

export function createNodeGradient(track, colors, gradientDefs) {
  const gradientId = `node-gradient-${track.id}`;
  const gradient = createSVGElement("radialGradient");
  gradient.setAttribute("id", gradientId);
  gradient.setAttribute("cx", "50%");
  gradient.setAttribute("cy", "50%");
  gradient.setAttribute("r", "50%");

  // Bright white center for star point
  const stopInner = createSVGElement("stop");
  stopInner.setAttribute("offset", "0%");
  stopInner.setAttribute("stop-color", "#ffffff");
  stopInner.setAttribute("stop-opacity", "1");

  // Quick transition to color
  const stopMid = createSVGElement("stop");
  stopMid.setAttribute("offset", "15%");
  stopMid.setAttribute("stop-color", colors.coreInner);
  stopMid.setAttribute("stop-opacity", "0.9");

  // Fade to transparent at edge
  const stopOuter = createSVGElement("stop");
  stopOuter.setAttribute("offset", "100%");
  stopOuter.setAttribute("stop-color", colors.coreMid);
  stopOuter.setAttribute("stop-opacity", "0");

  gradient.appendChild(stopInner);
  gradient.appendChild(stopMid);
  gradient.appendChild(stopOuter);

  if (gradientDefs) {
    gradientDefs.appendChild(gradient);
  }

  return gradientId;
}

export function createNodeElements(track, radius, gradientId, colors) {
  // Detect mobile mode
  const isMobile = document.body.classList.contains('is-mobile');

  const circle = createSVGElement("circle");
  circle.classList.add("track-node__core");
  circle.setAttribute("r", radius);

  // Use solid fill on mobile, gradient on desktop
  if (isMobile) {
    circle.setAttribute("fill", colors?.coreInner || "#e0a0ff");
    circle.setAttribute("stroke", "#ffffff");
    circle.setAttribute("stroke-width", "2");
  } else {
    circle.setAttribute("fill", `url(#${gradientId})`);
  }

  const ring = createSVGElement("circle");
  ring.classList.add("track-node__halo");
  ring.setAttribute("r", radius * NODE.HALO_SCALE);

  const flare = createSVGElement("circle");
  flare.classList.add("track-node__flare");
  flare.setAttribute("r", radius * NODE.FLARE_SCALE);

  const spark = createSVGElement("circle");
  spark.classList.add("track-node__spark");
  spark.setAttribute("r", radius * NODE.SPARK_SCALE);

  const label = createSVGElement("text");
  label.classList.add("track-node__label");
  label.textContent = track.title;
  label.setAttribute("text-anchor", "middle");
  label.setAttribute("dy", `${radius + 18}`);

  return { circle, ring, flare, spark, label };
}

export function attachNodeListeners(group, track, handlers) {
  let touchStartTime = 0;
  let touchMoved = false;

  const listeners = {
    click: () => handlers.onSelect(track.id),
    keydown: (event) => {
      if (event.key === "Enter" || event.key === " ") {
        event.preventDefault();
        handlers.onSelect(track.id);
      }
    },
    pointerenter: () => handlers.onHover(track),
    focus: () => handlers.onFocus(track),
    blur: () => handlers.onBlur?.(track),

    // Touch-optimized interactions
    touchstart: (event) => {
      touchStartTime = Date.now();
      touchMoved = false;

      // Visual feedback on touch
      group.classList.add('is-touching');

      // Add haptic feedback on supported devices
      if ('vibrate' in navigator) {
        navigator.vibrate(10);
      }
    },
    touchmove: () => {
      touchMoved = true;
      group.classList.remove('is-touching');
    },
    touchend: (event) => {
      const touchDuration = Date.now() - touchStartTime;
      group.classList.remove('is-touching');

      // Only trigger if it was a tap (not a swipe)
      if (!touchMoved && touchDuration < 500) {
        event.preventDefault();
        handlers.onSelect(track.id);
      }
    },
    touchcancel: () => {
      group.classList.remove('is-touching');
    }
  };

  Object.entries(listeners).forEach(([event, handler]) => {
    group.addEventListener(event, handler);
  });

  nodeListeners.set(group, listeners);
}

export function removeNodeListeners(group) {
  const listeners = nodeListeners.get(group);
  if (listeners) {
    Object.entries(listeners).forEach(([event, handler]) => {
      group.removeEventListener(event, handler);
    });
    nodeListeners.delete(group);
  }
}

export function createNode(track, index, gradientDefs, handlers) {
  const group = createSVGElement("g");
  group.classList.add("track-node");
  group.dataset.id = track.id;
  group.setAttribute("tabindex", "0");

  // Calculate sizing and colors
  const radius = calculateNodeRadius(track);
  const colors = getKeyColors(track.key);
  const glowSize = calculateGlowSize(track.bpm);
  const haloOpacity = calculateHaloOpacity(track.pulseValue);

  // Set CSS custom properties
  group.style.setProperty("--core-spark", colors.sparkFill);
  group.style.setProperty("--node-halo-fill", colors.haloFill);
  group.style.setProperty("--node-flare-fill", colors.flareFill);
  group.style.setProperty("--glow-size", `${glowSize}px`);
  group.style.setProperty("--node-index", index);
  group.style.setProperty("--halo-active-opacity", haloOpacity.active.toFixed(3));
  group.style.setProperty("--halo-hover-opacity", haloOpacity.hover.toFixed(3));
  group.style.setProperty("--halo-play-opacity", haloOpacity.play.toFixed(3));

  // Create gradient
  const gradientId = createNodeGradient(track, colors, gradientDefs);

  // Create node elements (pass colors for mobile solid fill)
  const { circle, ring, flare, spark, label } = createNodeElements(track, radius, gradientId, colors);

  // Assemble node
  group.appendChild(flare);
  group.appendChild(ring);
  group.appendChild(circle);
  group.appendChild(spark);
  group.appendChild(label);

  // Attach event listeners
  attachNodeListeners(group, track, handlers);

  return { group, circle, ring, flare, spark, track };
}

export function updateNode(track, nodeData) {
  // Update node properties without recreating
  const { group, circle, ring } = nodeData;

  const radius = calculateNodeRadius(track);
  const colors = getKeyColors(track.key);
  const glowSize = calculateGlowSize(track.bpm);
  const haloOpacity = calculateHaloOpacity(track.pulseValue);

  // Update CSS properties
  group.style.setProperty("--core-spark", colors.sparkFill);
  group.style.setProperty("--node-halo-fill", colors.haloFill);
  group.style.setProperty("--node-flare-fill", colors.flareFill);
  group.style.setProperty("--glow-size", `${glowSize}px`);
  group.style.setProperty("--halo-active-opacity", haloOpacity.active.toFixed(3));
  group.style.setProperty("--halo-hover-opacity", haloOpacity.hover.toFixed(3));
  group.style.setProperty("--halo-play-opacity", haloOpacity.play.toFixed(3));

  // Update radius
  circle.setAttribute("r", radius);
  ring.setAttribute("r", radius * NODE.HALO_SCALE);
}

export function cleanupNode(nodeData) {
  if (!nodeData) return;

  const { group } = nodeData;

  // Remove event listeners
  removeNodeListeners(group);

  // Remove from DOM
  if (group.parentNode) {
    group.parentNode.removeChild(group);
  }
}

export function cleanupAllNodes() {
  state.nodes.forEach((nodeData) => {
    cleanupNode(nodeData);
  });
  clearNodes();
  console.log("✅ All nodes cleaned up");
}

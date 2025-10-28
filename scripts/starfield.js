// ============================================
// STARFIELD BACKGROUND ANIMATION
// ============================================
// Provides a lightweight, ambient canvas animation to sit behind the UI.

const STARFIELD_CONFIG = {
  density: 0.00016,             // Stars per pixel squared
  minRadius: 0.4,
  maxRadius: 1.6,
  baseSpeed: 0.0014,            // Pixels per millisecond
  speedVariance: 0.0035,
  directionAngle: -Math.PI / 7,
  directionVariance: Math.PI / 48,
  twinkleSpeedMin: 0.6,
  twinkleSpeedMax: 1.6,
  hueRange: [280, 320],         // Soft magenta hues
  saturation: 52,
  lightnessRange: [70, 92],
  maxOpacity: 0.85,
};

const CLOUD_CONFIG = {
  layers: 4,
  minRadiusFactor: 0.45,
  maxRadiusFactor: 0.92,
  opacityRange: [0.05, 0.1],
  rotationSpeed: 0.000025,
  tintHue: 295,
  tintSaturation: 36,
  tintLightness: 40,
};

const prefersReducedMotion = (() => {
  if (typeof window === "undefined" || typeof window.matchMedia !== "function") {
    return false;
  }
  return window.matchMedia("(prefers-reduced-motion: reduce)").matches;
})();

function randomBetween(min, max) {
  return Math.random() * (max - min) + min;
}

function createStar(width, height) {
  const angle = STARFIELD_CONFIG.directionAngle +
    randomBetween(-STARFIELD_CONFIG.directionVariance, STARFIELD_CONFIG.directionVariance);
  const speed = STARFIELD_CONFIG.baseSpeed + randomBetween(-STARFIELD_CONFIG.speedVariance, STARFIELD_CONFIG.speedVariance);

  return {
    x: Math.random() * width,
    y: Math.random() * height,
    radius: randomBetween(STARFIELD_CONFIG.minRadius, STARFIELD_CONFIG.maxRadius),
    vx: Math.cos(angle) * speed,
    vy: Math.sin(angle) * speed,
    twinkleSpeed: randomBetween(STARFIELD_CONFIG.twinkleSpeedMin, STARFIELD_CONFIG.twinkleSpeedMax),
    twinkleOffset: Math.random() * Math.PI * 2,
    hue: randomBetween(STARFIELD_CONFIG.hueRange[0], STARFIELD_CONFIG.hueRange[1]),
    lightness: randomBetween(STARFIELD_CONFIG.lightnessRange[0], STARFIELD_CONFIG.lightnessRange[1]),
  };
}

export function createStarfieldController(canvas) {
  if (!canvas || prefersReducedMotion) {
    if (canvas) {
      canvas.style.display = "none";
    }
    return null;
  }

  const context = canvas.getContext("2d");
  if (!context) {
    console.warn("⚠️ Unable to acquire 2D context for starfield canvas");
    return null;
  }

  let animationFrame = null;
  let stars = [];
  let width = 0;
  let height = 0;
  let deviceRatio = 1;
  let isRunning = false;
  let lastTimestamp = 0;
  let cloudLayers = [];

  canvas.style.display = "block";

  function resizeCanvas() {
    const { clientWidth, clientHeight } = canvas;
    if (clientWidth === 0 || clientHeight === 0) return;

    const ratio = window.devicePixelRatio || 1;
    if (width === clientWidth && height === clientHeight && deviceRatio === ratio) {
      return;
    }

    width = clientWidth;
    height = clientHeight;
    deviceRatio = ratio;

    canvas.width = Math.round(width * deviceRatio);
    canvas.height = Math.round(height * deviceRatio);
    context.setTransform(deviceRatio, 0, 0, deviceRatio, 0, 0);

    const desiredStarCount = Math.max(30, Math.floor(width * height * STARFIELD_CONFIG.density));
    stars = Array.from({ length: desiredStarCount }, () => createStar(width, height));
    cloudLayers = generateCloudLayers();
  }

  function generateCloudLayers() {
    const diagonal = Math.sqrt(width * width + height * height);
    return Array.from({ length: CLOUD_CONFIG.layers }, () => ({
      radius: randomBetween(CLOUD_CONFIG.minRadiusFactor, CLOUD_CONFIG.maxRadiusFactor) * diagonal,
      opacity: randomBetween(CLOUD_CONFIG.opacityRange[0], CLOUD_CONFIG.opacityRange[1]),
      offsetAngle: randomBetween(0, Math.PI * 2),
      offsetDistance: randomBetween(0.08, 0.28) * diagonal,
    }));
  }

  function update(delta) {
    for (let i = 0; i < stars.length; i += 1) {
      const star = stars[i];
      star.x += star.vx * delta;
      star.y += star.vy * delta;

      const margin = 24;
      if (star.x < -margin) {
        star.x = width + margin;
        star.y += randomBetween(-margin, margin);
      } else if (star.x > width + margin) {
        star.x = -margin;
        star.y += randomBetween(-margin, margin);
      }

      if (star.y < -margin) {
        star.y = height + margin;
        star.x += randomBetween(-margin, margin);
      } else if (star.y > height + margin) {
        star.y = -margin;
        star.x += randomBetween(-margin, margin);
      }
    }
  }

  function draw(timestamp) {
    if (!isRunning) return;
    if (!width || !height) {
      resizeCanvas();
    }

    const delta = lastTimestamp ? timestamp - lastTimestamp : 16;
    lastTimestamp = timestamp;

    context.clearRect(0, 0, width, height);
    update(delta);

    drawClouds(timestamp);

    context.globalCompositeOperation = "lighter";
    for (let i = 0; i < stars.length; i += 1) {
      const star = stars[i];
      const twinkle = (Math.sin(timestamp * 0.001 * star.twinkleSpeed + star.twinkleOffset) + 1) / 2;
      const opacity = 0.35 + twinkle * STARFIELD_CONFIG.maxOpacity * 0.65;
      context.fillStyle = `hsla(${star.hue}, ${STARFIELD_CONFIG.saturation}%, ${star.lightness}%, ${opacity.toFixed(3)})`;
      context.beginPath();
      context.arc(star.x, star.y, star.radius, 0, Math.PI * 2);
      context.fill();
    }
    context.globalCompositeOperation = "source-over";

    animationFrame = window.requestAnimationFrame(draw);
  }

  function drawClouds(timestamp) {
    if (!cloudLayers.length) return;

    context.save();
    context.translate(width / 2, height / 2);
    const rotation = timestamp * CLOUD_CONFIG.rotationSpeed;
    context.rotate(rotation);
    context.globalCompositeOperation = "screen";

    cloudLayers.forEach((layer) => {
      const x = Math.cos(layer.offsetAngle) * layer.offsetDistance;
      const y = Math.sin(layer.offsetAngle) * layer.offsetDistance;
      const radius = layer.radius;

      const gradient = context.createRadialGradient(x, y, radius * 0.1, x, y, radius);
      gradient.addColorStop(0, `hsla(${CLOUD_CONFIG.tintHue}, ${CLOUD_CONFIG.tintSaturation}%, ${CLOUD_CONFIG.tintLightness}%, ${layer.opacity})`);
      gradient.addColorStop(1, "rgba(0, 0, 0, 0)");

      context.fillStyle = gradient;
      context.beginPath();
      context.arc(x, y, radius, 0, Math.PI * 2);
      context.fill();
    });

    context.restore();
    context.globalCompositeOperation = "source-over";
  }

  function start() {
    if (isRunning) return;
    isRunning = true;
    resizeCanvas();
    lastTimestamp = performance.now();
    animationFrame = window.requestAnimationFrame(draw);
  }

  function stop() {
    isRunning = false;
    if (animationFrame) {
      window.cancelAnimationFrame(animationFrame);
      animationFrame = null;
    }
  }

  function destroy() {
    stop();
    stars = [];
  }

  return {
    start,
    stop,
    resize: resizeCanvas,
    destroy,
  };
}

"use client";

import { useEffect, useRef } from "react";

// Same square-dot field and pointer wake as the hero, without the penguin; sized to its parent section.
export function DotField({ still = false }: { still?: boolean }) {
  const canvas = useRef<HTMLCanvasElement>(null);
  useEffect(() => {
    const surface = canvas.current, area = surface?.parentElement;
    const ctx = surface?.getContext("2d");
    if (!surface || !area || !ctx) return;
    const media = matchMedia("(prefers-reduced-motion: reduce)");
    const quiet = still || media.matches; // still: dots only, no wave and no pointer wake
    let width = 0, height = 0, frame = 0, visible = true, last = 0, animateUntil = 0;
    let trail: { x: number; y: number; time: number }[] = [];
    const seed = (x: number, y: number) => { const v = Math.sin(x * 127.1 + y * 311.7) * 43758.5453; return v - Math.floor(v); };
    const draw = (time: number) => {
      ctx.clearRect(0, 0, width, height);
      const step = width < 600 ? 20 : 24;
      trail = trail.filter(p => time - p.time < 950);
      for (let x = 0; x < width; x += step) for (let y = 0; y < height; y += step) {
        const col = x / step, row = y / step;
        const side = Math.pow(Math.abs(x / width - .5) * 2, 3);
        const floor = Math.pow(y / height, 4);
        const density = .02 + side * .3 + floor * .35;
        const wave = .5 + .5 * Math.sin(col * .48 + row * .3 - time * .00065);
        let opacity = seed(col, row) < density ? .19 + wave * .25 : 0, wake = 0;
        for (const p of trail) {
          const d = Math.hypot(x - p.x, y - p.y), life = Math.max(0, 1 - (time - p.time) / 950);
          if (d < 105 && seed(col + 17, row + 9) > .35) wake = Math.max(wake, (1 - d / 105) * life);
        }
        opacity = Math.max(opacity, wake * .9);
        if (opacity < .02) continue;
        ctx.fillStyle = `rgba(73,220,206,${opacity})`;
        const size = wake > .25 ? 12 : 10;
        ctx.fillRect(x + (step - size) / 2, y + (step - size) / 2, size, size);
      }
    };
    const tick = (time: number) => {
      if (time - last > 40) { draw(time); last = time; }
      if (time < animateUntil) frame = requestAnimationFrame(tick); else { frame = 0; trail = []; draw(0); }
    };
    const resize = () => {
      width = area.clientWidth; height = area.clientHeight;
      const ratio = Math.min(devicePixelRatio || 1, 2);
      surface.width = width * ratio; surface.height = height * ratio;
      ctx.setTransform(ratio, 0, 0, ratio, 0, 0);
      draw(0);
    };
    const move = (e: PointerEvent) => {
      if (media.matches || !visible || document.hidden || e.pointerType === "touch") return;
      const b = area.getBoundingClientRect();
      trail.push({ x: e.clientX - b.left, y: e.clientY - b.top, time: performance.now() });
      if (trail.length > 18) trail.shift();
      animateUntil = performance.now() + 1000;
      if (!frame) frame = requestAnimationFrame(tick);
    };
    const resizeObserver = new ResizeObserver(resize);
    const visibility = new IntersectionObserver(([e]) => { visible = e.isIntersecting; });
    resizeObserver.observe(area); visibility.observe(area);
    if (!quiet) area.addEventListener("pointermove", move);
    resize();
    return () => { cancelAnimationFrame(frame); resizeObserver.disconnect(); visibility.disconnect(); area.removeEventListener("pointermove", move); };
  }, []);
  return <canvas className="dot-field" ref={canvas} aria-hidden="true" />;
}

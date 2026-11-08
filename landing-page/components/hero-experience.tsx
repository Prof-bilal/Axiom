"use client";

import Link from "next/link";
import { useEffect, useRef } from "react";
import { agentIcons, type AgentClass } from "@/lib/agent-icons";

// Original five-column letterforms; no reference-site artwork or code is reused.
const letters = [
  ["01110", "11011", "11011", "11111", "11011", "11011", "11011"],
  ["11011", "11011", "01110", "00100", "01110", "11011", "11011"],
  ["11111", "00100", "00100", "00100", "00100", "00100", "11111"],
  ["01110", "11011", "11011", "11011", "11011", "11011", "01110"],
  ["10001", "11011", "11111", "10101", "10001", "10001", "10001"],
];
export function HeroExperience() {
  const canvas = useRef<HTMLCanvasElement>(null);
  const region = useRef<HTMLElement>(null);
  const sign = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const surface = canvas.current;
    const area = region.current, signEl = sign.current;
    if (!surface || !area || !signEl) return;
    const ctx = surface.getContext("2d");
    if (!ctx) return;
    const media = matchMedia("(prefers-reduced-motion: reduce)");
    let width = 0, height = 0, frame = 0, visible = true, last = 0, animateUntil = 0;
    // A stable edge field with a fading, grid-snapped pointer wake.
    let trail: { x: number; y: number; time: number }[] = [];
    // Penguin frames (9 grayscale tiles) are sampled onto a finer 12px dot grid and play once per load.
    const FW = 368, FH = 198, FRAMES = 9, FRAME_MS = 450; // slow ~4s intro, then a gentle idle loop
    let sheet: ImageData | null = null, start = 0;
    const levels = Array.from({ length: 21 }, (_, i) => `rgba(73,220,206,${i / 20})`); // avoids a string per dot per frame
    const lum = (f: number, sx: number, sy: number) =>
      sx < 0 || sy < 0 || sx >= FW || sy >= FH ? 0 : sheet!.data[((sy | 0) * sheet!.width + f * FW + (sx | 0)) * 4];
    // Big pixel wordmark drawn on the canvas inside the placeholder's box; the pointer lifts and pushes nearby cells.
    const born = performance.now();
    let colors = { light: "#c6f7e8", cyan: "#20d6d2", dim: "#126e70", dark: "#244c48" };
    const readColors = () => {
      const cs = getComputedStyle(document.documentElement);
      const get = (name: string, fallback: string) => cs.getPropertyValue(name).trim() || fallback;
      colors = { light: get("--logo-light", colors.light), cyan: get("--cyan", colors.cyan), dim: get("--cyan-dim", colors.dim), dark: get("--logo-dark", colors.dark) };
    };
    const drawSign = (time: number) => {
      const box = signEl.getBoundingClientRect(), bounds = area.getBoundingClientRect();
      const cell = box.width / 290;
      if (cell <= 0) return;
      const left = box.left - bounds.left, top = box.top - bounds.top, radius = cell * 70;
      const elapsed = time === 0 ? Infinity : time - born; // time 0 = settled
      letters.forEach((letter, i) => letter.forEach((row, y) => [...row].forEach((on, x) => {
        if (on !== "1") return;
        const t = Math.min(1, Math.max(0, (elapsed - (i * 5 + x + y) * 18) / 900));
        if (t <= 0) return;
        const ease = 1 - Math.pow(1 - t, 3);
        let cx = left + (i * 60 + x * 10 + 5) * cell, cy = top + (y * 10 + 5) * cell + (1 - ease) * 18 * cell;
        let lift = 0;
        for (const point of trail) {
          const dx = cx - point.x, dy = cy - point.y, dist = Math.hypot(dx, dy);
          if (dist >= radius) continue;
          const life = Math.max(0, 1 - (time - point.time) / 950);
          const w = (1 - dist / radius) * life;
          if (w <= lift) continue;
          lift = w;
        }
        // Push away from the nearest recent pointer position.
        let px = 0, py = 0;
        if (lift > 0) {
          const near = trail[trail.length - 1];
          const dx = cx - near.x, dy = cy - near.y, d = Math.hypot(dx, dy) || 1;
          px = dx / d * lift * cell * 5; py = dy / d * lift * cell * 5;
        }
        cx += px; cy += py;
        const size = cell * 10.05 * (.5 + .5 * ease) * (1 + lift * .35);
        const f = (y * 10) / 70;
        ctx.globalAlpha = ease;
        ctx.fillStyle = lift > .15 ? colors.light : f < .3 ? colors.light : f < .65 ? colors.cyan : colors.dim;
        ctx.fillRect(cx - size / 2, cy - size / 2, size, size);
      })));
      ctx.globalAlpha = 1;
    };
    let artTop = 0;
    let signRect = { l: 0, r: 0, t: 0, b: 0 };
    let shade: { l: number; r: number; t: number; b: number }[] = [];
    const measureShade = () => {
      const o = area.getBoundingClientRect(), pad = 14;
      const note = area.querySelector(".signal-note")?.getBoundingClientRect();
      const sb = signEl.getBoundingClientRect();
      signRect = { l: sb.left - o.left - 10, r: sb.right - o.left + 10, t: sb.top - o.top - 10, b: sb.bottom - o.top + 10 };
      artTop = note ? note.bottom - o.top + 8 : height * .5; // penguin gets its own zone under the copy
      shade = [...area.querySelectorAll(".hero-announcement, h1, .signal-lead, .cta, .signal-note")].map(el => {
        const b = el.getBoundingClientRect();
        return { l: b.left - o.left - pad, r: b.right - o.left + pad, t: b.top - o.top - pad, b: b.bottom - o.top + pad };
      });
    };
    const drawArt = (time: number) => {
      if (!sheet) return;
      const t = time === 0 ? Infinity : Math.max(0, time - start) / FRAME_MS; // time 0 = static final frame
      const f = Math.min(FRAMES - 1, Math.floor(t)), g = Math.min(FRAMES - 1, f + 1), mix = Math.min(1, t - f);
      // Idle after the intro: slow breathing (anchored at the base), glow pulse and a drifting shimmer.
      const idle = time === 0 || media.matches ? 0 : Math.max(0, time - start - FRAMES * FRAME_MS);
      const wave = Math.sin(idle / 6000 * Math.PI * 2);
      const step = width < 600 ? 8 : 7, base = height * 1.3 / FH, scale = base * (1 + .012 * wave); // huge: frame is 1.3x the hero height
      const ox = (width - FW * scale) / 2, oy = height * .66 - FH * base * .6 - (scale - base) * FH * .9; // body centre sits a bit below the middle, under the wordmark
      for (let x = 0; x < width; x += step) {
        for (let y = 0; y < height; y += step) {
          const sx = (x + step / 2 - ox) / scale, sy = (y + step / 2 - oy) / scale;
          const v = (lum(f, sx, sy) * (1 - mix) + lum(g, sx, sy) * mix) / 255;
          if (v < .05) continue;
          // Keep the art quieter behind the headline.
          const d = Math.min(1, Math.hypot((x / width - .5) / .3, (y / height - .5) / .28));
          // The halo can still cross the copy; keep it quiet there.
          let calm = 1;
          for (const r of shade) if (x > r.l && x < r.r && y > r.t && y < r.b) { calm = .3; break; }
          let boost = 1;
          if (idle > 0) boost = v > .7 ? .93 + .07 * wave : 1 + .12 * Math.sin(x * .02 + y * .02 - idle * .0015); // belly and eyes pulse; the halo shimmers
          const opacity = Math.min(1, Math.pow(v, .6) * 1.25) * (.35 + .65 * d) * calm * boost;
          if (opacity < .03) continue;
          ctx.fillStyle = levels[Math.min(20, Math.round(opacity * 20))];
          const size = step * .78;
          ctx.fillRect(x + (step - size) / 2, y + (step - size) / 2, size, size);
        }
      }
    };
    // Agent icons drift across the whole hero; positions are normalised so resizes keep them in place.
    const tint: Record<AgentClass, string> = { OBSERVE: "#49dcce", NORMAL: "#c6f7e8", SENSITIVE: "#ff9418", CORE: "#edf5f5" };
    const drift = agentIcons.map((_, i) => {
      const r = (k: number) => { const v = Math.sin((i + 1) * 91.7 + k * 17.3) * 43758.5453; return v - Math.floor(v); };
      const angle = r(1) * Math.PI * 2, speed = 6 + r(2) * 8;
      return { nx: .04 + r(3) * .92, ny: .06 + r(4) * .9, vx: Math.cos(angle) * speed, vy: Math.sin(angle) * speed, phase: r(5) * 6.28, blink: 1100 + r(6) * 1500 };
    });
    let mouse: { x: number; y: number } | null = null, lastAgents = 0;
    const tip = area.querySelector<HTMLElement>(".agent-tip");
    const drawAgents = (time: number) => {
      const dt = time === 0 || media.matches || !lastAgents ? 0 : Math.min(64, time - lastAgents);
      lastAgents = time === 0 ? 0 : time;
      let hover = -1;
      drift.forEach((a, i) => {
        const near = mouse && Math.hypot(a.nx * width - mouse.x, a.ny * height - mouse.y) < 22;
        if (near) hover = i;
        const slow = near ? .15 : 1;
        a.nx += a.vx * slow * dt / 1000 / width; a.ny += a.vy * slow * dt / 1000 / height;
        if (a.nx < -.03) a.nx = 1.03; else if (a.nx > 1.03) a.nx = -.03;
        if (a.ny < -.03) a.ny = 1.03; else if (a.ny > 1.03) a.ny = -.03;
      });
      const px = width < 600 ? 2.6 : 4;
      drift.forEach((a, i) => {
        const icon = agentIcons[i], hot = i === hover;
        const bob = time === 0 || media.matches ? 0 : Math.sin(time / 1400 + a.phase) * 4;
        const cx = a.nx * width, cy = a.ny * height + bob, size = px * (hot ? 1.4 : 1);
        // Stay quiet over the copy, buttons and the wordmark.
        let calm = 1;
        for (const r of shade) if (cx > r.l && cx < r.r && cy > r.t && cy < r.b) { calm = .22; break; }
        if (cx > signRect.l && cx < signRect.r && cy > signRect.t && cy < signRect.b) calm = .22;
        ctx.globalAlpha = hot ? 1 : .75 * calm;
        ctx.fillStyle = tint[icon.cls];
        const blinkOn = time !== 0 && Math.floor((time + a.phase * 1000) / a.blink) % 3 === 0;
        icon.rows.forEach((row, y) => [...row].forEach((on, x) => {
          if (on === "0") return;
          ctx.fillStyle = on === "2" && !blinkOn ? (icon.cls === "CORE" ? "#20d6d2" : "#ffffff") : tint[icon.cls]; // accent pixel blinks out now and then
          ctx.fillRect(cx + (x - 4) * size, cy + (y - 4) * size, size * .86, size * .86);
        }));
      });
      ctx.globalAlpha = 1;
      if (tip) {
        if (hover >= 0) {
          const a = drift[hover];
          tip.textContent = `${agentIcons[hover].name} · ${agentIcons[hover].cls === "CORE" ? "CORE" : agentIcons[hover].cls} · Designed`;
          tip.style.transform = `translate(${Math.min(width - 190, Math.max(8, a.nx * width + 16))}px, ${a.ny * height - 34}px)`;
          tip.style.opacity = "1";
        } else tip.style.opacity = "0";
      }
    };
    const seed = (x: number, y: number) => {
      const value = Math.sin(x * 127.1 + y * 311.7) * 43758.5453;
      return value - Math.floor(value);
    };
    const draw = (time: number) => {
      ctx.clearRect(0, 0, width, height);
      const step = width < 600 ? 20 : 24;
      trail = trail.filter(point => time - point.time < 950);
      drawArt(time);
      for (let x = 0; x < width; x += step) {
        for (let y = 0; y < height; y += step) {
          const col = x / step, row = y / step;
          const random = seed(col, row);
          const side = Math.pow(Math.abs(x / width - .5) * 2, 5);
          const floor = Math.pow(y / height, 9);
          const density = .012 + side * .2 + floor * .58;
          const wave = .5 + .5 * Math.sin(col * .48 + row * .3 - time * .00065);
          let opacity = random < density ? .19 + wave * .25 : 0;
          let wake = 0;
          for (const point of trail) {
            const distance = Math.hypot(x - point.x, y - point.y);
            const life = Math.max(0, Math.min(1, 1 - (time - point.time) / 950));
            // Scatter bright pixels around the pointer rather than painting a disk.
            if (distance < 105 && seed(col + 17, row + 9) > .35) {
              wake = Math.max(wake, (1 - distance / 105) * life);
            }
          }
          opacity = Math.max(opacity, wake * .9);
          if (opacity < .02) continue;
          ctx.fillStyle = levels[Math.min(20, Math.round(opacity * 20))];
          const size = wake > .25 ? 12 : 10;
          ctx.fillRect(x + (step - size) / 2, y + (step - size) / 2, size, size);
        }
      }
      drawAgents(time);
      drawSign(time);
    };
    const tick = (time: number) => {
      if (time - last > 40) { draw(time); last = time; }
      if (time < animateUntil) frame = requestAnimationFrame(tick);
      else { frame = 0; trail = []; draw(0); }
    };
    const sync = () => {
      readColors();
      if (!media.matches) animateUntil = Infinity; // continuous: idle loop and drifting agents, paused when hidden
      cancelAnimationFrame(frame);
      frame = 0;
      if (!media.matches && visible && !document.hidden && performance.now() < animateUntil) frame = requestAnimationFrame(tick);
      else { trail = []; draw(0); }
    };
    const resize = () => {
      width = area.clientWidth; height = area.clientHeight; measureShade();
      const ratio = Math.min(devicePixelRatio || 1, 2);
      surface.width = width * ratio; surface.height = height * ratio;
      ctx.setTransform(ratio, 0, 0, ratio, 0, 0);
      draw(!media.matches && performance.now() < animateUntil ? performance.now() : 0); // don't flash the settled state mid-intro
    };
    const move = (event: PointerEvent) => {
      if (media.matches || !visible || document.hidden || event.pointerType === "touch") return;
      const bounds = area.getBoundingClientRect();
      trail.push({ x: event.clientX - bounds.left, y: event.clientY - bounds.top, time: performance.now() });
      if (trail.length > 18) trail.shift();
      mouse = { x: event.clientX - bounds.left, y: event.clientY - bounds.top };
      if (!frame) frame = requestAnimationFrame(tick);
    };
    const resizeObserver = new ResizeObserver(resize);
    const visibilityObserver = new IntersectionObserver(([entry]) => { visible = entry.isIntersecting; sync(); });
    resizeObserver.observe(area); visibilityObserver.observe(area);
    media.addEventListener("change", sync);
    document.addEventListener("visibilitychange", sync);
    area.addEventListener("pointermove", move);
    const leave = () => { mouse = null; };
    area.addEventListener("pointerleave", leave);
    if (!media.matches) animateUntil = Infinity;
    resizeObserver.observe(signEl);
    resize(); sync();
    // Decode the sheet, then start the one-shot timeline (a reload re-runs this effect).
    let cancelled = false;
    const img = new Image();
    img.onload = () => {
      if (cancelled) return;
      const off = document.createElement("canvas");
      off.width = img.naturalWidth; off.height = img.naturalHeight;
      const octx = off.getContext("2d");
      if (!octx) return;
      octx.drawImage(img, 0, 0);
      sheet = octx.getImageData(0, 0, off.width, off.height);
      start = performance.now();
      sync();
    };
    img.src = "/hero/penguin-frames.webp";
    return () => {
      cancelled = true;
      cancelAnimationFrame(frame); resizeObserver.disconnect(); visibilityObserver.disconnect();
      media.removeEventListener("change", sync); document.removeEventListener("visibilitychange", sync);
      area.removeEventListener("pointermove", move);
      area.removeEventListener("pointerleave", leave);
    };
  }, []);

  return <section className="signal-hero" ref={region} aria-labelledby="hero-title">
    <canvas className="signal-field" ref={canvas} aria-hidden="true" />
    <span className="agent-tip mono" aria-hidden="true" />
    
    <div className="signal-center">
      <Link className="hero-announcement mono" href="/roadmap/">A new Linux workspace is taking shape <span aria-hidden>→</span></Link>
      <div className="pixel-sign" ref={sign} aria-hidden="true" />
      
      <h1 id="hero-title">A thoughtful Linux desktop. A space of your own.</h1>
      <p className="signal-lead">Made for developers and curious minds.<br className="wide-only" /> Bring your tools, find your focus, make something great.</p>
      <div className="cta"><Link className="btn primary" href="/desktop/">Meet your desktop <span aria-hidden>↗</span></Link><a className="btn" href="#introduction">Take a first look <span aria-hidden>↓</span></a></div>
      <p className="signal-note">In development. Something worth looking forward to.</p>
    </div>

  </section>;
}

export function PageReveals() {
  useEffect(() => {
    if (matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    const nodes = document.querySelectorAll<HTMLElement>(".home > section:not(.signal-hero)");
    const observer = new IntersectionObserver(entries => entries.forEach(entry => {
      if (!entry.isIntersecting) return;
      entry.target.animate([{ opacity: .35, transform: "translateY(22px)" }, { opacity: 1, transform: "translateY(0)" }], { duration: 650, easing: "cubic-bezier(.2,.7,.3,1)" });
      observer.unobserve(entry.target);
    }), { threshold: .08 });
    nodes.forEach(node => observer.observe(node));
    return () => observer.disconnect();
  }, []);
  return null;
}

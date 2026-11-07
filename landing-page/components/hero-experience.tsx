"use client";

import Link from "next/link";
import { useEffect, useRef } from "react";

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

  useEffect(() => {
    const surface = canvas.current;
    const area = region.current;
    if (!surface || !area) return;
    const ctx = surface.getContext("2d");
    if (!ctx) return;
    const media = matchMedia("(prefers-reduced-motion: reduce)");
    let width = 0, height = 0, frame = 0, visible = true, last = 0, animateUntil = 0;
    // A stable edge field with a fading, grid-snapped pointer wake.
    let trail: { x: number; y: number; time: number }[] = [];
    const seed = (x: number, y: number) => {
      const value = Math.sin(x * 127.1 + y * 311.7) * 43758.5453;
      return value - Math.floor(value);
    };
    const draw = (time: number) => {
      ctx.clearRect(0, 0, width, height);
      const step = width < 600 ? 20 : 24;
      trail = trail.filter(point => time - point.time < 950);
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
          ctx.fillStyle = `rgba(73,220,206,${opacity})`;
          const size = wake > .25 ? 12 : 10;
          ctx.fillRect(x + (step - size) / 2, y + (step - size) / 2, size, size);
        }
      }
    };
    const tick = (time: number) => {
      if (time - last > 40) { draw(time); last = time; }
      if (time < animateUntil) frame = requestAnimationFrame(tick);
      else { frame = 0; trail = []; draw(0); }
    };
    const sync = () => {
      cancelAnimationFrame(frame);
      frame = 0;
      if (!media.matches && visible && !document.hidden && performance.now() < animateUntil) frame = requestAnimationFrame(tick);
      else { trail = []; draw(0); }
    };
    const resize = () => {
      width = area.clientWidth; height = area.clientHeight;
      const ratio = Math.min(devicePixelRatio || 1, 2);
      surface.width = width * ratio; surface.height = height * ratio;
      ctx.setTransform(ratio, 0, 0, ratio, 0, 0);
      draw(0);
    };
    const move = (event: PointerEvent) => {
      if (media.matches || !visible || document.hidden || event.pointerType === "touch") return;
      const bounds = area.getBoundingClientRect();
      trail.push({ x: event.clientX - bounds.left, y: event.clientY - bounds.top, time: performance.now() });
      if (trail.length > 18) trail.shift();
      animateUntil = performance.now() + 1000;
      if (!frame) frame = requestAnimationFrame(tick);
    };
    const resizeObserver = new ResizeObserver(resize);
    const visibilityObserver = new IntersectionObserver(([entry]) => { visible = entry.isIntersecting; sync(); });
    resizeObserver.observe(area); visibilityObserver.observe(area);
    media.addEventListener("change", sync);
    document.addEventListener("visibilitychange", sync);
    area.addEventListener("pointermove", move);
    resize(); sync();
    return () => {
      cancelAnimationFrame(frame); resizeObserver.disconnect(); visibilityObserver.disconnect();
      media.removeEventListener("change", sync); document.removeEventListener("visibilitychange", sync);
      area.removeEventListener("pointermove", move);
    };
  }, []);

  return <section className="signal-hero" ref={region} aria-labelledby="hero-title">
    <canvas className="signal-field" ref={canvas} aria-hidden="true" />
    
    <div className="signal-center">
      <Link className="hero-announcement mono" href="/roadmap/">A new Linux workspace is taking shape <span aria-hidden>→</span></Link>
      <div className="pixel-sign" aria-hidden="true"><svg viewBox="0 0 290 70" fill="url(#axiom-wordmark-gradient)"><defs><linearGradient id="axiom-wordmark-gradient" x1="0" y1="0" x2="0" y2="70" gradientUnits="userSpaceOnUse"><stop offset="0" stopColor="var(--logo-light)"/><stop offset=".3" stopColor="var(--logo-light)"/><stop offset=".3" stopColor="var(--cyan)"/><stop offset=".65" stopColor="var(--cyan)"/><stop offset=".65" stopColor="var(--cyan-dim)"/><stop offset="1" stopColor="var(--logo-dark)"/></linearGradient></defs>{letters.flatMap((letter, i) => letter.flatMap((row, y) => [...row].map((cell, x) => cell === "1" ? <rect key={`${i}-${y}-${x}`} x={i * 60 + x * 10} y={y * 10} width="10.05" height="10.05" style={{ animationDelay: `${(i * 5 + x + y) * 18}ms` }} /> : null)))}</svg></div>
      
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

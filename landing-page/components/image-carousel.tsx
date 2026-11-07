"use client";

import { useCallback, useEffect, useRef, useState } from "react";

type Slide = { src: string; alt: string; title: string; caption: string };

export function ImageCarousel({ slides }: { slides: Slide[] }) {
  const [active, setActive] = useState(0);
  const frame = useRef<HTMLDivElement>(null);
  const select = useCallback((index: number) => setActive((index + slides.length) % slides.length), [slides.length]);

  useEffect(() => {
    const node = frame.current;
    if (!node) return;
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === "ArrowRight") { event.preventDefault(); select(active + 1); }
      if (event.key === "ArrowLeft") { event.preventDefault(); select(active - 1); }
    };
    node.addEventListener("keydown", onKeyDown);
    return () => node.removeEventListener("keydown", onKeyDown);
  }, [active, select]);

  const slide = slides[active];
  return <div className="image-carousel" ref={frame} tabIndex={0} aria-roledescription="carousel" aria-label="Axiom desktop gallery">
    <div className="carousel-image"><img key={slide.src} src={slide.src} alt={slide.alt} /><span className="carousel-counter mono">{String(active + 1).padStart(2, "0")} <i>/</i> {String(slides.length).padStart(2, "0")}</span></div>
    <div className="carousel-caption"><div><h3 aria-live="polite">{slide.title}</h3><p>{slide.caption}</p></div><div className="carousel-controls"><button type="button" onClick={() => select(active - 1)} aria-label="Previous image">←</button><button type="button" onClick={() => select(active + 1)} aria-label="Next image">→</button></div></div>
    <div className="carousel-pagination" role="group" aria-label="Choose gallery image">{slides.map((item, index) => <button key={item.src} type="button" onClick={() => select(index)} aria-label={`Show image ${index + 1}: ${item.title}`} aria-pressed={active === index}><span /></button>)}</div>
  </div>;
}

export function Head({ n, title, lead }: { n: string; title: string; lead?: string }) {
  return (
    <header className="head">
      <span className="mono dim">{n}</span>
      <h2>{title}</h2>
      {lead && <p className="lead">{lead}</p>}
    </header>
  );
}


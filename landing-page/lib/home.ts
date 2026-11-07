
export const gallerySlides = [
  { src: "/shots/desktop.webp", alt: "The Axiom desktop, with a top panel, dock and a custom penguin wallpaper.", title: "A workspace of your own", caption: "A first look at the Axiom desktop." },
  { src: "/shots/p3-menu.webp", alt: "The Axiom application menu with apps and session choices.", title: "Everything close at hand", caption: "Find the things you need from one simple menu." },
  { src: "/shots/p3-launcher.webp", alt: "The Axiom app launcher showing installed applications.", title: "Start with an idea", caption: "Find an app and get into your flow." },
  { src: "/shots/p3-activities.webp", alt: "The Axiom Activities overview showing workspaces and open windows.", title: "See your day at a glance", caption: "Keep track of projects and open windows." },
  { src: "/shots/p3-status.webp", alt: "The Axiom status menu showing current device availability.", title: "Your desktop, in context", caption: "See what’s available from the desktop." },
  { src: "/shots/p4-files.webp", alt: "Axiom Files displaying folders and files in a project.", title: "A place for every project", caption: "Browse the files and folders that make up your work." },
  { src: "/shots/p4-trash.webp", alt: "Axiom Files showing items in Trash and their original locations.", title: "A little breathing room", caption: "Review items in Trash and restore what you need." },
  { src: "/shots/p4-clash.webp", alt: "Axiom Files showing a folder while renaming a file.", title: "Everyday file tasks", caption: "Organize your work from one familiar place." },
  { src: "/shots/p4-software.webp", alt: "Axiom Software showing installed applications.", title: "Get to know your apps", caption: "Explore the software already on your desktop." },
  { src: "/shots/p5-displays.webp", alt: "Axiom Settings showing display preferences and confirmation controls.", title: "Make the screen yours", caption: "Adjust display settings with a chance to keep or revert." },
  { src: "/shots/p5-password.webp", alt: "Axiom Settings showing Wi-Fi network controls.", title: "Stay connected", caption: "Manage network connections from Settings." },
  { src: "/shots/p5-bluetooth.webp", alt: "Axiom Settings showing Bluetooth availability.", title: "Know what’s available", caption: "Settings tells you when a device isn’t present." },
  { src: "/shots/p5-power.webp", alt: "Axiom Settings showing power and battery information.", title: "Set your pace", caption: "Choose a power profile and review device status." },
];

export const questions = [
  ["What is Axiom?", "Axiom is a Linux desktop in development for people who build things. It brings your apps, files and everyday workspace together with a calm, considered design."],
  ["Who is it for?", "Developers, curious makers and people who enjoy making their workspace their own. If your day moves between projects, tools and new ideas, you’re who we’re designing for."],
  ["Do I need to use AI?", "No. Axiom’s everyday desktop works independently. Optional AI assistance is part of our future vision, not a feature available today."],
  ["When can I try it?", "Axiom is still in development and isn’t available for public download yet. Explore the desktop for a first look, or visit the roadmap to see what’s ahead."],
];

export const proof = [
  ["5", "development phases complete"],
  ["QEMU", "every milestone boots a real system"],
  ["0", "cloud services needed to use it"],
  ["Open", "repository, docs and evidence"],
];

export const showcase = [
  { size: "wide", tag: "FILES", title: "A place for every project", text: "Browse, rename and organize, with Trash that remembers where things came from.", src: "/shots/p4-files.webp", alt: "Axiom Files showing project folders." },
  { size: "tall", tag: "SETTINGS", title: "Make the screen yours", text: "Change displays with a chance to keep or revert.", src: "/shots/p5-displays.webp", alt: "Axiom Settings display preferences with keep or revert controls." },
  { size: "std", tag: "ACTIVITIES", title: "Your day at a glance", text: "Workspaces and open windows in one overview.", src: "/shots/p3-activities.webp", alt: "Axiom Activities overview." },
  { size: "std", tag: "SOFTWARE", title: "Know your apps", text: "A read-only look at what’s installed.", src: "/shots/p4-software.webp", alt: "Axiom Software listing installed applications." },
];

export const owned = ["Compositor & session boundary", "Shell and panels", "Files, Settings, Terminal, Software", "Security prompts & recovery UX", "AI boundary (planned)"];
export const reused = ["Linux kernel & drivers", "systemd & udev", "Wayland, Mesa, PipeWire", "NetworkManager & BlueZ", "Package management"];

export const aiRules = [
  ["Optional", "The desktop works fully without it."],
  ["Bounded", "Narrow, structured actions. Never unrestricted root or shell."],
  ["Attributed", "Every action is logged, verified and, where possible, recoverable."],
];

// Every claim on the page comes from this file, and each entry names the repo
// document it was taken from. Update it from docs/PHASES.md, never from memory.


export type Phase = {
  n: number;
  name: string;
  status: "done" | "next" | "planned";
  summary: string;
  evidence?: string; // present only when a retained run backs it
  date?: string;
};

export const phases: Phase[] = [
  { n: 0, name: "Architecture reset", status: "done", summary: "Owned layers, upstream boundaries, compositor strategy and the QEMU acceptance path written down; the upstream-derived desktop removed." },
  { n: 1, name: "Bootable base", status: "done", summary: "Minimal image boots to a graphical target with kernel, userspace, networking and graphics.", evidence: "Folded into the Phase 3 QEMU run" },
  { n: 2, name: "Graphical session", status: "done", summary: "Wayland session on a temporary labwc harness manages real Linux apps.", evidence: "Folded into the Phase 3 QEMU run" },
  { n: 3, name: "Shell MVP", status: "done", date: "2026-11-03", summary: "Top panel, dock, launcher, workspaces, tray, notifications and session controls on real session state.", evidence: "21 automated checks; boot to shutdown through the UI at 1920×1080" },
  { n: 4, name: "Core apps", status: "done", date: "2026-11-03", summary: "Files, Settings, Terminal integration and a read-only Software Center.", evidence: "58 automated checks; hostile file names, 10,000-entry folders" },
  { n: 5, name: "System experience", status: "done", date: "2026-11-06", summary: "Wi-Fi, Bluetooth, sound, display, power, keyboard, date and users controls through real services.", evidence: "76 automated checks; wrong Wi-Fi password rejected, display change reverts" },
  { n: 6, name: "Installable system", status: "done", date: "2026-11-08", summary: "Terminal installer, greetd login screen, lock screen and a Developer Hub first-boot job. Closes the no-reboot-persistence gap.", evidence: "Verified in QEMU: blank disk installs, reboots and logs in (real key events); installer unit tests" },
  { n: 7, name: "Packages and updates", status: "next", summary: "Software Center installs, updates and removes through a narrow polkit-gated helper; snapshots roll back a bad update." },
  { n: 8, name: "Daily-driver completeness", status: "planned", summary: "Printing, removable media, screenshots and recording, clipboard, idle lock, input methods, accessibility, a default firewall." },
  { n: 9, name: "Developer edition", status: "planned", summary: "Curated toolchains, git, containers, editors, and an optional Kali-style security-tools set." },
  { n: 10, name: "Hardware and stability", status: "planned", summary: "Intel, AMD and NVIDIA, laptop power, suspend, multi-monitor, HiDPI. Supported, unsupported and untested are recorded, not claimed." },
  { n: 11, name: "Security layer", status: "planned", summary: "Capability permissions, filesystem and network scopes, secret protection, audit; Warden judged against verified behaviour." },
  { n: 12, name: "AI-native layer", status: "planned", summary: "Optional agent runtime, contextual search and automation through typed permissions. The desktop never depends on it." },
  { n: 13, name: "Distribution", status: "planned", summary: "Signed updates, release channels and recovery media, tested for interruption and signature rejection." },
];

export const reused = ["Linux kernel", "libc", "systemd", "udev", "NetworkManager", "PipeWire", "Mesa", "Wayland protocols", "pacman", "Proven boot tools"];
export const owned = [
  ["Compositor and session boundary", "labwc stands in as a temporary harness behind a documented adapter."],
  ["Axiom Shell", "Panel, dock, launcher, notifications, control centre. Quickshell/QML, one process."],
  ["Core apps", "Files, Settings, Software Center, Terminal integration."],
  ["Platform services", "Narrow, individually authorized privileged operations."],
  ["AI boundary and security UX", "Planned: Phases 11 and 12."],
];

export const rules = [
  ["No AI root.", "AI never gets unrestricted root, sudo or a shell passthrough."],
  ["The UI is never root.", "Privileged APIs are narrow and each one authorizes caller, operation and target."],
  ["Works without the cloud.", "The core desktop needs no model, provider or network."],
  ["Nothing faked.", "No hard-coded state or screenshot-only component passes a graphical phase."],
  ["Numbers need measurements.", "A performance claim without a recorded run is not a claim."],
  ["Recovery, not magic undo.", "Actions are attributed and verified; universal undo is never promised."],
];

export const measured = [
  ["QEMU start to login prompt", "67.5 s", "includes firmware and a systemd job waiting for time sync"],
  ["Whole guest memory in use", "676 MB of 2048 MB", "idle desktop"],
  ["Shell RSS, idle", "433 MB", "the largest single cost; no optimization claimed"],
  ["Compositor RSS, idle", "72 MB", "labwc harness"],
  ["Idle CPU, 20 s window", "0.00 %", "shell and compositor"],
  ["Shell IPC toggle, steady state", "≈ 90 ms", "cold start 547 ms"],
];

export const hero = { src: "/shots/desktop.webp", w: 1600, h: 900, alt: "The Axiom desktop: top panel with workspaces 1 to 4, a floating dock, and a penguin wallpaper in cyan and amber light." };

type Shot = { src: string; w: number; h: number; alt: string; cap: string };
export const galleries: { n: number; title: string; note: string; items: Shot[] }[] = [
  {
    n: 3, title: "Shell", note: "2026-11-03 build; the dock icons were refined later.",
    items: [
      { src: "/shots/p3-menu.webp", w: 700, h: 520, alt: "The Axiom menu open: Applications, Files, Terminal, Software, Settings, About, Log Out, Restart, Shut Down.", cap: "Axiom menu: apps, About, Log Out, Restart, Shut Down." },
      { src: "/shots/p3-launcher.webp", w: 900, h: 560, alt: "The launcher with a search field and a list of applications including Code, Files, Firefox and Settings.", cap: "Launcher over real XDG desktop entries." },
      { src: "/shots/p3-activities.webp", w: 1100, h: 619, alt: "The Activities overview: workspaces 1 to 4 and thumbnails of three open windows.", cap: "Activities: four workspaces and the windows on them." },
      { src: "/shots/p3-status.webp", w: 520, h: 330, alt: "The status menu showing Wi-Fi not connected, no audio device found, and AC power with no battery.", cap: "Status menu. “No audio device found” is shown, not hidden." },
    ],
  },
  {
    n: 4, title: "Core apps", note: "2026-11-03 build, 1920×1080.",
    items: [
      { src: "/shots/p4-files.webp", w: 1100, h: 720, alt: "Axiom Files listing a folder of awkward names: a leading dash, spaces, emoji, an archive and a broken link.", cap: "Files in a folder of hostile names, including a broken link." },
      { src: "/shots/p4-trash.webp", w: 1100, h: 720, alt: "Axiom Files showing Trash, with each item’s original location in a second column.", cap: "Trash keeps each item’s original location, so restore knows where to go." },
      { src: "/shots/p4-clash.webp", w: 1100, h: 720, alt: "Axiom Files in a folder with two files, one selected, during a rename test.", cap: "Rename clash test: two files, one selected." },
      { src: "/shots/p4-software.webp", w: 1100, h: 702, alt: "Software Center listing installed applications under a banner saying no repository data is available offline.", cap: "Software Center: installed packages only. The banner says repository data isn’t available." },
    ],
  },
  {
    n: 5, title: "System experience", note: "2026-11-04 to 2026-11-06 builds.",
    items: [
      { src: "/shots/p5-displays.webp", w: 1100, h: 619, alt: "Settings, Displays: a banner reads “Keep these display settings? Reverting in 9 s” with Keep and Revert buttons.", cap: "Display scale change with a 9-second countdown: Keep, or it reverts." },
      { src: "/shots/p5-password.webp", w: 1100, h: 640, alt: "Settings, Network: a saved Wi-Fi network with a password field open and Connect, Password and Forget buttons.", cap: "Wi-Fi join prompt. A wrong password is rejected." },
      { src: "/shots/p5-bluetooth.webp", w: 1100, h: 640, alt: "Settings, Bluetooth: an orange notice saying no Bluetooth adapter was found.", cap: "No Bluetooth adapter: it says so instead of showing an empty list." },
      { src: "/shots/p5-power.webp", w: 1100, h: 620, alt: "Settings, Power: power-saver profile selected, with “No battery detected” and “No controllable backlight”.", cap: "Power profiles from power-profiles-daemon. Missing hardware is stated." },
    ],
  },
];

export const limits = [
  "Installation is verified on a blank QEMU disk only, not on real hardware. There is no public release.",
 "No root licence. Redistribution is not authorized.",
  "Verified in QEMU only, at 1920×1080. Real hardware is Phase 10.",
  "Wi-Fi was simulated and the VM has no backlight or Bluetooth controller.",
  "The Software Center is read-only. It cannot install or update anything.",
  "Logout and restart are not covered by an automated check.",
  "All timings are software-rendered KVM baselines from a loaded host, not hardware figures.",
];

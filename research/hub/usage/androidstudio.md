# Android Studio
## When to use
- You build Android apps in Kotlin or Java with Jetpack Compose or classic views.
- You need an emulator and live device testing in one tool.
- You want Gradle-based builds, build variants, and lint checks.
- You need profilers for memory, CPU, and network in a running app.
## How it works
- A project holds modules (app, library); the Android view groups source, manifests, and resources.
- Gradle build files (build.gradle.kts or build.gradle) configure the build and dependencies.
- Run the app on an emulator or device, then use Logcat, the Layout Inspector, and the Profiler.
- Lint and IDE inspections run during compile to flag bugs and performance issues.
## Not for
- Non-Android projects or lightweight editing; use VS Code, Zed, or Neovim.
- Machines with limited RAM, where the emulator is heavy; use a terminal editor and command-line builds.

## Sources
https://developer.android.com/studio/intro

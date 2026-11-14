# Unity Hub

## When to use
- You develop games or interactive 3D content with Unity on Linux.
- You need several Unity Editor versions side by side and want to switch between them.
- You want to create or open Unity projects and add platform build modules.
- You want Unity's own package repository so Hub updates come through apt or dnf.

## How it works
- A desktop manager for the Unity Editor: it installs, lists and launches Editor versions and projects.
- Ubuntu is the officially supported Linux target (`.deb` via apt); RHEL, CentOS and Fedora use an `.rpm` repository that Unity does not officially support.
- Any distribution can run the AppImage (`UnityHubSetup-x86_64.AppImage`) with no root access.
- The Unity Editor does not run on Linux Arm64 yet, so the Hub cannot run an Editor there.

## Not for
- Arm64 Linux machines that need the Unity Editor.
- Users who need an officially supported Hub on Fedora, RHEL or CentOS.

## Sources
- https://docs.unity.com/hub/install-hub-linux
- https://unity.com/download
- https://unity.com/public-relations/brand

# Frigate

## When to use
- You run IP cameras at home or on a small site and want local video security with no cloud subscription.
- You use Home Assistant and want camera events and detections there.
- You want AI object detection that runs only when motion is seen, to save resources.
- You need retention rules based on detected objects, such as people or cars.

## How it works
- A local network video recorder (NVR) that runs object detection on camera feeds.
- Supports 24/7 recording, RTSP re-streaming, WebRTC and MSE live view, and MQTT.
- Recommended to run in Docker (the official image is `ghcr.io/blakeblackshear/frigate:stable`).
- Detection benefits from a GPU or AI accelerator; the docs say CPU detection is for testing only.

## Not for
- Windows hosts, which the docs say are not officially supported.
- Setups with no spare storage or CPU/GPU for continuous recording and detection.

## Sources
- https://docs.frigate.video/
- https://docs.frigate.video/frigate/installation
- https://github.com/blakeblackshear/frigate

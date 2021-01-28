# Streaming Kiosk for Raspbian

This project adds the kiosk (fullscreen) apps for some popular streaming services to Raspbian. For the time being, the following apps are supported:

- Netflix
- Prime Video
- Spotify ([remotely controllable](https://explore.spotify.com/us/pages/connect-at-home))
- YouTube ([remotely controllable](https://support.google.com/youtube/answer/7640706#TV_code))

![screenshot](https://github.com/barhun/streaming/raw/main/screenshot.png "Screenshot")

## Installation

Run the following command in a terminal to install the project on your system:

```
sh -c "$(wget -qO - https://github.com/barhun/streaming/raw/main/download.sh)"
```

Since the Widevine library is only available for x86 and armv7+, you won't be able to use these apps if you try to install them on a Raspberry Pi 0/1. Raspbian must be running on a Raspberry Pi 2/3/4 or on a Mac/PC to be able to utilize this project.

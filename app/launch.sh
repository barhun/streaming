#!/usr/bin/env sh

exit_with_error () {
  { echo; echo "$@"; } >&2
  exit 1
}

SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

APP_NAME="$1"

case "$APP_NAME" in
  "Netflix") APP_URL="https://netflix.com";;
  "PrimeVideo") APP_URL="https://primevideo.com";;
  "Spotify") APP_URL="https://open.spotify.com";;
  "YouTube") APP_URL="https://youtube.com/tv";;
  *) exit_with_error "Unknown application: $APP_NAME";;
esac

mkdir -p "$SCRIPT_DIR/../$APP_NAME/WidevineCdm"
echo "{\"Path\":\"$SCRIPT_DIR/WidevineCdm\"}" >"$SCRIPT_DIR/../$APP_NAME/WidevineCdm/latest-component-updated-widevine-cdm"

uname -m | grep -q "arm\|aarch" && IS_ARM="TRUE"

[ -z "$IS_ARM" ] && {
  CHROMIUM_EXEC="chromium"
  PLATFORM="Linux i686 (x86_64)"
} || {
  CHROMIUM_EXEC="chromium-browser"
  PLATFORM="CrOS armv7l 13816.82.0"
}

[ "$APP_NAME" = "YouTube" ] &&
USER_AGENT="AppleTV/tvOS/14.6" ||
USER_AGENT="Mozilla/5.0 (X11; $PLATFORM) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.187 Safari/537.36"

shift
exec "$CHROMIUM_EXEC" \
  --app="$APP_URL" \
  --disable-extensions-except="$SCRIPT_DIR/extension" \
  --disable-features=Translate \
  --enable-gpu-memory-buffer-video-frames \
  --enable-gpu-rasterization \
  --enable-native-gpu-memory-buffers \
  --enable-zero-copy \
  --force-overlay-fullscreen-video \
  --kiosk \
  --new-window \
  --ui-enable-zero-copy \
  --user-agent="$USER_AGENT" \
  --user-data-dir="$SCRIPT_DIR/../$APP_NAME" \
  "$@"

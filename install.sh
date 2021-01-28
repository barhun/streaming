#!/usr/bin/env sh

exit_with_error () {
  { echo; echo "$@"; } >&2
  exit 1
}

SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

grep -q "Raspberry Pi" /etc/rpi-issue || exit_with_error "This installation is only available for Raspbian."
grep -q "ARMv6" /proc/cpuinfo && exit_with_error "This installation doesn't support Raspberry Pi 0/1."
sudo echo -n || exit_with_error "This script can only be run by a sudoer."

uname -m | grep -q "arm\|aarch" && IS_ARM="TRUE"

echo; echo "Downloading the Widevine library..."

APP_DIR="$HOME/.streaming/app"
WV_DIR="$APP_DIR/WidevineCdm"
TMP_DIR="$(mktemp -d "$HOME/.widevine.XXXXXX")"

[ -z "$IS_ARM" ] && {
  WIDEVINE_URL="https://dl.google.com/widevine-cdm/$(wget -qO - https://dl.google.com/widevine-cdm/versions.txt 2>/dev/null | grep 4.10.1582.2 | tail -n 1)-linux-ia32.zip"

  wget -qO "$TMP_DIR/widevine.zip" "$WIDEVINE_URL" 2>/dev/null || {
    rm -rf "$TMP_DIR"
    exit_with_error "Error occurred while downloading the Widevine library. Check your internet connection and try again."
  }

  (cd "$TMP_DIR"; unzip -qq "widevine.zip")

  WV_PLATFORM_DIR="$WV_DIR/_platform_specific/linux_x86"
} || {
  WIDEVINE_URL="http://archive.raspberrypi.org/debian/pool/main/w/widevine/libwidevinecdm0_4.10.2252.0+3_armhf.deb"

  wget -qO "$TMP_DIR/widevine.deb" "$WIDEVINE_URL" 2>/dev/null || {
    rm -rf "$TMP_DIR"
    exit_with_error "Error occurred while downloading the Widevine library. Check your internet connection and try again."
  }

  dpkg-deb -x "$TMP_DIR/widevine.deb" "$TMP_DIR"; mv "$TMP_DIR/opt/WidevineCdm/manifest.json" "$TMP_DIR/opt/WidevineCdm/_platform_specific/linux_arm/libwidevinecdm.so" "$TMP_DIR"

  WV_PLATFORM_DIR="$WV_DIR/_platform_specific/linux_arm"
}

mkdir -p "$WV_PLATFORM_DIR"
cp "$TMP_DIR/manifest.json" "$WV_DIR"
cp "$TMP_DIR/libwidevinecdm.so" "$WV_PLATFORM_DIR"
chmod 600 "$WV_DIR/manifest.json" "$WV_PLATFORM_DIR/libwidevinecdm.so"

rm -rf "$TMP_DIR"

echo; echo "Installing the applications..."

cp -r "$SCRIPT_DIR/app/." "$APP_DIR"
chmod +x "$APP_DIR/launch.sh"

find "$SCRIPT_DIR/entries" -mindepth 1 -type f -print | while read -r file; do
  app="$(basename "$file" | cut -d "." -f 1)"

  xdg-icon-resource install --novendor --size 256 "$SCRIPT_DIR/icons/$app.png" "$app"

  [ "$app" != "Streaming" ] &&
  xdg-desktop-menu install --novendor "$SCRIPT_DIR/entries/Streaming.directory" "$file"
done

sudo mv /etc/xdg/autostart/xcompmgr.desktop /etc/xdg/autostart_xcompmgr.desktop >/dev/null 2>&1

echo; echo "Successfully installed the applications."

[ -z "$IS_ARM" ] && exit 0

[ "$(. /etc/os-release; echo "$VERSION_ID")" -gt 10 ] && exit 0

raspi-config nonint is_fkms || {
  REBOOT_REQUIRED="TRUE"

  # Works as a no-op since do_gldriver routine doesn't support noninteractive mode
  sudo raspi-config nonint do_gldriver G2 && {
    echo; echo "GL Driver has been set to FKMS."
  }

  # So we enable it ourselves as the following
  sudo sed /boot/config.txt -i -e "s/^dtoverlay=vc4-kms-v3d/#dtoverlay=vc4-kms-v3d/g"
  sudo sed /boot/config.txt -i -e "s/^#dtoverlay=vc4-fkms-v3d/dtoverlay=vc4-fkms-v3d/g"
  sed -n "/\[pi4\]/,/\[/ !p" /boot/config.txt | grep -q "^dtoverlay=vc4-fkms-v3d" || {
    printf "[all]\ndtoverlay=vc4-fkms-v3d\n" | sudo tee -a /boot/config.txt >/dev/null
  }
}

[ "128" -gt "$(vcgencmd get_mem gpu | cut -d "=" -f 2 | cut -d "M" -f 1)" ] && {
  REBOOT_REQUIRED="TRUE"

  sudo raspi-config nonint do_memory_split 128 && {
    echo; echo "GPU memory size has been set to 128 MB."
  }
}

[ -z "$REBOOT_REQUIRED" ] && exit 0

until echo && read -rp "You need to reboot to see the changes in effect. Do you want to reboot now? (y/n): " answer && echo "$answer" | grep -qx "y\|Y\|n\|N"; do
  echo; echo "Please type 'y' or 'n' to answer the question."
done

echo "$answer" | grep -qx "y\|Y" && (sleep 5; sudo reboot) &

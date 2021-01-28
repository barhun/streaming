#!/usr/bin/env sh

exit_with_error () {
  { echo; echo "$@"; } >&2
  exit 1
}

TMP_DIR="$(mktemp -d "$HOME/.streaming.XXXXXX")"

git clone --depth 1 --single-branch -b main "https://github.com/barhun/streaming" "$TMP_DIR" >/dev/null 2>&1 || {
  rm -rf "$TMP_DIR"
  exit_with_error "Error occurred while downloading the repository. Check your internet connection and try again."
}

sh "$TMP_DIR/install.sh"
rm -rf "$TMP_DIR"

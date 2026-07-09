#!/bin/zsh
set -euo pipefail

if [[ $# -ne 2 ]]; then
  print "Usage: $0 <iphone|ipad> <name-without-extension>"
  print "Example: $0 iphone 01-opening"
  exit 1
fi

DEVICE_KIND="$1"
NAME="$2"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

case "$DEVICE_KIND" in
  iphone)
    OUT_DIR="$ROOT_DIR/screenshots/iPhone-6.9"
    ;;
  ipad)
    OUT_DIR="$ROOT_DIR/screenshots/iPad-13"
    ;;
  *)
    print "Unknown device kind: $DEVICE_KIND"
    print "Use iphone or ipad"
    exit 1
    ;;
esac

mkdir -p "$OUT_DIR"
xcrun simctl io booted screenshot "$OUT_DIR/$NAME.png"
print "Saved $OUT_DIR/$NAME.png"

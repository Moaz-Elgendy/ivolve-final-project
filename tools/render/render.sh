#!/usr/bin/env bash
# usage: render.sh IN.html|IN.svg OUT.png WIDTH HEIGHT
set -euo pipefail
CHROME="${CHROME:-$HOME/.cache/ms-playwright/chromium-1254/chrome-linux64/chrome}"
in="$(realpath "$1")"; out="$(realpath -m "$2")"; w="$3"; h="$4"
if [[ "$in" == *.svg ]]; then
  # wrap SVG so it renders at exact size with zero margin
  tmp="$(mktemp --suffix=.html)"; trap 'rm -f "$tmp"' EXIT
  printf '<!doctype html><meta charset="utf-8"><style>html,body{margin:0;background:#F4F1EA}img{display:block}</style><img src="file://%s" width="%s" height="%s">' "$in" "$w" "$h" > "$tmp"
  in="$tmp"
fi
"$CHROME" --headless=new --no-sandbox --hide-scrollbars --force-device-scale-factor=1 \
  --window-size="$w,$h" --screenshot="$out" "file://$in" >/dev/null 2>&1
[[ -s "$out" ]] || { echo "render failed: $out missing" >&2; exit 1; }

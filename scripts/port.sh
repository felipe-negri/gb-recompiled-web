#!/usr/bin/env bash
# Contrato "web-recomp" do Recompendium: scripts/port.sh <nome> <rom.gb|rom.gbc>
# Gera a página em build/web-<nome>/ (index.html + <jogo>.js + <jogo>.wasm).
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
name="$1"; rom="$2"
EMSDK="${EMSDK:-$root/tools/emsdk}"
work="$root/games/$name"
out="$root/build/web-$name"
echo "== [1/3] gbrecomp"
rm -rf "$work/src" "$work/build" "$work/dist"
mkdir -p "$work"
echo "== [2/3] compilando WASM"
"$root/tools/web/build-web.sh" "$rom" "$work" --emsdk "$EMSDK"
echo "== [3/3] publicando"
rm -rf "$out"
mkdir -p "$(dirname "$out")"
mv "$work/dist" "$out"
# o C gerado e o build intermediário são grandes e saem de novo a cada build
rm -rf "$work/src" "$work/build"

#!/usr/bin/env bash
# Contrato "web-recomp" do Recompendium: prepara um checkout novo (gbrecomp nativo + Emscripten SDK).
# Pode rodar de novo.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
EMSDK="${EMSDK:-$root/tools/emsdk}"
EMSDK_VERSION="7.0.1"
if [ ! -f "$EMSDK/emsdk_env.sh" ]; then
  echo "== instalando o Emscripten SDK $EMSDK_VERSION em $EMSDK"
  git clone -q https://github.com/emscripten-core/emsdk.git "$EMSDK"
  "$EMSDK/emsdk" install "$EMSDK_VERSION"
  "$EMSDK/emsdk" activate "$EMSDK_VERSION"
fi
cmake -G Ninja -S "$root" -B "$root/build" -DCMAKE_BUILD_TYPE=Release > /dev/null
ninja -C "$root/build" gbrecomp
echo "== ready"

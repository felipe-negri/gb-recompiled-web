#!/usr/bin/env bash
# ROM -> página web: gbrecomp gera o C, Emscripten compila para WASM, dist/ fica com index.html + .js + .wasm.
# Uso: tools/web/build-web.sh <rom.gb|rom.gbc> <saida> [--emsdk <dir>]
set -euo pipefail
rom=${1:?uso: build-web.sh <rom> <saida> [--emsdk dir]}; out=${2:?falta a pasta de saída}
emsdk=${EMSDK:-}; [[ ${3:-} == --emsdk ]] && emsdk=${4:?}
repo=$(cd "$(dirname "$0")/../.." && pwd)
gbrecomp=${GBRECOMP:-$repo/build/bin/gbrecomp}

if [[ ! -x $gbrecomp ]]; then
  cmake -G Ninja -S "$repo" -B "$repo/build" -DCMAKE_BUILD_TYPE=Release >/dev/null
  ninja -C "$repo/build" gbrecomp
fi
if ! command -v emcmake >/dev/null; then
  [[ -n $emsdk ]] || { echo "emcmake não encontrado: ative o emsdk ou passe --emsdk <dir>" >&2; exit 1; }
  # shellcheck disable=SC1091
  source "$emsdk/emsdk_env.sh" >/dev/null
fi

"$gbrecomp" "$rom" -o "$out/src"
name=$(sed -n 's/^project(\([^ ]*\) .*/\1/p' "$out/src/CMakeLists.txt")
emcmake cmake -G Ninja -S "$out/src" -B "$out/build" -DCMAKE_BUILD_TYPE=Release >/dev/null
ninja -C "$out/build"
mkdir -p "$out/dist"
cp "$out/build/$name.js" "$out/build/$name.wasm" "$out/dist/"
cp "$out/build/$name.html" "$out/dist/index.html"
echo "Pronto: $out/dist (sirva por HTTP, ex.: python3 -m http.server -d $out/dist)"

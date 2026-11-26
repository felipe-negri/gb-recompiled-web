# Build para navegador (WebAssembly)

```bash
tools/web/build-web.sh caminho/jogo.gbc saida/jogo --emsdk /caminho/do/emsdk
python3 -m http.server -d saida/jogo/dist 8000
```

O projeto gerado pelo `gbrecomp` compila com `emcmake` sem mudanças: quando
`EMSCRIPTEN` está definido, o CMake usa o port de SDL2 do Emscripten e linka com
`-sASYNCIFY`. O laço principal continua bloqueante; ele cede ao navegador em
`gb_platform_vsync` (`emscripten_sleep`) uma vez por quadro.

Saves de bateria e RTC vão para `/saves`, montado em IndexedDB por
`runtime/src/web/pre.js`. Como uma aba fecha sem chamar o encerramento do
runtime, a RAM do cartucho é conferida uma vez por segundo e gravada quando muda.

Limitações conhecidas:

- só o modo de uma ROM; o lançador de várias ROMs (`gbrecomp <pasta>`) não foi adaptado;
- o áudio só começa depois de um clique ou tecla (regra de autoplay do navegador);
- `-sASYNCIFY_IGNORE_INDIRECT`: nada chamado por ponteiro de função pode suspender
  (por isso o `fsync` e o sleep do SDL no `SwapWindow` ficam desligados na web).

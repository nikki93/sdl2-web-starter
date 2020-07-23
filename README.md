# Cloning

Make sure to either `git clone --recursive`, or to do `git submodule update
--init --recursive` after cloning.

# Building / running

You'll need CMake.

## Desktop

`./run.sh release` or `./run.sh debug`. You can make changes in the code and
run that again to rebuild an rerun.

## Web

[Install
emscripten](https://emscripten.org/docs/getting_started/downloads.html#installation-instructions)
in '../emsdk' relative to this repo's root:
```
cd ..
git clone https://github.com/emscripten-core/emsdk.git
./emsdk install latest
./emsdk activate latest
```
Alternatively, point the emscripten path in 'CMakeLists.txt' to an existing
emscripten install you may have, or your package manager's emscripten install.

`./run.sh web-release` or `./run.sh web-debug` will build for web, and you can
serve 'build/web-release' or 'build/web-debug' and see the result in your
browser.

If you install 'entr' and 'node' you can instead use `./run.sh
web-watch-release` or `./run.sh web-watch-debug` to watch for code changes
automatically rebuild, and simultaneously serve with `./run.sh
web-serve-release` or `./run.sh web-serve-debug`. Then you should see your
website at http://localhost:8080.

On Windows you can run these script using WSL.

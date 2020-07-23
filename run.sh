#!/bin/bash

set -e

PLATFORM="macOS"
CMAKE="cmake"

if [[ -f /proc/version ]]; then
  if grep -q Microsoft /proc/version; then
    PLATFORM="win"
    CMAKE="cmake.exe"
  fi
fi

case "$1" in
  # DB
  db)
    $CMAKE -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Debug -H. -Bbuild/db -GNinja
    cp ./build/db/compile_commands.json .
    ;;

  # Desktop
  release)
    case $PLATFORM in
      macOS)
        $CMAKE -H. -Bbuild/release -GNinja
        $CMAKE --build build/release
        ./build/release/sdl-test
        ;;
      win)
        $CMAKE -H. -Bbuild/msvc -G"Visual Studio 16"
        $CMAKE --build build/msvc --config Release
        ./build/msvc/Release/sdl-test.exe 
        ;;
    esac
    ;;
  debug)
    case $PLATFORM in
      macOS)
        $CMAKE -DCMAKE_BUILD_TYPE=Debug -H. -Bbuild/debug -GNinja
        $CMAKE --build build/debug
        ./build/debug/sdl-test
        ;;
      win)
        $CMAKE -H. -Bbuild/msvc -G"Visual Studio 16"
        $CMAKE --build build/msvc --config Debug
        ./build/msvc/Debug/sdl-test.exe 
        ;;
    esac
    ;;

  # Web
  web-release)
    $CMAKE -DWEB=ON -H. -Bbuild/web-release -GNinja
    $CMAKE --build build/web-release
    ;;
  web-debug)
    $CMAKE -DCMAKE_BUILD_TYPE=Debug -DWEB=ON -H. -Bbuild/web-debug -GNinja
    $CMAKE --build build/web-debug
    ;;
  web-watch-release)
    ls -1 CMakeLists.txt main.cc index.html | entr ./run.sh web-release
    ;;
  web-watch-debug)
    ls -1 CMakeLists.txt main.cc index.html | entr ./run.sh web-debug
    ;;
  web-serve-release)
    npx http-server -c-1 build/web-release
    ;;
  web-serve-debug)
    npx http-server -c-1 build/web-debug
    ;;
  web-publish)
    ./run.sh web-release
    rsync -avP build/web-release/{index.*,sdl-test.*} # [Put your web host here!]
    ;;
esac

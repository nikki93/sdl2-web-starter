cmake_minimum_required(VERSION 3.16)


#
# Toolchain
#

if(WEB)
  # Emscripten
  set(CMAKE_TOOLCHAIN_FILE ../emsdk/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake)
endif()


#
# Project
#

project(sdl-test)
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release) # Release build by default
endif()


#
# Target
#

add_executable(sdl-test main.cc)

# Standard
target_compile_features(sdl-test PRIVATE cxx_std_17)
set_target_properties(sdl-test PROPERTIES CXX_EXTENSIONS OFF)

# Warnings
if(MSVC)
  target_compile_options(sdl-test PRIVATE /W4 /WX
    #/wd4100 # Disable 'unreferenced formal parameter'
    /wd4244 # Disable 'possible loss of data'
    /wd4307 # Disable 'integral constant overflow'
    /wd4702 # Disable 'unreachable code'
    )
  target_link_options(sdl-test PRIVATE /WX)
else()
  target_compile_options(sdl-test PRIVATE -fcolor-diagnostics -pedantic-errors -Wall -Wextra -Wno-missing-braces)
  target_link_options(sdl-test PRIVATE -fcolor-diagnostics -pedantic-errors -Wall -Wextra -Wno-missing-braces)
  if(WIN32)
    target_compile_options(sdl-test PRIVATE -Wno-language-extension-token)
    target_link_options(sdl-test PRIVATE -Wno-language-extension-token)
  endif()
endif()

# Web flags
if(WEB)
  target_link_options(sdl-test PRIVATE "SHELL:--bind")
  target_link_options(sdl-test PRIVATE "SHELL:-s WASM=1")
  target_link_options(sdl-test PRIVATE "SHELL:-s MAX_WEBGL_VERSION=2")
  target_link_options(sdl-test PRIVATE "SHELL:-s TOTAL_MEMORY=256MB")
  if ("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    target_compile_options(sdl-test PRIVATE "SHELL:-g4 --source-map-base file://${CMAKE_BINARY_DIR}/ -fsanitize=leak")
    target_link_options(sdl-test PRIVATE "SHELL:-g4 --source-map-base file://${CMAKE_BINARY_DIR}/ -fsanitize=leak")
  endif()
endif()


#
# Dependencies
#

# SDL2
if(WEB)
  target_compile_options(sdl-test PRIVATE "SHELL:-s USE_SDL=2")
  target_link_options(sdl-test PRIVATE "SHELL:-s USE_SDL=2")
else()
  set(SDL_STATIC ON CACHE BOOL "" FORCE)
  set(SDL_SHARED OFF CACHE BOOL "" FORCE)
  add_subdirectory(vendor/SDL2 EXCLUDE_FROM_ALL)
  target_link_libraries(sdl-test PRIVATE SDL2-static)
endif()


#
# Assets
#

# Bundle 'assets/'
if(WEB)
  target_link_options(sdl-test PRIVATE "SHELL:--preload-file ${PROJECT_SOURCE_DIR}/assets@assets")
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "iOS")
  target_sources(sdl-test PRIVATE "assets")
  set_target_properties(sdl-test PROPERTIES RESOURCE "assets")
endif()

# Static web files
if(WEB)
  configure_file(index.html index.html COPYONLY)
endif()

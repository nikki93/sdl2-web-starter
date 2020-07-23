#ifdef __EMSCRIPTEN__
#include <emscripten/emscripten.h>
#endif
#include <SDL.h>

auto main() -> int {
  auto quit = false;

  SDL_Init(SDL_INIT_VIDEO);
  auto window
      = SDL_CreateWindow("sdl-test", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 800, 450, 0);
  auto renderer = SDL_CreateRenderer(window, -1, 0);

  static auto update = [&]() {
    SDL_Event event;
    while (SDL_PollEvent(&event)) {
      switch (event.type) {
      case SDL_QUIT:
        quit = true;
        break;
      }
    }
  };

  static auto draw = [&]() {
    SDL_SetRenderDrawColor(renderer, 0xff, 0x80, 0x80, 0xff);
    SDL_RenderClear(renderer);

    SDL_FRect rect { 10, 10, 100, 100 };
    SDL_SetRenderDrawColor(renderer, 0x80, 0x80, 0xff, 0xff);
    SDL_RenderFillRectF(renderer, &rect);

    SDL_RenderPresent(renderer);
  };

  static auto frame = [&]() {
    update();
    draw();
  };
#ifdef __EMSCRIPTEN__
  emscripten_set_main_loop(
      []() {
        frame();
      },
      0, true);
#else
  while (!quit) {
    frame();
  }
#endif

  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
  SDL_Quit();

  return 0;
}

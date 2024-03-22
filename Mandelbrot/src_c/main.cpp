#include <stdio.h>
#include <SDL2/SDL.h>
#include <math.h>

const int SCREEN_WIDTH  = 1920;
const int SCREEN_HEIGHT = 1080;
const size_t n_max = 80;
const double dx = 1/700.f;
const double dy = 1/700.f; 

const double dscale = 1/100.f;

int sdl_ctor();
int sdl_dtor();

SDL_Window   *window = NULL;
SDL_Renderer *renderer = NULL;
SDL_Event    event;

int main(int argc, char* argv[]) {
    // Initialize SDL
    if (sdl_ctor() == 1) {
        return 1;
    }

    // Wait for the user to close the window
    double x_center = -0.6;
    double y_center = 0;
    double x_0 = 0;
    double y_0 = 0;
    double x = 0;
    double y = 0;
    double x2 = 0;
    double y2 = 0;
    double xy = 0;
    double r2 = 0;
    double r2max = 100.f;
    double scale = 1;
    bool color_flag = 0;
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    bool run = true;
    while (run)
    {
        //Process Keys
        while(SDL_PollEvent(&event) != 0) {
            if (event.type == SDL_QUIT) {
                run = false;
                break;
            }
            if (event.type == SDL_KEYDOWN) {
                if (event.key.keysym.sym == SDLK_UP)        y_center += dy;
                if (event.key.keysym.sym == SDLK_DOWN)      y_center -= dy;
                if (event.key.keysym.sym == SDLK_RIGHT)     x_center -= dx;
                if (event.key.keysym.sym == SDLK_LEFT)      x_center += dx;
                if (event.key.keysym.sym == SDLK_KP_PLUS)   scale -= dscale;    //+ == scale-
                if (event.key.keysym.sym == SDLK_KP_MINUS)  scale += dscale;
            }
        }
        //clear window
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_RenderClear(renderer);
        //body
        for (int y_i = 0; y_i < SCREEN_HEIGHT; y_i++)
        {
            //check for close
            if (event.type == SDL_QUIT) {
                run = false;
                break;
            }
            //set line with height = y0 and x - counting
            x_0 = x_center + (                  - (double)SCREEN_WIDTH  * scale / 2) * dx; 
            y_0 = y_center + ((double)y_i*scale - (double)SCREEN_HEIGHT * scale / 2) * dy;
            for (int x_i = 0; x_i < SCREEN_WIDTH; x_i++ , x_0 += dx*scale)
            {
                color_flag = 0;
                //counting (x,y)
                x = x_0;
                y = y_0;
                //check if (x,y) not run away from circle
                size_t n = 0;
                for (; n < n_max; n++)
                {
                    x2 = x * x;
                    y2 = y * y;
                    xy = x * y;
                    r2 = (x2 + y2);
                    if (r2 > r2max) 
                    {
                        color_flag = 1;
                        break;
                    }   
                    x = x2 - y2 + x_0;
                    y = 2 * xy  + y_0;  
                }
                int r = 0, g = 0, b = 0;
                SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
                if (color_flag)
                {
                    // Normalize the value to the range [0, 1]
                    double normalized = (double)n / (double)n_max;

                    // Use sine waves to create a colorful gradient with smooth transitions
                    double r_n = sin(2 * M_PI * normalized * 2.0 + M_PI / 2);
                    double g_n = sin(2 * M_PI * normalized * 3.0 + M_PI / 3);
                    double b_n = sin(2 * M_PI * normalized * 4.0);

                    // Convert to the range [0, 255]
                    r = (int) ((r_n + 1) * 127.5);
                    g = (int) ((g_n + 1) * 127.5);
                    b = (int) ((b_n + 1) * 127.5);
                    SDL_SetRenderDrawColor(renderer, r, g, b, 255);
                }
                SDL_RenderDrawPoint(renderer, x_i, y_i);
            }
        }
        //render
        SDL_RenderPresent(renderer); 
    }
    // Clean up and quit SDL
    sdl_dtor();
    return 0;
}

int sdl_ctor() 
{
    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        return 1;
    }
    // Create a window
    // Get the screen's width and height
    SDL_DisplayMode DM;
    SDL_GetCurrentDisplayMode(0, &DM);
    int screenWidth = DM.w;
    int screenHeight = DM.h;
    // Calculate the center position for the window
    const int windowPosX = (screenWidth - SCREEN_WIDTH/2)/2;
    const int windowPosY = (screenHeight - SCREEN_HEIGHT/2)/2;
    window = SDL_CreateWindow(  "MANDELBROT", 
                                windowPosX, windowPosY,
                                SCREEN_WIDTH, SCREEN_HEIGHT, 
                                SDL_WINDOW_SHOWN);
    if (window == NULL) {
        return 1;
    }
    // Create a renderer for the window
    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    
    return 0;
}

int sdl_dtor() 
{
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}
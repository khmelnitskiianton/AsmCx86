#include <stdio.h>
#include <stdlib.h>
#include <SDL2/SDL.h>
#include "SDL_ttf.h"
#include <math.h>
#include <emmintrin.h>
#include <immintrin.h>
#include <x86intrin.h>

const size_t SIZE       = 8;
      int SCREEN_WIDTH  = 800;
      int SCREEN_HEIGHT = 600;     
const size_t N_MAX      = 100;    
const float dx          = 1/200.f; 
const float dy          = 1/200.f; 
const float dscale      = 1.2f;   
const float RADIUS      = 100;     
const float X_SHIFT     = -0.55f;  
const size_t SIZE_OF_BUFFER = 100;
const size_t WIDTH_TEXT     = 200; 
const size_t HEIGHT_TEXT    = 55;

const __m256 r2max      = _mm256_set1_ps (100.f);
const __m256 _76543210  = _mm256_set_ps  (7.f, 6.f, 5.f, 4.f, 3.f, 2.f, 1.f, 0.f);
const __m256 nmax       = _mm256_set1_ps (N_MAX);

const uint64_t clock_speed_spu = 2000000000;

int         sdl_ctor();
int         sdl_dtor();
uint64_t    rdtsc();
bool        DrawMandelbrot(float* x_center, float* y_center, float* scale, SDL_Color* colors);
void        CalcAllColors(SDL_Color* colors);
void        CleanBuffer(char* buff, size_t leng);

SDL_Window   *window = NULL;
SDL_Renderer *renderer = NULL;
SDL_Event    event;
SDL_Surface  *surfaceMessage = NULL;
SDL_Texture  *Message = NULL;
TTF_Font     *font = NULL; 

int main() {
    // Initialize SDL
    if (sdl_ctor() == 1) {
        return 1;
    }
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    // Wait for the user to close the window
    float x_center = X_SHIFT;
    float y_center = 0;
    float scale = 1;
    bool run = true;
    uint64_t t1 = 0;
    uint64_t t2 = 0;
    SDL_Color color_text = {255, 255, 255, 255};
    SDL_Color colors[N_MAX+1] = {};

    SDL_Rect Message_rect; //create a rect
    Message_rect.x = 0;  //controls the rect's x coordinate 
    Message_rect.y = 0; // controls the rect's y coordinte
    Message_rect.w = WIDTH_TEXT; // controls the width of the rect
    Message_rect.h = HEIGHT_TEXT; // controls the height of the rect
    char fps_buffer[SIZE_OF_BUFFER] = {};
    
    CalcAllColors(colors);

    while (run)
    {
        //Process Keys
        while(SDL_PollEvent(&event) != 0) {
            if (event.type == SDL_QUIT) {
                run = false;
                break;
            }
            if (event.type == SDL_KEYDOWN) {
                if (event.key.keysym.sym == SDLK_UP)     y_center += dy*scale;
                if (event.key.keysym.sym == SDLK_DOWN)   y_center -= dy*scale;
                if (event.key.keysym.sym == SDLK_RIGHT)  x_center -= dx*scale;
                if (event.key.keysym.sym == SDLK_LEFT)   x_center += dx*scale;
                if (event.key.keysym.sym == SDLK_EQUALS) scale /= dscale;
                if (event.key.keysym.sym == SDLK_MINUS)  scale *= dscale;
            }
            if (event.type == SDL_WINDOWEVENT && event.window.event == SDL_WINDOWEVENT_RESIZED) {
                SCREEN_WIDTH  = event.window.data1;
                SCREEN_HEIGHT = event.window.data2;
            }
        }
        //clear
        SDL_RenderClear(renderer);
        SDL_FreeSurface(surfaceMessage);
        CleanBuffer(fps_buffer, SIZE_OF_BUFFER);
        //body
        if (!DrawMandelbrot(&x_center, &y_center, &scale, colors))
        {
            run = false;
        }
        //render
        t2 = __rdtsc();
        float fps_float = (float)clock_speed_spu / (float)(t2 - t1);
        snprintf(fps_buffer, SIZE_OF_BUFFER,"FPS: %.2lf", fps_float);
        t1 = __rdtsc();
        surfaceMessage = TTF_RenderText_Solid(font, fps_buffer, color_text); 
        Message = SDL_CreateTextureFromSurface(renderer, surfaceMessage);
        SDL_RenderCopy(renderer, Message, NULL, &Message_rect);
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
                                SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);
    if (window == NULL) {
        return 1;
    }
    // Create a renderer for the window
    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    TTF_Init();
    font = TTF_OpenFont("/usr/share/fonts/truetype/firacode/FiraCode-Bold.ttf", 256);

    return 0;
}

int sdl_dtor() 
{
    SDL_RenderClear(renderer);
    SDL_FreeSurface(surfaceMessage);
    SDL_DestroyTexture(Message);
    TTF_CloseFont(font);
    TTF_Quit();
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}

void CalcAllColors(SDL_Color* colors)
{
    for (size_t i = 0; i < (N_MAX); i++)
    { 
        // Normalize the value to the range [0, 1]
        float normalized = -(float)i / (float)N_MAX;
        // Use sine waves to create a colorful gradient with smooth transitions
        float r_n = (float) sin(2 * M_PI * normalized * 4.0 + M_PI / 4);
        float g_n = (float) sin(2 * M_PI * normalized * 8.0 + M_PI / 8);
        float b_n = (float) sin(2 * M_PI * normalized * 16.0 + M_PI / 16);
        // Convert to the range [0, 255]
        colors[i].r = (Uint8) ((r_n + 1) * 127.5);
        colors[i].g = (Uint8) ((g_n + 1) * 127.5);
        colors[i].b = (Uint8) ((b_n + 1) * 127.5);
    }
}

bool DrawMandelbrot(float* x_center, float* y_center, float* scale, SDL_Color* colors)
{
    for (int y_i = 0; y_i < SCREEN_HEIGHT; y_i++)
    {
        //check for close
        if (event.type == SDL_QUIT) {
            return 0;
        }
        //set line with height = y0 and x - counting
        float x_0 = *x_center + (                    - (float)SCREEN_WIDTH *(*scale)/2)*dx; 
        float y_0 = *y_center + ((float)y_i*(*scale) - (float)SCREEN_HEIGHT*(*scale)/2)*dy;
        for (int x_i = 0; x_i < SCREEN_WIDTH; x_i += 8 , x_0 += 8*dx*(*scale))
        {
            //counting (x,y)
            __m256 x_0_arr = _mm256_add_ps (_mm256_set1_ps (x_0), _mm256_mul_ps (_76543210, _mm256_set1_ps (dx*(*scale))));
            __m256 y_0_arr =                                                   _mm256_set1_ps (y_0);
            __m256 x = x_0_arr;
            __m256 y = y_0_arr;
            __m256i n = _mm256_setzero_si256();
            __m256 cmp = _mm256_setzero_ps();
            for (size_t m = 0; m < N_MAX; m++)
            {
                __m256 x2 = _mm256_mul_ps (x, x);
                __m256 y2 = _mm256_mul_ps (y, y);
                __m256 xy = _mm256_mul_ps (x, y);
                __m256 r2 = _mm256_add_ps (x2,y2);
                cmp = _mm256_cmp_ps (r2, r2max, _CMP_LE_OS);
                int mask = 0; 
                mask = _mm256_movemask_ps (cmp);
                if (!mask) break;
                n = _mm256_sub_epi32 (n, _mm256_castps_si256(cmp)); 
                x = _mm256_add_ps (_mm256_sub_ps(x2,y2), x_0_arr);
                y = _mm256_add_ps (_mm256_add_ps(xy,xy), y_0_arr);
            }   
            for (size_t j = 0; j < SIZE; j++)
            {
                uint* n_ptr   = (uint*) &n;
                int* cmp_ptr = (int*) &cmp;
                SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
                if (!cmp_ptr[j])
                {
                    SDL_SetRenderDrawColor(renderer, colors[n_ptr[j]].r, colors[n_ptr[j]].g, colors[n_ptr[j]].b, 255);
                }
                SDL_RenderDrawPoint(renderer, x_i+(int)j, y_i);
            }
        }
    }
    return 1;
}

void CleanBuffer(char* buff, size_t leng)
{
    size_t pos = 0;
    while ((pos < leng) && (buff[pos] != '\0'))
    {
        buff[pos] = '\0';
    }
}
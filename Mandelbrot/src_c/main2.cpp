#include <stdio.h>
#include <stdlib.h>
#include <SDL2/SDL.h>
#include "SDL_ttf.h"
#include <math.h>
 
const size_t SIZE = 4;
const int SCREEN_WIDTH  = 1000;      //1920;
const int SCREEN_HEIGHT = 800;       //1080;
const size_t N_MAX      = 100;       //256;
const double dx         = 1/400.f;   //1/800.f;
const double dy         = 1/400.f;   //1/800.f; 
const double dscale     = 1/80.f;    //1/100.f;
const double RADIUS     = 150;       //100.f;
const double X_SHIFT    = -0.55;     //-0.55;
const size_t SIZE_OF_BUFFER = 100;
const size_t WIDTH_TEXT = 200;
const size_t HEIGHT_TEXT = 70;

const uint64_t clock_speed_spu = 3800000000;

int         sdl_ctor();
int         sdl_dtor();
uint64_t    rdtsc();
bool        DrawMandelbrot(double* x_center, double* y_center, double* scale);
void        CalcColor(SDL_Color* pixel_color, size_t n);
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
    double x_center = X_SHIFT;
    double y_center = 0;
    double scale = 1;
    bool run = true;
    uint64_t t1 = 0;
    uint64_t t2 = 0;
    SDL_Color color_text = {0,0,0,0};
    SDL_Rect Message_rect; //create a rect
    Message_rect.x = 0;  //controls the rect's x coordinate 
    Message_rect.y = 0; // controls the rect's y coordinte
    Message_rect.w = WIDTH_TEXT; // controls the width of the rect
    Message_rect.h = HEIGHT_TEXT; // controls the height of the rect
    char fps_buffer[SIZE_OF_BUFFER] = {};
    while (run)
    {
        t1 = rdtsc();
        //Process Keys
        while(SDL_PollEvent(&event) != 0) {
            if (event.type == SDL_QUIT) {
                run = false;
                break;
            }
            if (event.type == SDL_KEYDOWN) {
                if (event.key.keysym.sym == SDLK_UP)     y_center += dy;
                if (event.key.keysym.sym == SDLK_DOWN)   y_center -= dy;
                if (event.key.keysym.sym == SDLK_RIGHT)  x_center -= dx;
                if (event.key.keysym.sym == SDLK_LEFT)   x_center += dx;
                if (event.key.keysym.sym == SDLK_EQUALS) scale -= dscale;
                if (event.key.keysym.sym == SDLK_MINUS)  scale += dscale;
            }
        }
        //clear
        SDL_RenderClear(renderer);
        SDL_FreeSurface(surfaceMessage);
        CleanBuffer(fps_buffer, SIZE_OF_BUFFER);
        //body
        if (!DrawMandelbrot(&x_center, &y_center, &scale))
        {
            run = false;
        }
        //render
        t2 = rdtsc();
        snprintf(fps_buffer, SIZE_OF_BUFFER,"FPS: %lu", clock_speed_spu/(t2 - t1));
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
                                SDL_WINDOW_SHOWN);
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


uint64_t rdtsc()
{
   uint32_t hi, lo;
   __asm__ __volatile__ ("rdtsc" : "=a"(lo), "=d"(hi));
   return ( (uint64_t)lo)|( ((uint64_t)hi)<<32 );
}

void CalcColor(SDL_Color* pixel_color, size_t n)
{
    if (!pixel_color) return;
    // Normalize the value to the range [0, 1]
    double normalized = (double)n / (double)N_MAX;
    // Use sine waves to create a colorful gradient with smooth transitions
    double r_n = sin(2 * M_PI * normalized * 4.0 + M_PI / 4);
    double g_n = sin(2 * M_PI * normalized * 8.0 + M_PI / 8);
    double b_n = sin(2 * M_PI * normalized * 16.0 + M_PI / 16);
    // Convert to the range [0, 255]
    pixel_color->r = (Uint8) ((r_n + 1) * 127.5);
    pixel_color->g = (Uint8) ((g_n + 1) * 127.5);
    pixel_color->b = (Uint8) ((b_n + 1) * 127.5);
}

bool DrawMandelbrot(double* x_center, double* y_center, double* scale)
{
    double x_0 = 0;
    double y_0 = 0;
    double x[SIZE] = {};
    double y[SIZE] = {};
    double x2[SIZE] = {};
    double y2[SIZE] = {};
    double xy[SIZE] = {};
    double r2[SIZE] = {};
    double x_0_arr[SIZE] = {};
    int mask = 0;
    double r2max = RADIUS;
    bool color_flag[SIZE] = {};
    SDL_Color pixel_color = {};
    for (int y_i = 0; y_i < SCREEN_HEIGHT; y_i++)
    {
        //check for close
        if (event.type == SDL_QUIT) {
            return 0;
        }
        //set line with height = y0 and x - counting
        x_0 = *x_center + (                     - (double)SCREEN_WIDTH *(*scale)/2)*dx; 
        y_0 = *y_center + ((double)y_i*(*scale) - (double)SCREEN_HEIGHT*(*scale)/2)*dy;
        for (int x_i = 0; x_i < SCREEN_WIDTH; x_i += 4 , x_0 += 4*dx*(*scale))
        {
            //counting (x,y)
            for (size_t i = 0; i < SIZE; i++) color_flag[i] = 0;
            for (size_t i = 0; i < SIZE; i++) x_0_arr[i] = x_0 + dx*((double)i)*(*scale);
            for (size_t i = 0; i < SIZE; i++) x[i] = x_0_arr[i];
            for (size_t i = 0; i < SIZE; i++) y[i] = y_0;
            //check if (x,y) not run away from circle
            size_t n[SIZE] = {0,0,0,0};
            for (size_t m = 0; m < N_MAX; m++)
            {
                int cmp[SIZE] = {0,0,0,0};
                for (size_t k = 0; k < SIZE; k++)    x2[k] = x[k] * x[k];
                for (size_t k = 0; k < SIZE; k++)    y2[k] = y[k] * y[k];
                for (size_t k = 0; k < SIZE; k++)    xy[k] = x[k] * y[k];
                for (size_t k = 0; k < SIZE; k++)    r2[k] = (x2[k] + y2[k]);
                for (size_t k = 0; k < SIZE; k++) if (r2[k] <= r2max) cmp[k] = 1;
                for (size_t k = 0; k < SIZE; k++) if (r2[k] > r2max)  color_flag[k] = 1;
                mask = 0; 
                for (size_t k = 0; k < SIZE; k++) mask |= (cmp[k] << k);
                if (!mask) break;
                for (size_t k = 0; k < SIZE; k++) n[k] = n[k] + (size_t)cmp[k];
                for (size_t k = 0; k < SIZE; k++) x[k] = x2[k] - y2[k] + x_0_arr[k];
                for (size_t k = 0; k < SIZE; k++) y[k] = 2 * xy[k]     + y_0;
            }  
            for (size_t j = 0; j < SIZE; j++)
            {
                SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
                if (color_flag[j])
                {
                    CalcColor(&pixel_color, n[j]);
                    SDL_SetRenderDrawColor(renderer, pixel_color.r, pixel_color.g, pixel_color.b, 255);
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
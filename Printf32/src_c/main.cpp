#include <stdio.h>

//declare function extern(from another place) 
//with mangling name like in C

extern "C" void print_char(int a);      
extern "C" void print_string(const char* buffer);
extern "C" void Printf32(const char* buffer, ...);   //main function of printf

int main()
{
    print_string("Abba\n");
    Printf32("Hi: %c %s %c %s\n", 'a', "Hello", 'b', "World");
    return 0;
}

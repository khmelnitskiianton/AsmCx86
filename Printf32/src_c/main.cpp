#include <stdio.h>

//declare function extern(from another place) 
//with mangling name like in C

extern "C" int Printf32(const char* buffer, ...);   //main function of printf

int main()
{
    int a = Printf32("%o\n%d %s %x %d%%%c%b\n%d %s %x %d%%%c%b\n", -20, -1, "love", 3802, 100, 33, 127,
                                                                        -1, "love", 3802, 100, 33, 127);
    int b = 1;
    printf("\n%x\n", -20);
    Printf32("abba%n-best\n", &b);
    Printf32("%d\n", b);
    return 0;
}
#include <stdio.h>

//declare function extern(from another place) 
//with mangling name like in C

extern "C" void Printf32(const char* buffer, ...);   //main function of printf

int main()
{
    Printf32("%d\n%d %s %d %d%%%c%d\n%d %s %d %d%%%c\b\n", -1, -1, "love", 3802, 100, 33, 127,
                                                                         -1, "love", 3802, 100, 33, 127);
    int a = 0;
    Printf32("%c %p %u %d %s %n\n", 'a', &a, 123, -456, "HELLO");
    return 0;
}
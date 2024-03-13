#include <stdio.h>

extern "C" void HelloWorld();   //declare function extern(from another place) 
                                //with mangling name like in C

int main()
{
    HelloWorld();               //Call it
    return 0;
}

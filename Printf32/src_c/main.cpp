#include <stdio.h>

extern "C" void print_char(int a);      //declare function extern(from another place) 
                                        //with mangling name like in C
extern "C" void Printf32(const char* buffer);   //main function of printf

int main()
{
    print_char('a');
    print_char('\n');
    Printf32("Hello %% %a bye bye\n");
    return 0;
}

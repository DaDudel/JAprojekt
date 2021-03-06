#include <iostream>
#include <wtypes.h>


typedef unsigned char byte;
typedef void (*CONVERT_TO_RPN)(byte[], int, int, byte[]);
int main()
{
    //testowe obrazy do debugowania asemblera
    byte a[75] = { 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
                   255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
                   255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
                   255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
                   255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 };
    byte b[75];
    byte c[75] = { 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
                   255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255,
                   255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255,
                   255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255,
                   255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 };
    std::cout << "a address:" << &a;
    std::cout << "b address:" << &b;
    CONVERT_TO_RPN convertToRpnProc;
    HINSTANCE hDll = NULL;
    hDll = LoadLibrary(TEXT("dllASM"));
    convertToRpnProc = (CONVERT_TO_RPN)GetProcAddress(hDll, "filtr");
    (convertToRpnProc)(c, 5, 5, b);
    for (int i = 0; i < 75; i++) {
        std::cout << "a[" << i << "] = " << a[i] * 1 << " ";
        std::cout << "b[" << i << "] = " << b[i] * 1 << std::endl;
    }
}
   
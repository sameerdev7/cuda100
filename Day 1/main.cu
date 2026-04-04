#include <iostream>
#include <cuda_runtime.h> 

int main()
{
    int vectorLength = 1024; 
    int threads = 256; 
    int blocks = (vectorLength + threads-1) / threads;

    std::cout << blocks << std::endl;
    return 0;
}
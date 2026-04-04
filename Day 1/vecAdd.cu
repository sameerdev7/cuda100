#include <stdio.h>
#include <iostream>
#include <cmath>
#include <cuda_runtime.h>

__global__ void vecAdd(double *A, double *B, double *C, int vectorLength)
{
    int idx = blockDim.x * blockIdx.x + threadIdx.x; 

    if (idx < vectorLength)
    {
        C[idx] = A[idx] + B[idx];
    }
}

int main() 
{
    int vectorLength = 1024; 

    // Number of bytes to allocate
    size_t bytes = vectorLength * sizeof(double);

    // Allocate memory for arrays on CPU
    double *A = (double*)malloc(bytes);
    double *B = (double*)malloc(bytes);
    double *C = (double*)malloc(bytes);

    // Allocate memory for arrays on GPU
    double *d_A, *d_B, *d_C; 
    cudaMalloc(&d_A, bytes);
    cudaMalloc(&d_B, bytes);
    cudaMalloc(&d_C, bytes);


    // Fill the host arrays 
    for (int i = 0; i < vectorLength; i++)
    {
        A[i] = 1.0; 
        B[i] = 2.0; 
    }
 

    // Copy the data from host to device
    cudaMemcpy(d_A, A, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, B, bytes, cudaMemcpyHostToDevice);

    int threads = 256;  // number of threads per block 
    int blocks = (vectorLength + threads - 1) / threads; // number of blocks per grid
 
    // Launch the kernel
    vecAdd<<<blocks, threads>>>(d_A, d_B, d_C, vectorLength);

    cudaDeviceSynchronize();

    // copy the result from device to host
    cudaMemcpy(C, d_C, bytes, cudaMemcpyDeviceToHost);

    double tolerance = 1.0e-14; 

    for (int i = 0; i < vectorLength; i++)
    {
        if (fabs(C[i] - 3.0) > tolerance)
        {
            std::cout << "Error: C[" << i << "] = " << C[i] << "\n";
            return -1;
        }
    }

    std::cout << "Success!\n";

    // free the cpu memory 
    free(A);
    free(B);
    free(C);

    // free the gpu memory
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    return 0;
}
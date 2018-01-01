#include <iostream>
#include <vector>
//#include <cuda.h>
#include <stdio.h>

using namespace std;

///////////////////////////////////////////////////////////////////////////////
	
void print(std::vector<float> &vec) 
{
  for (size_t i = 0; i < vec.size(); ++i) {
     cerr << vec[i] << " ";
  }
  cerr << endl;
}

///////////////////////////////////////////////////////////////////////////////
__global__
void kernelHelloWorld()
{
  printf("Hello world\n");
}
///////////////////////////////////////////////////////////////////////////////
__global__
void kernelSquare(float *vec)
{
  for (size_t i = 0; i < 10; ++i) {
    vec[i] = vec[i] * vec[i];
  }
}
///////////////////////////////////////////////////////////////////////////////
__global__
void kernelParallelSquare(float *vec, int size)
{
  int i = threadIdx.x + blockDim.x * blockIdx.x;
  if (i < size) {
    printf("gridDim.x=%i  blockDim.x=%i blockIdx.x=%i threadIdx.x=%i i=%i \n", gridDim.x, blockDim.x, blockIdx.x, threadIdx.x, i);
    vec[i] = vec[i] * vec[i];
  }
}

///////////////////////////////////////////////////////////////////////////////
__global__
void kernelReduce(float *vec, int size)
{
  for (int i = 1; i < size; ++i) {
    vec[0] += vec[i];
  }
}

///////////////////////////////////////////////////////////////////////////////
__global__
void kernelReduceAtomic(float *vec, int size)
{
  int i = threadIdx.x + blockDim.x * blockIdx.x;
  if (i < size) {
    atomicAdd(&vec[0], vec[i]);
  }  
}

///////////////////////////////////////////////////////////////////////////////
__global__
void kernelReduceParallel(float *vec, int size, int half)
{
  int i = threadIdx.x + blockDim.x * blockIdx.x;
  if (i < half) {
    vec[i] += vec[i+half];
    if ((i == half - 1) && (i + half + 2 == size)) {
       vec[i] += vec[i+half+1];
    }
  }
}

///////////////////////////////////////////////////////////////////////////////
__global__
void kernelReduceParallel2(float *vec, int size)
{
  int half = size / 2;
  int i = threadIdx.x + blockDim.x * blockIdx.x;

  while (half > 0) {
    if (i < half) {
      vec[i] += vec[i+half];
      if ((i == half - 1) && (i + half + 2 == size)) {
        vec[i] += vec[i+half+1];
      }
    }

    size = half;
    half = size / 2;
  }
}

///////////////////////////////////////////////////////////////////////////////

int main()
{
  cerr << "Starting" << endl;

  int NUM = 10;
  vector<float> h_vec(NUM);
  for (size_t i = 0; i < NUM; ++i) {
     h_vec[i] = i;
  }
  print(h_vec); cerr << endl;

  float *d_array;
  cudaMalloc(&d_array, sizeof(float) * NUM);
  cudaMemcpy(d_array, h_vec.data(), sizeof(float) * NUM, cudaMemcpyHostToDevice);

  //kernel1<<<1, 1000>>>();
  //kernel2<<<1, 1>>>(d_array);
  //kernel3<<<3, 4>>>(d_array, NUM);
  //kernel4<<<1, 1>>>(d_array, NUM);
  //kernel5<<<1, 10>>>(d_array, NUM);

  //kernelReduceParallel<<<1, 5>>>(d_array, 10, 5);
  //kernelReduceParallel<<<1, 2>>>(d_array, 5, 2);
  //kernelReduceParallel<<<1, 1>>>(d_array, 2, 1);
  /*
  int size = 10;
  int half = size / 2;
  while (half > 0) {
    kernelReduceParallel<<<1, half>>>(d_array, size, half);

    size = half;
    half = size / 2;
  }
  */
  kernelReduceParallel2<<<1, 5>>>(d_array, 10);

  if ( cudaSuccess != cudaGetLastError()) {
    cerr << "kernel didn't run" << endl;
    abort();
  }
  
  int ret = cudaDeviceSynchronize();
  if (ret) {
    cerr << "kernel ran but produced an error" << endl;
    abort();
  }

  cudaMemcpy(h_vec.data(), d_array, sizeof(float) * NUM, cudaMemcpyDeviceToHost);

  print(h_vec); cerr << endl;

  cerr << "Finished" << endl;
}

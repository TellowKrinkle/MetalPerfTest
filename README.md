# MetalPerfTest

Metal version of https://github.com/sebbbi/perftest

Notable differences:
- This uses the median of the runs (rather than the sum).  Because of this, it doesn't run warmups, as they're not needed.  ms values will also be much lower because of this.
- This uses `texture_buffer<R32> random` as the baseline instead of `RGBA8`.  This is mostly because Apple GPUs have a ~10% penalty for loading 4 floats at once, so by using one of the smaller formats, all the numbers look much nicer.
- Metal really wants you to use `half` for shader operations, so this tests halves in addition to floats.  To differentiate, texture type names use a trailing `H`, so `R8` is R8Unorm loaded as float and `R32` is R32Float loaded as float, while R8H is R8Unorm loaded as half and `R32H` is R32Float loaded as half.
- An additional `random+` mode, which is like `random` but spreads out its start points across 64 different values, rather than just 16.  This was added because Apple GPUs seem to load faster if multiple threads in a simdgroup load the same value.

## Running

`make run` on macOS 10.15+

You can also `make` and then `./MetalPerfTest id` where `id` is the index of the GPU you want to run the test on

If you want to run from Xcode, make a new command line project, drag the two sources onto it, and you should be good to go.

## Results

<details>
<summary>Apple M1</summary>

```
  0.03ms  94.74x cbuffer{float4} uniform
  6.42ms   0.51x cbuffer{float4} linear
  5.24ms   0.63x cbuffer{float4} random
  9.33ms   0.35x cbuffer{float4} random+
  1.39ms   2.38x device const rg8unorm<float2>* uniform
  1.77ms   1.87x device const rg8unorm<float2>* linear
  1.52ms   2.18x device const rg8unorm<float2>* random
  1.87ms   1.77x device const rg8unorm<float2>* random+
  1.88ms   1.75x device const rgba8unorm<float4>* uniform
  2.11ms   1.56x device const rgba8unorm<float4>* linear
  2.10ms   1.57x device const rgba8unorm<float4>* random
  4.40ms   0.75x device const rgba8unorm<float4>* random+
  1.15ms   2.86x device const rg8unorm<half2>* uniform
  1.32ms   2.51x device const rg8unorm<half2>* linear
  1.31ms   2.52x device const rg8unorm<half2>* random
  1.31ms   2.53x device const rg8unorm<half2>* random+
  1.27ms   2.60x device const rgba8unorm<half4>* uniform
  1.51ms   2.19x device const rgba8unorm<half4>* linear
  1.43ms   2.31x device const rgba8unorm<half4>* random
  1.55ms   2.13x device const rgba8unorm<half4>* random+
  1.16ms   2.85x device const half2* uniform
  1.35ms   2.44x device const half2* linear
  1.33ms   2.49x device const half2* random
  1.54ms   2.14x device const half2* random+
  1.32ms   2.51x device const half4* uniform
  2.57ms   1.29x device const half4* linear
  1.86ms   1.77x device const half4* random
  4.00ms   0.83x device const half4* random+
  1.24ms   2.66x device const float1* uniform
  1.41ms   2.34x device const float1* linear
  1.39ms   2.37x device const float1* random
  1.54ms   2.14x device const float1* random+
  1.43ms   2.32x device const float2* uniform
  2.57ms   1.29x device const float2* linear
  1.87ms   1.76x device const float2* random
  4.00ms   0.83x device const float2* random+
  2.25ms   1.47x device const float4* uniform
  6.43ms   0.51x device const float4* linear
  5.25ms   0.63x device const float4* random
  9.53ms   0.35x device const float4* random+
  1.39ms   2.38x device const packed_float2* uniform
  2.57ms   1.29x device const packed_float2* linear
  1.88ms   1.76x device const packed_float2* random
  4.00ms   0.83x device const packed_float2* random+
  2.55ms   1.29x device const packed_float3* uniform
  6.58ms   0.50x device const packed_float3* linear
  5.01ms   0.66x device const packed_float3* random
  7.11ms   0.46x device const packed_float3* random+
  2.25ms   1.47x device const packed_float4* uniform
  6.43ms   0.51x device const packed_float4* linear
  5.25ms   0.63x device const packed_float4* random
  9.53ms   0.35x device const packed_float4* random+
  1.39ms   2.38x device const unaligned packed_float2* uniform
  2.97ms   1.11x device const unaligned packed_float2* linear
  2.50ms   1.32x device const unaligned packed_float2* random
  3.85ms   0.86x device const unaligned packed_float2* random+
  2.25ms   1.47x device const unaligned packed_float4* uniform
  8.93ms   0.37x device const unaligned packed_float4* linear
  7.38ms   0.45x device const unaligned packed_float4* random
 11.79ms   0.28x device const unaligned packed_float4* random+
  0.02ms 144.96x constant float1* uniform
  1.41ms   2.35x constant float1* linear
  1.39ms   2.37x constant float1* random
  1.54ms   2.14x constant float1* random+
  0.02ms 132.71x constant float2* uniform
  2.57ms   1.29x constant float2* linear
  1.87ms   1.76x constant float2* random
  4.00ms   0.83x constant float2* random+
  0.03ms  97.71x constant float4* uniform
  6.42ms   0.51x constant float4* linear
  5.25ms   0.63x constant float4* random
  9.53ms   0.35x constant float4* random+
  0.03ms 126.47x constant packed_float2* uniform
  2.57ms   1.29x constant packed_float2* linear
  1.88ms   1.76x constant packed_float2* random
  4.00ms   0.83x constant packed_float2* random+
  0.03ms 116.52x constant packed_float3* uniform
  6.58ms   0.50x constant packed_float3* linear
  5.02ms   0.66x constant packed_float3* random
  7.11ms   0.46x constant packed_float3* random+
  0.03ms  95.13x constant packed_float4* uniform
  6.43ms   0.51x constant packed_float4* linear
  5.25ms   0.63x constant packed_float4* random
  9.53ms   0.35x constant packed_float4* random+
  3.30ms   1.00x texture_buffer<R8> uniform
  3.30ms   1.00x texture_buffer<R8> linear
  3.30ms   1.00x texture_buffer<R8> random
  3.31ms   1.00x texture_buffer<R8> random+
  3.31ms   1.00x texture_buffer<RG8> uniform
  3.32ms   1.00x texture_buffer<RG8> linear
  3.31ms   1.00x texture_buffer<RG8> random
  4.21ms   0.78x texture_buffer<RG8> random+
  3.69ms   0.89x texture_buffer<RGBA8> uniform
  3.62ms   0.91x texture_buffer<RGBA8> linear
  3.63ms   0.91x texture_buffer<RGBA8> random
  3.71ms   0.89x texture_buffer<RGBA8> random+
  3.30ms   1.00x texture_buffer<R16> uniform
  3.30ms   1.00x texture_buffer<R16> linear
  3.30ms   1.00x texture_buffer<R16> random
  4.23ms   0.78x texture_buffer<R16> random+
  3.32ms   1.00x texture_buffer<RG16> uniform
  3.31ms   1.00x texture_buffer<RG16> linear
  3.31ms   1.00x texture_buffer<RG16> random
  3.46ms   0.95x texture_buffer<RG16> random+
  3.69ms   0.89x texture_buffer<RGBA16> uniform
  3.63ms   0.91x texture_buffer<RGBA16> linear
  3.71ms   0.89x texture_buffer<RGBA16> random
  4.25ms   0.78x texture_buffer<RGBA16> random+
  3.30ms   1.00x texture_buffer<R32> uniform
  3.30ms   1.00x texture_buffer<R32> linear
  3.30ms   1.00x texture_buffer<R32> random
  3.46ms   0.95x texture_buffer<R32> random+
  3.32ms   1.00x texture_buffer<RG32> uniform
  3.36ms   0.98x texture_buffer<RG32> linear
  3.58ms   0.92x texture_buffer<RG32> random
  4.11ms   0.80x texture_buffer<RG32> random+
  6.57ms   0.50x texture_buffer<RGBA32> uniform
  6.57ms   0.50x texture_buffer<RGBA32> linear
  6.57ms   0.50x texture_buffer<RGBA32> random
  6.57ms   0.50x texture_buffer<RGBA32> random+
  3.30ms   1.00x texture2d<R8> uniform
  3.30ms   1.00x texture2d<R8> linear
  3.30ms   1.00x texture2d<R8> random
  3.30ms   1.00x texture2d<R8> random+
  3.32ms   0.99x texture2d<RG8> uniform
  3.31ms   1.00x texture2d<RG8> linear
  3.32ms   0.99x texture2d<RG8> random
  3.31ms   1.00x texture2d<RG8> random+
  3.67ms   0.90x texture2d<RGBA8> uniform
  3.70ms   0.89x texture2d<RGBA8> linear
  3.72ms   0.89x texture2d<RGBA8> random
  3.76ms   0.88x texture2d<RGBA8> random+
  3.30ms   1.00x texture2d<R16> uniform
  3.30ms   1.00x texture2d<R16> linear
  3.30ms   1.00x texture2d<R16> random
  3.30ms   1.00x texture2d<R16> random+
  3.32ms   1.00x texture2d<RG16> uniform
  3.31ms   1.00x texture2d<RG16> linear
  3.32ms   0.99x texture2d<RG16> random
  3.32ms   0.99x texture2d<RG16> random+
  3.67ms   0.90x texture2d<RGBA16> uniform
  3.71ms   0.89x texture2d<RGBA16> linear
  3.72ms   0.89x texture2d<RGBA16> random
  3.79ms   0.87x texture2d<RGBA16> random+
  3.30ms   1.00x texture2d<R32> uniform
  3.30ms   1.00x texture2d<R32> linear
  3.30ms   1.00x texture2d<R32> random
  3.33ms   0.99x texture2d<R32> random+
  3.32ms   1.00x texture2d<RG32> uniform
  3.32ms   1.00x texture2d<RG32> linear
  3.32ms   0.99x texture2d<RG32> random
  3.53ms   0.93x texture2d<RG32> random+
  6.57ms   0.50x texture2d<RGBA32> uniform
  6.57ms   0.50x texture2d<RGBA32> linear
  6.57ms   0.50x texture2d<RGBA32> random
  6.57ms   0.50x texture2d<RGBA32> random+
  3.30ms   1.00x texture2d<R8>.sample(nearest) uniform
  3.30ms   1.00x texture2d<R8>.sample(nearest) linear
  3.30ms   1.00x texture2d<R8>.sample(nearest) random
  3.30ms   1.00x texture2d<R8>.sample(nearest) random+
  3.32ms   1.00x texture2d<RG8>.sample(nearest) uniform
  3.32ms   1.00x texture2d<RG8>.sample(nearest) linear
  3.32ms   0.99x texture2d<RG8>.sample(nearest) random
  3.32ms   1.00x texture2d<RG8>.sample(nearest) random+
  3.71ms   0.89x texture2d<RGBA8>.sample(nearest) uniform
  3.68ms   0.90x texture2d<RGBA8>.sample(nearest) linear
  3.68ms   0.90x texture2d<RGBA8>.sample(nearest) random
  3.72ms   0.89x texture2d<RGBA8>.sample(nearest) random+
  3.30ms   1.00x texture2d<R16>.sample(nearest) uniform
  3.30ms   1.00x texture2d<R16>.sample(nearest) linear
  3.30ms   1.00x texture2d<R16>.sample(nearest) random
  3.30ms   1.00x texture2d<R16>.sample(nearest) random+
  3.31ms   1.00x texture2d<RG16>.sample(nearest) uniform
  3.31ms   1.00x texture2d<RG16>.sample(nearest) linear
  3.32ms   1.00x texture2d<RG16>.sample(nearest) random
  3.36ms   0.98x texture2d<RG16>.sample(nearest) random+
  3.71ms   0.89x texture2d<RGBA16>.sample(nearest) uniform
  3.69ms   0.90x texture2d<RGBA16>.sample(nearest) linear
  3.68ms   0.90x texture2d<RGBA16>.sample(nearest) random
  3.73ms   0.89x texture2d<RGBA16>.sample(nearest) random+
  3.30ms   1.00x texture2d<R32>.sample(nearest) uniform
  3.30ms   1.00x texture2d<R32>.sample(nearest) linear
  3.30ms   1.00x texture2d<R32>.sample(nearest) random
  3.35ms   0.99x texture2d<R32>.sample(nearest) random+
  3.31ms   1.00x texture2d<RG32>.sample(nearest) uniform
  3.32ms   1.00x texture2d<RG32>.sample(nearest) linear
  3.32ms   1.00x texture2d<RG32>.sample(nearest) random
  3.40ms   0.97x texture2d<RG32>.sample(nearest) random+
  6.57ms   0.50x texture2d<RGBA32>.sample(nearest) uniform
  6.57ms   0.50x texture2d<RGBA32>.sample(nearest) linear
  6.57ms   0.50x texture2d<RGBA32>.sample(nearest) random
  6.57ms   0.50x texture2d<RGBA32>.sample(nearest) random+
  3.30ms   1.00x texture2d<R8>.sample(bilinear) uniform
  3.30ms   1.00x texture2d<R8>.sample(bilinear) linear
  3.30ms   1.00x texture2d<R8>.sample(bilinear) random
  3.30ms   1.00x texture2d<R8>.sample(bilinear) random+
  3.32ms   1.00x texture2d<RG8>.sample(bilinear) uniform
  3.32ms   1.00x texture2d<RG8>.sample(bilinear) linear
  3.32ms   0.99x texture2d<RG8>.sample(bilinear) random
  3.32ms   1.00x texture2d<RG8>.sample(bilinear) random+
  3.71ms   0.89x texture2d<RGBA8>.sample(bilinear) uniform
  3.68ms   0.90x texture2d<RGBA8>.sample(bilinear) linear
  3.68ms   0.90x texture2d<RGBA8>.sample(bilinear) random
  3.72ms   0.89x texture2d<RGBA8>.sample(bilinear) random+
  3.30ms   1.00x texture2d<R16>.sample(bilinear) uniform
  3.30ms   1.00x texture2d<R16>.sample(bilinear) linear
  3.30ms   1.00x texture2d<R16>.sample(bilinear) random
  3.30ms   1.00x texture2d<R16>.sample(bilinear) random+
  3.31ms   1.00x texture2d<RG16>.sample(bilinear) uniform
  3.31ms   1.00x texture2d<RG16>.sample(bilinear) linear
  3.32ms   1.00x texture2d<RG16>.sample(bilinear) random
  3.36ms   0.98x texture2d<RG16>.sample(bilinear) random+
  3.71ms   0.89x texture2d<RGBA16>.sample(bilinear) uniform
  3.69ms   0.90x texture2d<RGBA16>.sample(bilinear) linear
  3.68ms   0.90x texture2d<RGBA16>.sample(bilinear) random
  3.73ms   0.89x texture2d<RGBA16>.sample(bilinear) random+
  3.30ms   1.00x texture2d<R32>.sample(bilinear) uniform
  3.30ms   1.00x texture2d<R32>.sample(bilinear) linear
  3.30ms   1.00x texture2d<R32>.sample(bilinear) random
  3.35ms   0.99x texture2d<R32>.sample(bilinear) random+
  6.57ms   0.50x texture2d<RG32>.sample(bilinear) uniform
  6.57ms   0.50x texture2d<RG32>.sample(bilinear) linear
  6.59ms   0.50x texture2d<RG32>.sample(bilinear) random
  6.61ms   0.50x texture2d<RG32>.sample(bilinear) random+
 13.13ms   0.25x texture2d<RGBA32>.sample(bilinear) uniform
 13.13ms   0.25x texture2d<RGBA32>.sample(bilinear) linear
 13.13ms   0.25x texture2d<RGBA32>.sample(bilinear) random
 13.13ms   0.25x texture2d<RGBA32>.sample(bilinear) random+
  3.30ms   1.00x texture_buffer<R8H> uniform
  3.30ms   1.00x texture_buffer<R8H> linear
  3.30ms   1.00x texture_buffer<R8H> random
  3.31ms   1.00x texture_buffer<R8H> random+
  3.30ms   1.00x texture_buffer<RG8H> uniform
  3.30ms   1.00x texture_buffer<RG8H> linear
  3.30ms   1.00x texture_buffer<RG8H> random
  4.23ms   0.78x texture_buffer<RG8H> random+
  3.30ms   1.00x texture_buffer<RGBA8H> uniform
  3.31ms   1.00x texture_buffer<RGBA8H> linear
  3.30ms   1.00x texture_buffer<RGBA8H> random
  3.46ms   0.95x texture_buffer<RGBA8H> random+
  3.30ms   1.00x texture_buffer<R16H> uniform
  3.30ms   1.00x texture_buffer<R16H> linear
  3.30ms   1.00x texture_buffer<R16H> random
  4.23ms   0.78x texture_buffer<R16H> random+
  3.30ms   1.00x texture_buffer<RG16H> uniform
  3.30ms   1.00x texture_buffer<RG16H> linear
  3.30ms   1.00x texture_buffer<RG16H> random
  3.47ms   0.95x texture_buffer<RG16H> random+
  3.30ms   1.00x texture_buffer<RGBA16H> uniform
  3.34ms   0.99x texture_buffer<RGBA16H> linear
  3.58ms   0.92x texture_buffer<RGBA16H> random
  4.11ms   0.80x texture_buffer<RGBA16H> random+
  3.30ms   1.00x texture_buffer<R32H> uniform
  3.30ms   1.00x texture_buffer<R32H> linear
  3.30ms   1.00x texture_buffer<R32H> random
  3.47ms   0.95x texture_buffer<R32H> random+
  3.30ms   1.00x texture_buffer<RG32H> uniform
  3.36ms   0.98x texture_buffer<RG32H> linear
  3.58ms   0.92x texture_buffer<RG32H> random
  4.22ms   0.78x texture_buffer<RG32H> random+
  6.57ms   0.50x texture_buffer<RGBA32H> uniform
  6.57ms   0.50x texture_buffer<RGBA32H> linear
  6.57ms   0.50x texture_buffer<RGBA32H> random
  6.57ms   0.50x texture_buffer<RGBA32H> random+
  3.30ms   1.00x texture2d<R8H> uniform
  3.30ms   1.00x texture2d<R8H> linear
  3.30ms   1.00x texture2d<R8H> random
  3.30ms   1.00x texture2d<R8H> random+
  3.30ms   1.00x texture2d<RG8H> uniform
  3.30ms   1.00x texture2d<RG8H> linear
  3.30ms   1.00x texture2d<RG8H> random
  3.30ms   1.00x texture2d<RG8H> random+
  3.31ms   1.00x texture2d<RGBA8H> uniform
  3.30ms   1.00x texture2d<RGBA8H> linear
  3.31ms   1.00x texture2d<RGBA8H> random
  3.33ms   0.99x texture2d<RGBA8H> random+
  3.30ms   1.00x texture2d<R16H> uniform
  3.30ms   1.00x texture2d<R16H> linear
  3.30ms   1.00x texture2d<R16H> random
  3.30ms   1.00x texture2d<R16H> random+
  3.30ms   1.00x texture2d<RG16H> uniform
  3.30ms   1.00x texture2d<RG16H> linear
  3.30ms   1.00x texture2d<RG16H> random
  3.33ms   0.99x texture2d<RG16H> random+
  3.31ms   1.00x texture2d<RGBA16H> uniform
  3.30ms   1.00x texture2d<RGBA16H> linear
  3.31ms   1.00x texture2d<RGBA16H> random
  3.53ms   0.93x texture2d<RGBA16H> random+
  3.30ms   1.00x texture2d<R32H> uniform
  3.30ms   1.00x texture2d<R32H> linear
  3.30ms   1.00x texture2d<R32H> random
  3.33ms   0.99x texture2d<R32H> random+
  3.30ms   1.00x texture2d<RG32H> uniform
  3.30ms   1.00x texture2d<RG32H> linear
  3.30ms   1.00x texture2d<RG32H> random
  3.48ms   0.95x texture2d<RG32H> random+
  6.57ms   0.50x texture2d<RGBA32H> uniform
  6.57ms   0.50x texture2d<RGBA32H> linear
  6.57ms   0.50x texture2d<RGBA32H> random
  6.57ms   0.50x texture2d<RGBA32H> random+
  3.30ms   1.00x texture2d<R8H>.sample(nearest) uniform
  3.30ms   1.00x texture2d<R8H>.sample(nearest) linear
  3.30ms   1.00x texture2d<R8H>.sample(nearest) random
  3.30ms   1.00x texture2d<R8H>.sample(nearest) random+
  3.30ms   1.00x texture2d<RG8H>.sample(nearest) uniform
  3.30ms   1.00x texture2d<RG8H>.sample(nearest) linear
  3.30ms   1.00x texture2d<RG8H>.sample(nearest) random
  3.30ms   1.00x texture2d<RG8H>.sample(nearest) random+
  3.30ms   1.00x texture2d<RGBA8H>.sample(nearest) uniform
  3.30ms   1.00x texture2d<RGBA8H>.sample(nearest) linear
  3.31ms   1.00x texture2d<RGBA8H>.sample(nearest) random
  3.36ms   0.98x texture2d<RGBA8H>.sample(nearest) random+
  3.30ms   1.00x texture2d<R16H>.sample(nearest) uniform
  3.30ms   1.00x texture2d<R16H>.sample(nearest) linear
  3.30ms   1.00x texture2d<R16H>.sample(nearest) random
  3.30ms   1.00x texture2d<R16H>.sample(nearest) random+
  3.30ms   1.00x texture2d<RG16H>.sample(nearest) uniform
  3.30ms   1.00x texture2d<RG16H>.sample(nearest) linear
  3.30ms   1.00x texture2d<RG16H>.sample(nearest) random
  3.35ms   0.99x texture2d<RG16H>.sample(nearest) random+
  3.30ms   1.00x texture2d<RGBA16H>.sample(nearest) uniform
  3.31ms   1.00x texture2d<RGBA16H>.sample(nearest) linear
  3.31ms   1.00x texture2d<RGBA16H>.sample(nearest) random
  3.40ms   0.97x texture2d<RGBA16H>.sample(nearest) random+
  3.30ms   1.00x texture2d<R32H>.sample(nearest) uniform
  3.30ms   1.00x texture2d<R32H>.sample(nearest) linear
  3.30ms   1.00x texture2d<R32H>.sample(nearest) random
  3.35ms   0.99x texture2d<R32H>.sample(nearest) random+
  3.30ms   1.00x texture2d<RG32H>.sample(nearest) uniform
  3.30ms   1.00x texture2d<RG32H>.sample(nearest) linear
  3.30ms   1.00x texture2d<RG32H>.sample(nearest) random
  3.42ms   0.96x texture2d<RG32H>.sample(nearest) random+
  6.57ms   0.50x texture2d<RGBA32H>.sample(nearest) uniform
  6.57ms   0.50x texture2d<RGBA32H>.sample(nearest) linear
  6.57ms   0.50x texture2d<RGBA32H>.sample(nearest) random
  6.57ms   0.50x texture2d<RGBA32H>.sample(nearest) random+
  3.30ms   1.00x texture2d<R8H>.sample(bilinear) uniform
  3.30ms   1.00x texture2d<R8H>.sample(bilinear) linear
  3.30ms   1.00x texture2d<R8H>.sample(bilinear) random
  3.30ms   1.00x texture2d<R8H>.sample(bilinear) random+
  3.30ms   1.00x texture2d<RG8H>.sample(bilinear) uniform
  3.30ms   1.00x texture2d<RG8H>.sample(bilinear) linear
  3.30ms   1.00x texture2d<RG8H>.sample(bilinear) random
  3.30ms   1.00x texture2d<RG8H>.sample(bilinear) random+
  3.31ms   1.00x texture2d<RGBA8H>.sample(bilinear) uniform
  3.30ms   1.00x texture2d<RGBA8H>.sample(bilinear) linear
  3.31ms   1.00x texture2d<RGBA8H>.sample(bilinear) random
  3.36ms   0.98x texture2d<RGBA8H>.sample(bilinear) random+
  3.30ms   1.00x texture2d<R16H>.sample(bilinear) uniform
  3.30ms   1.00x texture2d<R16H>.sample(bilinear) linear
  3.30ms   1.00x texture2d<R16H>.sample(bilinear) random
  3.30ms   1.00x texture2d<R16H>.sample(bilinear) random+
  3.30ms   1.00x texture2d<RG16H>.sample(bilinear) uniform
  3.30ms   1.00x texture2d<RG16H>.sample(bilinear) linear
  3.30ms   1.00x texture2d<RG16H>.sample(bilinear) random
  3.35ms   0.99x texture2d<RG16H>.sample(bilinear) random+
  3.31ms   1.00x texture2d<RGBA16H>.sample(bilinear) uniform
  3.31ms   1.00x texture2d<RGBA16H>.sample(bilinear) linear
  3.31ms   1.00x texture2d<RGBA16H>.sample(bilinear) random
  3.40ms   0.97x texture2d<RGBA16H>.sample(bilinear) random+
  3.30ms   1.00x texture2d<R32H>.sample(bilinear) uniform
  3.30ms   1.00x texture2d<R32H>.sample(bilinear) linear
  3.30ms   1.00x texture2d<R32H>.sample(bilinear) random
  3.35ms   0.99x texture2d<R32H>.sample(bilinear) random+
  6.57ms   0.50x texture2d<RG32H>.sample(bilinear) uniform
  6.57ms   0.50x texture2d<RG32H>.sample(bilinear) linear
  6.58ms   0.50x texture2d<RG32H>.sample(bilinear) random
  6.62ms   0.50x texture2d<RG32H>.sample(bilinear) random+
 13.13ms   0.25x texture2d<RGBA32H>.sample(bilinear) uniform
 13.13ms   0.25x texture2d<RGBA32H>.sample(bilinear) linear
 13.13ms   0.25x texture2d<RGBA32H>.sample(bilinear) random
 13.13ms   0.25x texture2d<RGBA32H>.sample(bilinear) random+
```

**Constant Buffers**: Apple GPUs are able to run a prolog shader before the main shader, which can store uniforms for the main shader to access.  Since this shader can run arbitrary shader code, it can precalculate the entire constant value in the uniform shaders, leaving just a single uniform load in the actual shader.  It appears the compiler is more aggressive at hoisting these operations when the source is a `constant` buffer, and our complicated loop is only hoisted in that case, resulting in the >100x speedups for the uniform constant loads.  Outside of the uniform case, constant buffers perform identically to device buffers.

**Buffer Loads**: On larger values (especially the `float4`s), Apple GPUs seem to load faster the more repeated values there are to load in each simdgroup.  You can see the 0-15 random loading faster than the linear loads.  On the other hand, the 0-63 random performs slower than linear.  You can get the same speed as the uniform access as long as the entire simdgroup pulls from the same 16-element aligned piece of memory.

**Texture Loads**: Unlike many other GPUs, texture_buffers act like textures rather than buffers.  There appears to be a small (~10%) penalty for loading 4-element vectors as floats, with no such penalty for the equivalent half operations.  RGBA32 is half rate, but everything else is full rate including RGBA16 and RG32.

**Texture Sampling**: Everything is the same as loads, except bilinear filtering of RG32 (half rate) and RGBA32 (quarter rate).
</details>

<details>
<summary>AMD RDNA1 (Radeon Pro 5600M)</summary>

```
  0.52ms   1.44x cbuffer{float4} uniform
  0.76ms   0.99x cbuffer{float4} linear
  0.76ms   0.99x cbuffer{float4} random
  0.76ms   0.99x cbuffer{float4} random+
  0.58ms   1.29x device const rg8unorm<float2>* uniform
  0.76ms   0.99x device const rg8unorm<float2>* linear
  0.79ms   0.95x device const rg8unorm<float2>* random
  0.79ms   0.95x device const rg8unorm<float2>* random+
  0.76ms   1.00x device const rgba8unorm<float4>* uniform
  0.76ms   1.00x device const rgba8unorm<float4>* linear
  0.76ms   1.00x device const rgba8unorm<float4>* random
  0.76ms   1.00x device const rgba8unorm<float4>* random+
  0.71ms   1.06x device const rg8unorm<half2>* uniform
  0.88ms   0.86x device const rg8unorm<half2>* linear
  0.88ms   0.86x device const rg8unorm<half2>* random
  0.88ms   0.86x device const rg8unorm<half2>* random+
  0.77ms   0.98x device const rgba8unorm<half4>* uniform
  0.87ms   0.86x device const rgba8unorm<half4>* linear
  0.88ms   0.86x device const rgba8unorm<half4>* random
  0.88ms   0.86x device const rgba8unorm<half4>* random+
  0.60ms   1.25x device const half2* uniform
  0.40ms   1.87x device const half2* linear
  0.41ms   1.86x device const half2* random
  0.41ms   1.86x device const half2* random+
  0.78ms   0.97x device const half4* uniform
  0.50ms   1.50x device const half4* linear
  0.51ms   1.49x device const half4* random
  0.51ms   1.49x device const half4* random+
  0.50ms   1.52x device const float1* uniform
  0.39ms   1.91x device const float1* linear
  0.44ms   1.72x device const float1* random
  0.44ms   1.72x device const float1* random+
  0.51ms   1.49x device const float2* uniform
  0.49ms   1.54x device const float2* linear
  0.53ms   1.43x device const float2* random
  0.53ms   1.43x device const float2* random+
  0.53ms   1.41x device const float4* uniform
  0.76ms   0.99x device const float4* linear
  0.76ms   1.00x device const float4* random
  0.76ms   1.00x device const float4* random+
  0.73ms   1.04x device const packed_float2* uniform
  0.49ms   1.54x device const packed_float2* linear
  0.53ms   1.43x device const packed_float2* random
  0.53ms   1.43x device const packed_float2* random+
  1.00ms   0.75x device const packed_float3* uniform
  0.86ms   0.88x device const packed_float3* linear
  1.50ms   0.50x device const packed_float3* random
  1.51ms   0.50x device const packed_float3* random+
  1.22ms   0.62x device const packed_float4* uniform
  0.76ms   0.99x device const packed_float4* linear
  0.76ms   0.99x device const packed_float4* random
  0.76ms   0.99x device const packed_float4* random+
  0.72ms   1.04x device const unaligned packed_float2* uniform
  0.76ms   1.00x device const unaligned packed_float2* linear
  0.76ms   1.00x device const unaligned packed_float2* random
  0.76ms   0.99x device const unaligned packed_float2* random+
  1.22ms   0.62x device const unaligned packed_float4* uniform
  1.50ms   0.50x device const unaligned packed_float4* linear
  1.51ms   0.50x device const unaligned packed_float4* random
  1.57ms   0.48x device const unaligned packed_float4* random+
  0.50ms   1.51x constant float1* uniform
  0.39ms   1.91x constant float1* linear
  0.44ms   1.72x constant float1* random
  0.44ms   1.72x constant float1* random+
  0.51ms   1.49x constant float2* uniform
  0.49ms   1.54x constant float2* linear
  0.53ms   1.43x constant float2* random
  0.53ms   1.43x constant float2* random+
  0.53ms   1.41x constant float4* uniform
  0.76ms   0.99x constant float4* linear
  0.76ms   0.99x constant float4* random
  0.76ms   0.99x constant float4* random+
  0.73ms   1.04x constant packed_float2* uniform
  0.49ms   1.54x constant packed_float2* linear
  0.53ms   1.43x constant packed_float2* random
  0.53ms   1.43x constant packed_float2* random+
  1.00ms   0.75x constant packed_float3* uniform
  0.86ms   0.88x constant packed_float3* linear
  1.50ms   0.50x constant packed_float3* random
  1.51ms   0.50x constant packed_float3* random+
  1.22ms   0.62x constant packed_float4* uniform
  0.76ms   0.99x constant packed_float4* linear
  0.76ms   1.00x constant packed_float4* random
  0.76ms   0.99x constant packed_float4* random+
  0.76ms   1.00x texture_buffer<R8> uniform
  0.76ms   1.00x texture_buffer<R8> linear
  0.76ms   1.00x texture_buffer<R8> random
  0.76ms   1.00x texture_buffer<R8> random+
  0.76ms   1.00x texture_buffer<RG8> uniform
  0.76ms   1.00x texture_buffer<RG8> linear
  0.76ms   1.00x texture_buffer<RG8> random
  0.76ms   1.00x texture_buffer<RG8> random+
  0.76ms   0.99x texture_buffer<RGBA8> uniform
  0.76ms   0.99x texture_buffer<RGBA8> linear
  0.76ms   0.99x texture_buffer<RGBA8> random
  0.76ms   0.99x texture_buffer<RGBA8> random+
  0.76ms   1.00x texture_buffer<R16> uniform
  0.76ms   1.00x texture_buffer<R16> linear
  0.76ms   1.00x texture_buffer<R16> random
  0.76ms   1.00x texture_buffer<R16> random+
  0.76ms   1.00x texture_buffer<RG16> uniform
  0.76ms   1.00x texture_buffer<RG16> linear
  0.76ms   1.00x texture_buffer<RG16> random
  0.76ms   1.00x texture_buffer<RG16> random+
  0.76ms   0.99x texture_buffer<RGBA16> uniform
  0.76ms   0.99x texture_buffer<RGBA16> linear
  0.76ms   0.99x texture_buffer<RGBA16> random
  0.76ms   0.99x texture_buffer<RGBA16> random+
  0.75ms   1.00x texture_buffer<R32> uniform
  0.75ms   1.00x texture_buffer<R32> linear
  0.75ms   1.00x texture_buffer<R32> random
  0.75ms   1.00x texture_buffer<R32> random+
  0.76ms   1.00x texture_buffer<RG32> uniform
  0.76ms   1.00x texture_buffer<RG32> linear
  0.76ms   1.00x texture_buffer<RG32> random
  0.76ms   1.00x texture_buffer<RG32> random+
  0.76ms   0.99x texture_buffer<RGBA32> uniform
  0.76ms   0.99x texture_buffer<RGBA32> linear
  0.76ms   0.99x texture_buffer<RGBA32> random
  0.76ms   0.99x texture_buffer<RGBA32> random+
  0.39ms   1.92x texture2d<R8> uniform
  0.40ms   1.88x texture2d<R8> linear
  0.40ms   1.87x texture2d<R8> random
  0.40ms   1.87x texture2d<R8> random+
  0.40ms   1.90x texture2d<RG8> uniform
  0.41ms   1.86x texture2d<RG8> linear
  0.39ms   1.92x texture2d<RG8> random
  0.39ms   1.92x texture2d<RG8> random+
  0.76ms   0.99x texture2d<RGBA8> uniform
  0.76ms   1.00x texture2d<RGBA8> linear
  0.76ms   1.00x texture2d<RGBA8> random
  0.76ms   1.00x texture2d<RGBA8> random+
  0.39ms   1.92x texture2d<R16> uniform
  0.40ms   1.88x texture2d<R16> linear
  0.40ms   1.87x texture2d<R16> random
  0.40ms   1.87x texture2d<R16> random+
  0.40ms   1.91x texture2d<RG16> uniform
  0.40ms   1.88x texture2d<RG16> linear
  0.39ms   1.92x texture2d<RG16> random
  0.39ms   1.92x texture2d<RG16> random+
  0.76ms   0.99x texture2d<RGBA16> uniform
  0.76ms   1.00x texture2d<RGBA16> linear
  0.76ms   1.00x texture2d<RGBA16> random
  0.76ms   1.00x texture2d<RGBA16> random+
  0.39ms   1.92x texture2d<R32> uniform
  0.40ms   1.87x texture2d<R32> linear
  0.40ms   1.87x texture2d<R32> random
  0.40ms   1.87x texture2d<R32> random+
  0.40ms   1.90x texture2d<RG32> uniform
  0.76ms   0.99x texture2d<RG32> linear
  0.39ms   1.92x texture2d<RG32> random
  0.39ms   1.92x texture2d<RG32> random+
  0.76ms   0.99x texture2d<RGBA32> uniform
  0.76ms   0.99x texture2d<RGBA32> linear
  0.76ms   1.00x texture2d<RGBA32> random
  0.76ms   1.00x texture2d<RGBA32> random+
  1.50ms   0.50x texture2d<R8>.sample(nearest) uniform
  1.50ms   0.50x texture2d<R8>.sample(nearest) linear
  1.50ms   0.50x texture2d<R8>.sample(nearest) random
  1.50ms   0.50x texture2d<R8>.sample(nearest) random+
  1.50ms   0.50x texture2d<RG8>.sample(nearest) uniform
  1.50ms   0.50x texture2d<RG8>.sample(nearest) linear
  1.50ms   0.50x texture2d<RG8>.sample(nearest) random
  1.50ms   0.50x texture2d<RG8>.sample(nearest) random+
  1.50ms   0.50x texture2d<RGBA8>.sample(nearest) uniform
  1.50ms   0.50x texture2d<RGBA8>.sample(nearest) linear
  1.50ms   0.50x texture2d<RGBA8>.sample(nearest) random
  1.50ms   0.50x texture2d<RGBA8>.sample(nearest) random+
  1.50ms   0.50x texture2d<R16>.sample(nearest) uniform
  1.50ms   0.50x texture2d<R16>.sample(nearest) linear
  1.50ms   0.50x texture2d<R16>.sample(nearest) random
  1.50ms   0.50x texture2d<R16>.sample(nearest) random+
  1.50ms   0.50x texture2d<RG16>.sample(nearest) uniform
  1.50ms   0.50x texture2d<RG16>.sample(nearest) linear
  1.50ms   0.50x texture2d<RG16>.sample(nearest) random
  1.50ms   0.50x texture2d<RG16>.sample(nearest) random+
  1.50ms   0.50x texture2d<RGBA16>.sample(nearest) uniform
  1.50ms   0.50x texture2d<RGBA16>.sample(nearest) linear
  1.50ms   0.50x texture2d<RGBA16>.sample(nearest) random
  1.50ms   0.50x texture2d<RGBA16>.sample(nearest) random+
  1.50ms   0.50x texture2d<R32>.sample(nearest) uniform
  1.50ms   0.50x texture2d<R32>.sample(nearest) linear
  1.50ms   0.50x texture2d<R32>.sample(nearest) random
  1.50ms   0.50x texture2d<R32>.sample(nearest) random+
  1.50ms   0.50x texture2d<RG32>.sample(nearest) uniform
  1.50ms   0.50x texture2d<RG32>.sample(nearest) linear
  1.50ms   0.50x texture2d<RG32>.sample(nearest) random
  1.50ms   0.50x texture2d<RG32>.sample(nearest) random+
  1.51ms   0.50x texture2d<RGBA32>.sample(nearest) uniform
  1.51ms   0.50x texture2d<RGBA32>.sample(nearest) linear
  1.51ms   0.50x texture2d<RGBA32>.sample(nearest) random
  2.06ms   0.37x texture2d<RGBA32>.sample(nearest) random+
  1.50ms   0.50x texture2d<R8>.sample(bilinear) uniform
  1.50ms   0.50x texture2d<R8>.sample(bilinear) linear
  1.50ms   0.50x texture2d<R8>.sample(bilinear) random
  1.50ms   0.50x texture2d<R8>.sample(bilinear) random+
  1.50ms   0.50x texture2d<RG8>.sample(bilinear) uniform
  1.50ms   0.50x texture2d<RG8>.sample(bilinear) linear
  1.50ms   0.50x texture2d<RG8>.sample(bilinear) random
  1.50ms   0.50x texture2d<RG8>.sample(bilinear) random+
  1.50ms   0.50x texture2d<RGBA8>.sample(bilinear) uniform
  1.50ms   0.50x texture2d<RGBA8>.sample(bilinear) linear
  1.50ms   0.50x texture2d<RGBA8>.sample(bilinear) random
  1.51ms   0.50x texture2d<RGBA8>.sample(bilinear) random+
  1.50ms   0.50x texture2d<R16>.sample(bilinear) uniform
  1.50ms   0.50x texture2d<R16>.sample(bilinear) linear
  1.50ms   0.50x texture2d<R16>.sample(bilinear) random
  1.50ms   0.50x texture2d<R16>.sample(bilinear) random+
  1.50ms   0.50x texture2d<RG16>.sample(bilinear) uniform
  1.50ms   0.50x texture2d<RG16>.sample(bilinear) linear
  1.51ms   0.50x texture2d<RG16>.sample(bilinear) random
  1.50ms   0.50x texture2d<RG16>.sample(bilinear) random+
  1.51ms   0.50x texture2d<RGBA16>.sample(bilinear) uniform
  1.50ms   0.50x texture2d<RGBA16>.sample(bilinear) linear
  1.51ms   0.50x texture2d<RGBA16>.sample(bilinear) random
  1.51ms   0.50x texture2d<RGBA16>.sample(bilinear) random+
  1.50ms   0.50x texture2d<R32>.sample(bilinear) uniform
  1.50ms   0.50x texture2d<R32>.sample(bilinear) linear
  1.50ms   0.50x texture2d<R32>.sample(bilinear) random
  1.50ms   0.50x texture2d<R32>.sample(bilinear) random+
  1.50ms   0.50x texture2d<RG32>.sample(bilinear) uniform
  1.50ms   0.50x texture2d<RG32>.sample(bilinear) linear
  1.50ms   0.50x texture2d<RG32>.sample(bilinear) random
  1.50ms   0.50x texture2d<RG32>.sample(bilinear) random+
  2.99ms   0.25x texture2d<RGBA32>.sample(bilinear) uniform
  2.99ms   0.25x texture2d<RGBA32>.sample(bilinear) linear
  3.00ms   0.25x texture2d<RGBA32>.sample(bilinear) random
  4.11ms   0.18x texture2d<RGBA32>.sample(bilinear) random+
  0.76ms   1.00x texture_buffer<R8H> uniform
  0.76ms   0.99x texture_buffer<R8H> linear
  0.76ms   0.99x texture_buffer<R8H> random
  0.76ms   0.99x texture_buffer<R8H> random+
  0.76ms   1.00x texture_buffer<RG8H> uniform
  0.76ms   1.00x texture_buffer<RG8H> linear
  0.76ms   0.99x texture_buffer<RG8H> random
  0.76ms   0.99x texture_buffer<RG8H> random+
  0.76ms   1.00x texture_buffer<RGBA8H> uniform
  0.76ms   1.00x texture_buffer<RGBA8H> linear
  0.76ms   0.99x texture_buffer<RGBA8H> random
  0.76ms   1.00x texture_buffer<RGBA8H> random+
  0.76ms   1.00x texture_buffer<R16H> uniform
  0.76ms   1.00x texture_buffer<R16H> linear
  0.76ms   0.99x texture_buffer<R16H> random
  0.76ms   0.99x texture_buffer<R16H> random+
  0.76ms   1.00x texture_buffer<RG16H> uniform
  0.76ms   0.99x texture_buffer<RG16H> linear
  0.76ms   0.99x texture_buffer<RG16H> random
  0.76ms   0.99x texture_buffer<RG16H> random+
  0.76ms   1.00x texture_buffer<RGBA16H> uniform
  0.76ms   1.00x texture_buffer<RGBA16H> linear
  0.76ms   1.00x texture_buffer<RGBA16H> random
  0.76ms   0.99x texture_buffer<RGBA16H> random+
  0.76ms   1.00x texture_buffer<R32H> uniform
  0.76ms   1.00x texture_buffer<R32H> linear
  0.76ms   1.00x texture_buffer<R32H> random
  0.76ms   1.00x texture_buffer<R32H> random+
  0.76ms   1.00x texture_buffer<RG32H> uniform
  0.76ms   0.99x texture_buffer<RG32H> linear
  0.76ms   0.99x texture_buffer<RG32H> random
  0.76ms   0.99x texture_buffer<RG32H> random+
  0.76ms   0.99x texture_buffer<RGBA32H> uniform
  0.76ms   0.99x texture_buffer<RGBA32H> linear
  0.76ms   0.99x texture_buffer<RGBA32H> random
  0.76ms   0.99x texture_buffer<RGBA32H> random+
  0.39ms   1.93x texture2d<R8H> uniform
  0.40ms   1.88x texture2d<R8H> linear
  0.40ms   1.88x texture2d<R8H> random
  0.40ms   1.88x texture2d<R8H> random+
  0.39ms   1.93x texture2d<RG8H> uniform
  0.41ms   1.86x texture2d<RG8H> linear
  0.40ms   1.87x texture2d<RG8H> random
  0.40ms   1.87x texture2d<RG8H> random+
  0.40ms   1.90x texture2d<RGBA8H> uniform
  0.40ms   1.87x texture2d<RGBA8H> linear
  0.39ms   1.92x texture2d<RGBA8H> random
  0.39ms   1.92x texture2d<RGBA8H> random+
  0.39ms   1.93x texture2d<R16H> uniform
  0.40ms   1.88x texture2d<R16H> linear
  0.40ms   1.88x texture2d<R16H> random
  0.40ms   1.88x texture2d<R16H> random+
  0.39ms   1.93x texture2d<RG16H> uniform
  0.41ms   1.85x texture2d<RG16H> linear
  0.40ms   1.87x texture2d<RG16H> random
  0.40ms   1.87x texture2d<RG16H> random+
  0.40ms   1.90x texture2d<RGBA16H> uniform
  0.77ms   0.99x texture2d<RGBA16H> linear
  0.39ms   1.92x texture2d<RGBA16H> random
  0.39ms   1.92x texture2d<RGBA16H> random+
  0.39ms   1.93x texture2d<R32H> uniform
  0.41ms   1.86x texture2d<R32H> linear
  0.40ms   1.88x texture2d<R32H> random
  0.40ms   1.88x texture2d<R32H> random+
  0.39ms   1.93x texture2d<RG32H> uniform
  0.76ms   1.00x texture2d<RG32H> linear
  0.40ms   1.87x texture2d<RG32H> random
  0.40ms   1.87x texture2d<RG32H> random+
  0.76ms   0.99x texture2d<RGBA32H> uniform
  0.77ms   0.98x texture2d<RGBA32H> linear
  0.77ms   0.98x texture2d<RGBA32H> random
  0.76ms   1.00x texture2d<RGBA32H> random+
  1.50ms   0.50x texture2d<R8H>.sample(nearest) uniform
  1.50ms   0.50x texture2d<R8H>.sample(nearest) linear
  1.50ms   0.50x texture2d<R8H>.sample(nearest) random
  1.50ms   0.50x texture2d<R8H>.sample(nearest) random+
  1.50ms   0.50x texture2d<RG8H>.sample(nearest) uniform
  1.50ms   0.50x texture2d<RG8H>.sample(nearest) linear
  1.50ms   0.50x texture2d<RG8H>.sample(nearest) random
  1.50ms   0.50x texture2d<RG8H>.sample(nearest) random+
  1.51ms   0.50x texture2d<RGBA8H>.sample(nearest) uniform
  1.50ms   0.50x texture2d<RGBA8H>.sample(nearest) linear
  1.50ms   0.50x texture2d<RGBA8H>.sample(nearest) random
  1.50ms   0.50x texture2d<RGBA8H>.sample(nearest) random+
  1.50ms   0.50x texture2d<R16H>.sample(nearest) uniform
  1.50ms   0.50x texture2d<R16H>.sample(nearest) linear
  1.50ms   0.50x texture2d<R16H>.sample(nearest) random
  1.50ms   0.50x texture2d<R16H>.sample(nearest) random+
  1.50ms   0.50x texture2d<RG16H>.sample(nearest) uniform
  1.50ms   0.50x texture2d<RG16H>.sample(nearest) linear
  1.50ms   0.50x texture2d<RG16H>.sample(nearest) random
  1.50ms   0.50x texture2d<RG16H>.sample(nearest) random+
  1.50ms   0.50x texture2d<RGBA16H>.sample(nearest) uniform
  1.50ms   0.50x texture2d<RGBA16H>.sample(nearest) linear
  1.50ms   0.50x texture2d<RGBA16H>.sample(nearest) random
  1.50ms   0.50x texture2d<RGBA16H>.sample(nearest) random+
  1.50ms   0.50x texture2d<R32H>.sample(nearest) uniform
  1.50ms   0.50x texture2d<R32H>.sample(nearest) linear
  1.50ms   0.50x texture2d<R32H>.sample(nearest) random
  1.50ms   0.50x texture2d<R32H>.sample(nearest) random+
  1.50ms   0.50x texture2d<RG32H>.sample(nearest) uniform
  1.50ms   0.50x texture2d<RG32H>.sample(nearest) linear
  1.50ms   0.50x texture2d<RG32H>.sample(nearest) random
  1.50ms   0.50x texture2d<RG32H>.sample(nearest) random+
  1.51ms   0.50x texture2d<RGBA32H>.sample(nearest) uniform
  1.51ms   0.50x texture2d<RGBA32H>.sample(nearest) linear
  1.50ms   0.50x texture2d<RGBA32H>.sample(nearest) random
  2.06ms   0.37x texture2d<RGBA32H>.sample(nearest) random+
  1.50ms   0.50x texture2d<R8H>.sample(bilinear) uniform
  1.50ms   0.50x texture2d<R8H>.sample(bilinear) linear
  1.50ms   0.50x texture2d<R8H>.sample(bilinear) random
  1.50ms   0.50x texture2d<R8H>.sample(bilinear) random+
  1.50ms   0.50x texture2d<RG8H>.sample(bilinear) uniform
  1.50ms   0.50x texture2d<RG8H>.sample(bilinear) linear
  1.50ms   0.50x texture2d<RG8H>.sample(bilinear) random
  1.50ms   0.50x texture2d<RG8H>.sample(bilinear) random+
  1.51ms   0.50x texture2d<RGBA8H>.sample(bilinear) uniform
  1.50ms   0.50x texture2d<RGBA8H>.sample(bilinear) linear
  1.50ms   0.50x texture2d<RGBA8H>.sample(bilinear) random
  1.50ms   0.50x texture2d<RGBA8H>.sample(bilinear) random+
  1.50ms   0.50x texture2d<R16H>.sample(bilinear) uniform
  1.50ms   0.50x texture2d<R16H>.sample(bilinear) linear
  1.50ms   0.50x texture2d<R16H>.sample(bilinear) random
  1.50ms   0.50x texture2d<R16H>.sample(bilinear) random+
  1.50ms   0.50x texture2d<RG16H>.sample(bilinear) uniform
  1.50ms   0.50x texture2d<RG16H>.sample(bilinear) linear
  1.50ms   0.50x texture2d<RG16H>.sample(bilinear) random
  1.50ms   0.50x texture2d<RG16H>.sample(bilinear) random+
  1.50ms   0.50x texture2d<RGBA16H>.sample(bilinear) uniform
  1.50ms   0.50x texture2d<RGBA16H>.sample(bilinear) linear
  1.50ms   0.50x texture2d<RGBA16H>.sample(bilinear) random
  1.50ms   0.50x texture2d<RGBA16H>.sample(bilinear) random+
  1.50ms   0.50x texture2d<R32H>.sample(bilinear) uniform
  1.50ms   0.50x texture2d<R32H>.sample(bilinear) linear
  1.50ms   0.50x texture2d<R32H>.sample(bilinear) random
  1.50ms   0.50x texture2d<R32H>.sample(bilinear) random+
  1.50ms   0.50x texture2d<RG32H>.sample(bilinear) uniform
  1.50ms   0.50x texture2d<RG32H>.sample(bilinear) linear
  1.50ms   0.50x texture2d<RG32H>.sample(bilinear) random
  1.50ms   0.50x texture2d<RG32H>.sample(bilinear) random+
  2.99ms   0.25x texture2d<RGBA32H>.sample(bilinear) uniform
  3.00ms   0.25x texture2d<RGBA32H>.sample(bilinear) linear
  2.99ms   0.25x texture2d<RGBA32H>.sample(bilinear) random
  4.11ms   0.18x texture2d<RGBA32H>.sample(bilinear) random+
```

**AMD RDNA1** TODO.
</details>

<details>
<summary>Nvidia Kepler (GT 750M)</summary>

```
 17.59ms   0.60x cbuffer{float4} uniform
451.48ms   0.02x cbuffer{float4} linear
174.49ms   0.06x cbuffer{float4} random
484.69ms   0.02x cbuffer{float4} random+
 30.39ms   0.35x device const rgba8unorm<float4>* uniform
 39.32ms   0.27x device const rgba8unorm<float4>* linear
 34.07ms   0.31x device const rgba8unorm<float4>* random
 53.39ms   0.20x device const rgba8unorm<float4>* random+
 30.43ms   0.35x device const rgba8unorm<half4>* uniform
 39.12ms   0.27x device const rgba8unorm<half4>* linear
 33.94ms   0.31x device const rgba8unorm<half4>* random
 53.41ms   0.20x device const rgba8unorm<half4>* random+
 15.29ms   0.69x device const half2* uniform
 17.02ms   0.62x device const half2* linear
 16.44ms   0.64x device const half2* random
 18.47ms   0.57x device const half2* random+
 23.68ms   0.45x device const half4* uniform
 24.98ms   0.42x device const half4* linear
 23.98ms   0.44x device const half4* random
 26.62ms   0.40x device const half4* random+
  9.84ms   1.07x device const float1* uniform
 12.36ms   0.85x device const float1* linear
 11.01ms   0.96x device const float1* random
 14.89ms   0.71x device const float1* random+
  9.89ms   1.07x device const float2* uniform
 15.23ms   0.69x device const float2* linear
 12.57ms   0.84x device const float2* random
 22.81ms   0.46x device const float2* random+
 11.54ms   0.92x device const float4* uniform
 27.14ms   0.39x device const float4* linear
 27.06ms   0.39x device const float4* random
 60.69ms   0.17x device const float4* random+
 11.97ms   0.88x device const packed_float2* uniform
 28.36ms   0.37x device const packed_float2* linear
 19.59ms   0.54x device const packed_float2* random
 44.24ms   0.24x device const packed_float2* random+
 16.05ms   0.66x device const packed_float3* uniform
 54.40ms   0.19x device const packed_float3* linear
 34.15ms   0.31x device const packed_float3* random
 90.54ms   0.12x device const packed_float3* random+
 19.81ms   0.53x device const packed_float4* uniform
 89.73ms   0.12x device const packed_float4* linear
 53.30ms   0.20x device const packed_float4* random
154.06ms   0.07x device const packed_float4* random+
 11.96ms   0.88x device const unaligned packed_float2* uniform
 28.35ms   0.37x device const unaligned packed_float2* linear
 19.61ms   0.54x device const unaligned packed_float2* random
 44.25ms   0.24x device const unaligned packed_float2* random+
 19.84ms   0.53x device const unaligned packed_float4* uniform
 89.75ms   0.12x device const unaligned packed_float4* linear
 53.22ms   0.20x device const unaligned packed_float4* random
154.06ms   0.07x device const unaligned packed_float4* random+
 11.70ms   0.90x constant float1* uniform
168.18ms   0.06x constant float1* linear
 83.64ms   0.13x constant float1* random
164.22ms   0.06x constant float1* random+
 15.54ms   0.68x constant float2* uniform
194.10ms   0.05x constant float2* linear
 85.07ms   0.12x constant float2* random
176.30ms   0.06x constant float2* random+
 17.18ms   0.61x constant float4* uniform
450.86ms   0.02x constant float4* linear
177.70ms   0.06x constant float4* random
474.71ms   0.02x constant float4* random+
 15.23ms   0.69x constant packed_float2* uniform
190.06ms   0.06x constant packed_float2* linear
 81.58ms   0.13x constant packed_float2* random
162.17ms   0.07x constant packed_float2* random+
 16.50ms   0.64x constant packed_float3* uniform
648.08ms   0.02x constant packed_float3* linear
252.86ms   0.04x constant packed_float3* random
649.86ms   0.02x constant packed_float3* random+
 17.42ms   0.61x constant packed_float4* uniform
474.78ms   0.02x constant packed_float4* linear
182.81ms   0.06x constant packed_float4* random
501.72ms   0.02x constant packed_float4* random+
 10.57ms   1.00x texture_buffer<R8> uniform
 10.58ms   1.00x texture_buffer<R8> linear
 10.57ms   1.00x texture_buffer<R8> random
 10.57ms   1.00x texture_buffer<R8> random+
 10.68ms   0.99x texture_buffer<RG8> uniform
 10.47ms   1.01x texture_buffer<RG8> linear
 10.34ms   1.02x texture_buffer<RG8> random
 10.10ms   1.05x texture_buffer<RG8> random+
  9.96ms   1.06x texture_buffer<RGBA8> uniform
  9.90ms   1.07x texture_buffer<RGBA8> linear
  9.93ms   1.06x texture_buffer<RGBA8> random
  9.90ms   1.07x texture_buffer<RGBA8> random+
 10.69ms   0.99x texture_buffer<R16> uniform
 10.66ms   0.99x texture_buffer<R16> linear
 10.48ms   1.01x texture_buffer<R16> random
 10.56ms   1.00x texture_buffer<R16> random+
 10.70ms   0.99x texture_buffer<RG16> uniform
 10.48ms   1.01x texture_buffer<RG16> linear
 10.21ms   1.03x texture_buffer<RG16> random
 10.22ms   1.03x texture_buffer<RG16> random+
 10.05ms   1.05x texture_buffer<RGBA16> uniform
  9.77ms   1.08x texture_buffer<RGBA16> linear
  9.92ms   1.07x texture_buffer<RGBA16> random
 10.38ms   1.02x texture_buffer<RGBA16> random+
 10.71ms   0.99x texture_buffer<R32> uniform
 10.57ms   1.00x texture_buffer<R32> linear
 10.56ms   1.00x texture_buffer<R32> random
 10.72ms   0.99x texture_buffer<R32> random+
 10.55ms   1.00x texture_buffer<RG32> uniform
 10.47ms   1.01x texture_buffer<RG32> linear
 10.16ms   1.04x texture_buffer<RG32> random
 10.27ms   1.03x texture_buffer<RG32> random+
 18.12ms   0.58x texture_buffer<RGBA32> uniform
 18.28ms   0.58x texture_buffer<RGBA32> linear
 18.00ms   0.59x texture_buffer<RGBA32> random
 18.13ms   0.58x texture_buffer<RGBA32> random+
 10.35ms   1.02x texture2d<R8> uniform
 10.73ms   0.98x texture2d<R8> linear
 10.71ms   0.99x texture2d<R8> random
 10.89ms   0.97x texture2d<R8> random+
  9.85ms   1.07x texture2d<RG8> uniform
 10.65ms   0.99x texture2d<RG8> linear
 10.82ms   0.98x texture2d<RG8> random
 10.79ms   0.98x texture2d<RG8> random+
 10.19ms   1.04x texture2d<RGBA8> uniform
 10.14ms   1.04x texture2d<RGBA8> linear
 10.30ms   1.03x texture2d<RGBA8> random
 10.05ms   1.05x texture2d<RGBA8> random+
 10.32ms   1.02x texture2d<R16> uniform
 10.72ms   0.99x texture2d<R16> linear
 10.76ms   0.98x texture2d<R16> random
 10.67ms   0.99x texture2d<R16> random+
  9.97ms   1.06x texture2d<RG16> uniform
 10.80ms   0.98x texture2d<RG16> linear
 10.71ms   0.99x texture2d<RG16> random
 10.78ms   0.98x texture2d<RG16> random+
 10.16ms   1.04x texture2d<RGBA16> uniform
 10.14ms   1.04x texture2d<RGBA16> linear
 10.15ms   1.04x texture2d<RGBA16> random
 12.54ms   0.84x texture2d<RGBA16> random+
 10.47ms   1.01x texture2d<R32> uniform
 10.60ms   1.00x texture2d<R32> linear
 10.70ms   0.99x texture2d<R32> random
 10.73ms   0.98x texture2d<R32> random+
  9.96ms   1.06x texture2d<RG32> uniform
 10.67ms   0.99x texture2d<RG32> linear
 10.78ms   0.98x texture2d<RG32> random
 12.55ms   0.84x texture2d<RG32> random+
 18.06ms   0.58x texture2d<RGBA32> uniform
 18.12ms   0.58x texture2d<RGBA32> linear
 18.13ms   0.58x texture2d<RGBA32> random
 18.30ms   0.58x texture2d<RGBA32> random+
 10.50ms   1.01x texture2d<R8>.sample(nearest) uniform
 10.78ms   0.98x texture2d<R8>.sample(nearest) linear
 10.76ms   0.98x texture2d<R8>.sample(nearest) random
 10.82ms   0.98x texture2d<R8>.sample(nearest) random+
 10.25ms   1.03x texture2d<RG8>.sample(nearest) uniform
 10.35ms   1.02x texture2d<RG8>.sample(nearest) linear
 10.30ms   1.03x texture2d<RG8>.sample(nearest) random
  9.97ms   1.06x texture2d<RG8>.sample(nearest) random+
 10.22ms   1.03x texture2d<RGBA8>.sample(nearest) uniform
 10.18ms   1.04x texture2d<RGBA8>.sample(nearest) linear
 10.15ms   1.04x texture2d<RGBA8>.sample(nearest) random
 10.11ms   1.04x texture2d<RGBA8>.sample(nearest) random+
 10.58ms   1.00x texture2d<R16>.sample(nearest) uniform
 10.99ms   0.96x texture2d<R16>.sample(nearest) linear
 10.66ms   0.99x texture2d<R16>.sample(nearest) random
 10.80ms   0.98x texture2d<R16>.sample(nearest) random+
 10.25ms   1.03x texture2d<RG16>.sample(nearest) uniform
 10.34ms   1.02x texture2d<RG16>.sample(nearest) linear
 10.12ms   1.04x texture2d<RG16>.sample(nearest) random
 10.13ms   1.04x texture2d<RG16>.sample(nearest) random+
 10.37ms   1.02x texture2d<RGBA16>.sample(nearest) uniform
 10.00ms   1.06x texture2d<RGBA16>.sample(nearest) linear
 10.12ms   1.04x texture2d<RGBA16>.sample(nearest) random
 12.53ms   0.84x texture2d<RGBA16>.sample(nearest) random+
 10.58ms   1.00x texture2d<R32>.sample(nearest) uniform
 10.93ms   0.97x texture2d<R32>.sample(nearest) linear
 10.75ms   0.98x texture2d<R32>.sample(nearest) random
 10.97ms   0.96x texture2d<R32>.sample(nearest) random+
 10.11ms   1.04x texture2d<RG32>.sample(nearest) uniform
 10.35ms   1.02x texture2d<RG32>.sample(nearest) linear
 10.12ms   1.04x texture2d<RG32>.sample(nearest) random
 12.55ms   0.84x texture2d<RG32>.sample(nearest) random+
 18.14ms   0.58x texture2d<RGBA32>.sample(nearest) uniform
 18.33ms   0.58x texture2d<RGBA32>.sample(nearest) linear
 17.97ms   0.59x texture2d<RGBA32>.sample(nearest) random
 18.14ms   0.58x texture2d<RGBA32>.sample(nearest) random+
 10.53ms   1.00x texture2d<R8>.sample(bilinear) uniform
 10.82ms   0.98x texture2d<R8>.sample(bilinear) linear
 10.74ms   0.98x texture2d<R8>.sample(bilinear) random
 10.97ms   0.96x texture2d<R8>.sample(bilinear) random+
 10.03ms   1.05x texture2d<RG8>.sample(bilinear) uniform
 10.37ms   1.02x texture2d<RG8>.sample(bilinear) linear
 10.12ms   1.04x texture2d<RG8>.sample(bilinear) random
 10.13ms   1.04x texture2d<RG8>.sample(bilinear) random+
 10.23ms   1.03x texture2d<RGBA8>.sample(bilinear) uniform
 10.16ms   1.04x texture2d<RGBA8>.sample(bilinear) linear
 10.20ms   1.04x texture2d<RGBA8>.sample(bilinear) random
 10.04ms   1.05x texture2d<RGBA8>.sample(bilinear) random+
 10.62ms   0.99x texture2d<R16>.sample(bilinear) uniform
 10.73ms   0.98x texture2d<R16>.sample(bilinear) linear
 10.79ms   0.98x texture2d<R16>.sample(bilinear) random
 10.73ms   0.98x texture2d<R16>.sample(bilinear) random+
 10.23ms   1.03x texture2d<RG16>.sample(bilinear) uniform
 10.47ms   1.01x texture2d<RG16>.sample(bilinear) linear
 10.03ms   1.05x texture2d<RG16>.sample(bilinear) random
 10.11ms   1.04x texture2d<RG16>.sample(bilinear) random+
 10.28ms   1.03x texture2d<RGBA16>.sample(bilinear) uniform
 10.16ms   1.04x texture2d<RGBA16>.sample(bilinear) linear
 10.12ms   1.04x texture2d<RGBA16>.sample(bilinear) random
 12.51ms   0.84x texture2d<RGBA16>.sample(bilinear) random+
 10.69ms   0.99x texture2d<R32>.sample(bilinear) uniform
 10.64ms   0.99x texture2d<R32>.sample(bilinear) linear
 10.66ms   0.99x texture2d<R32>.sample(bilinear) random
 10.72ms   0.98x texture2d<R32>.sample(bilinear) random+
 10.26ms   1.03x texture2d<RG32>.sample(bilinear) uniform
 10.34ms   1.02x texture2d<RG32>.sample(bilinear) linear
 10.14ms   1.04x texture2d<RG32>.sample(bilinear) random
 12.70ms   0.83x texture2d<RG32>.sample(bilinear) random+
 36.07ms   0.29x texture2d<RGBA32>.sample(bilinear) uniform
 36.46ms   0.29x texture2d<RGBA32>.sample(bilinear) linear
 36.09ms   0.29x texture2d<RGBA32>.sample(bilinear) random
 36.43ms   0.29x texture2d<RGBA32>.sample(bilinear) random+
 10.50ms   1.01x texture_buffer<R8H> uniform
 10.56ms   1.00x texture_buffer<R8H> linear
 10.59ms   1.00x texture_buffer<R8H> random
 10.58ms   1.00x texture_buffer<R8H> random+
 10.70ms   0.99x texture_buffer<RG8H> uniform
 10.47ms   1.01x texture_buffer<RG8H> linear
 10.36ms   1.02x texture_buffer<RG8H> random
 10.09ms   1.05x texture_buffer<RG8H> random+
  9.93ms   1.06x texture_buffer<RGBA8H> uniform
  9.91ms   1.07x texture_buffer<RGBA8H> linear
  9.92ms   1.07x texture_buffer<RGBA8H> random
  9.90ms   1.07x texture_buffer<RGBA8H> random+
 10.69ms   0.99x texture_buffer<R16H> uniform
 10.72ms   0.99x texture_buffer<R16H> linear
 10.39ms   1.02x texture_buffer<R16H> random
 10.58ms   1.00x texture_buffer<R16H> random+
 10.68ms   0.99x texture_buffer<RG16H> uniform
 10.47ms   1.01x texture_buffer<RG16H> linear
 10.23ms   1.03x texture_buffer<RG16H> random
 10.22ms   1.03x texture_buffer<RG16H> random+
 10.13ms   1.04x texture_buffer<RGBA16H> uniform
  9.75ms   1.08x texture_buffer<RGBA16H> linear
  9.91ms   1.07x texture_buffer<RGBA16H> random
 10.38ms   1.02x texture_buffer<RGBA16H> random+
 10.68ms   0.99x texture_buffer<R32H> uniform
 10.58ms   1.00x texture_buffer<R32H> linear
 10.57ms   1.00x texture_buffer<R32H> random
 10.65ms   0.99x texture_buffer<R32H> random+
 10.55ms   1.00x texture_buffer<RG32H> uniform
 10.46ms   1.01x texture_buffer<RG32H> linear
 10.22ms   1.03x texture_buffer<RG32H> random
 10.25ms   1.03x texture_buffer<RG32H> random+
 18.13ms   0.58x texture_buffer<RGBA32H> uniform
 18.28ms   0.58x texture_buffer<RGBA32H> linear
 18.01ms   0.59x texture_buffer<RGBA32H> random
 18.14ms   0.58x texture_buffer<RGBA32H> random+
 10.33ms   1.02x texture2d<R8H> uniform
 10.78ms   0.98x texture2d<R8H> linear
 10.72ms   0.98x texture2d<R8H> random
 10.84ms   0.97x texture2d<R8H> random+
  9.79ms   1.08x texture2d<RG8H> uniform
 10.70ms   0.99x texture2d<RG8H> linear
 10.78ms   0.98x texture2d<RG8H> random
 10.79ms   0.98x texture2d<RG8H> random+
 10.18ms   1.04x texture2d<RGBA8H> uniform
 10.15ms   1.04x texture2d<RGBA8H> linear
 10.29ms   1.03x texture2d<RGBA8H> random
 10.06ms   1.05x texture2d<RGBA8H> random+
 10.35ms   1.02x texture2d<R16H> uniform
 10.72ms   0.99x texture2d<R16H> linear
 10.76ms   0.98x texture2d<R16H> random
 10.74ms   0.98x texture2d<R16H> random+
  9.97ms   1.06x texture2d<RG16H> uniform
 10.79ms   0.98x texture2d<RG16H> linear
 10.63ms   0.99x texture2d<RG16H> random
 10.79ms   0.98x texture2d<RG16H> random+
 10.18ms   1.04x texture2d<RGBA16H> uniform
 10.13ms   1.04x texture2d<RGBA16H> linear
 10.16ms   1.04x texture2d<RGBA16H> random
 12.53ms   0.84x texture2d<RGBA16H> random+
 10.50ms   1.01x texture2d<R32H> uniform
 10.59ms   1.00x texture2d<R32H> linear
 10.73ms   0.98x texture2d<R32H> random
 10.69ms   0.99x texture2d<R32H> random+
  9.97ms   1.06x texture2d<RG32H> uniform
 10.73ms   0.98x texture2d<RG32H> linear
 10.73ms   0.98x texture2d<RG32H> random
 12.70ms   0.83x texture2d<RG32H> random+
 17.97ms   0.59x texture2d<RGBA32H> uniform
 18.09ms   0.58x texture2d<RGBA32H> linear
 18.13ms   0.58x texture2d<RGBA32H> random
 18.29ms   0.58x texture2d<RGBA32H> random+
 10.51ms   1.01x texture2d<R8H>.sample(nearest) uniform
 10.87ms   0.97x texture2d<R8H>.sample(nearest) linear
 10.78ms   0.98x texture2d<R8H>.sample(nearest) random
 10.84ms   0.97x texture2d<R8H>.sample(nearest) random+
 10.26ms   1.03x texture2d<RG8H>.sample(nearest) uniform
 10.31ms   1.02x texture2d<RG8H>.sample(nearest) linear
 10.33ms   1.02x texture2d<RG8H>.sample(nearest) random
  9.99ms   1.06x texture2d<RG8H>.sample(nearest) random+
 10.21ms   1.03x texture2d<RGBA8H>.sample(nearest) uniform
 10.19ms   1.04x texture2d<RGBA8H>.sample(nearest) linear
 10.14ms   1.04x texture2d<RGBA8H>.sample(nearest) random
 10.15ms   1.04x texture2d<RGBA8H>.sample(nearest) random+
 10.58ms   1.00x texture2d<R16H>.sample(nearest) uniform
 11.01ms   0.96x texture2d<R16H>.sample(nearest) linear
 10.64ms   0.99x texture2d<R16H>.sample(nearest) random
 10.84ms   0.97x texture2d<R16H>.sample(nearest) random+
 10.25ms   1.03x texture2d<RG16H>.sample(nearest) uniform
 10.37ms   1.02x texture2d<RG16H>.sample(nearest) linear
 10.13ms   1.04x texture2d<RG16H>.sample(nearest) random
 10.10ms   1.05x texture2d<RG16H>.sample(nearest) random+
 10.40ms   1.02x texture2d<RGBA16H>.sample(nearest) uniform
 10.05ms   1.05x texture2d<RGBA16H>.sample(nearest) linear
 10.13ms   1.04x texture2d<RGBA16H>.sample(nearest) random
 12.45ms   0.85x texture2d<RGBA16H>.sample(nearest) random+
 10.72ms   0.98x texture2d<R32H>.sample(nearest) uniform
 10.81ms   0.98x texture2d<R32H>.sample(nearest) linear
 10.79ms   0.98x texture2d<R32H>.sample(nearest) random
 11.03ms   0.96x texture2d<R32H>.sample(nearest) random+
 10.07ms   1.05x texture2d<RG32H>.sample(nearest) uniform
 10.32ms   1.02x texture2d<RG32H>.sample(nearest) linear
 10.14ms   1.04x texture2d<RG32H>.sample(nearest) random
 12.51ms   0.84x texture2d<RG32H>.sample(nearest) random+
 18.13ms   0.58x texture2d<RGBA32H>.sample(nearest) uniform
 18.33ms   0.58x texture2d<RGBA32H>.sample(nearest) linear
 17.98ms   0.59x texture2d<RGBA32H>.sample(nearest) random
 18.05ms   0.59x texture2d<RGBA32H>.sample(nearest) random+
 10.66ms   0.99x texture2d<R8H>.sample(bilinear) uniform
 10.81ms   0.98x texture2d<R8H>.sample(bilinear) linear
 10.73ms   0.98x texture2d<R8H>.sample(bilinear) random
 10.90ms   0.97x texture2d<R8H>.sample(bilinear) random+
 10.13ms   1.04x texture2d<RG8H>.sample(bilinear) uniform
 10.33ms   1.02x texture2d<RG8H>.sample(bilinear) linear
 10.14ms   1.04x texture2d<RG8H>.sample(bilinear) random
 10.12ms   1.04x texture2d<RG8H>.sample(bilinear) random+
 10.21ms   1.03x texture2d<RGBA8H>.sample(bilinear) uniform
 10.15ms   1.04x texture2d<RGBA8H>.sample(bilinear) linear
 10.28ms   1.03x texture2d<RGBA8H>.sample(bilinear) random
  9.96ms   1.06x texture2d<RGBA8H>.sample(bilinear) random+
 10.62ms   0.99x texture2d<R16H>.sample(bilinear) uniform
 10.79ms   0.98x texture2d<R16H>.sample(bilinear) linear
 10.75ms   0.98x texture2d<R16H>.sample(bilinear) random
 10.74ms   0.98x texture2d<R16H>.sample(bilinear) random+
 10.32ms   1.02x texture2d<RG16H>.sample(bilinear) uniform
 10.44ms   1.01x texture2d<RG16H>.sample(bilinear) linear
 10.04ms   1.05x texture2d<RG16H>.sample(bilinear) random
 10.07ms   1.05x texture2d<RG16H>.sample(bilinear) random+
 10.24ms   1.03x texture2d<RGBA16H>.sample(bilinear) uniform
 10.18ms   1.04x texture2d<RGBA16H>.sample(bilinear) linear
 10.13ms   1.04x texture2d<RGBA16H>.sample(bilinear) random
 12.49ms   0.85x texture2d<RGBA16H>.sample(bilinear) random+
 10.83ms   0.98x texture2d<R32H>.sample(bilinear) uniform
 10.64ms   0.99x texture2d<R32H>.sample(bilinear) linear
 10.79ms   0.98x texture2d<R32H>.sample(bilinear) random
 10.78ms   0.98x texture2d<R32H>.sample(bilinear) random+
 10.25ms   1.03x texture2d<RG32H>.sample(bilinear) uniform
 10.31ms   1.02x texture2d<RG32H>.sample(bilinear) linear
 10.13ms   1.04x texture2d<RG32H>.sample(bilinear) random
 12.70ms   0.83x texture2d<RG32H>.sample(bilinear) random+
 36.07ms   0.29x texture2d<RGBA32H>.sample(bilinear) uniform
 36.46ms   0.29x texture2d<RGBA32H>.sample(bilinear) linear
 36.11ms   0.29x texture2d<RGBA32H>.sample(bilinear) random
 36.44ms   0.29x texture2d<RGBA32H>.sample(bilinear) random+
```

Constant buffers are weirdly slow, even with uniform access.
</details>

<details>
<summary>Intel Gen7.5 (Iris Pro / i7-4980HQ)</summary>

```
  5.36ms  22.22x cbuffer{float4} uniform
 27.85ms   4.28x cbuffer{float4} linear
 61.30ms   1.94x cbuffer{float4} random
 62.65ms   1.90x cbuffer{float4} random+
 24.86ms   4.79x device const rgba8unorm<float4>* uniform
 34.38ms   3.46x device const rgba8unorm<float4>* linear
 39.95ms   2.98x device const rgba8unorm<float4>* random
 80.90ms   1.47x device const rgba8unorm<float4>* random+
 24.85ms   4.79x device const rgba8unorm<half4>* uniform
 34.34ms   3.47x device const rgba8unorm<half4>* linear
 39.93ms   2.98x device const rgba8unorm<half4>* random
 80.94ms   1.47x device const rgba8unorm<half4>* random+
 11.59ms  10.28x device const half2* uniform
 19.18ms   6.21x device const half2* linear
 18.86ms   6.31x device const half2* random
 39.43ms   3.02x device const half2* random+
 21.54ms   5.53x device const half4* uniform
 49.69ms   2.40x device const half4* linear
 56.25ms   2.12x device const half4* random
110.44ms   1.08x device const half4* random+
  2.76ms  43.20x device const float1* uniform
  8.45ms  14.09x device const float1* linear
  9.34ms  12.75x device const float1* random
 19.47ms   6.12x device const float1* random+
  2.56ms  46.43x device const float2* uniform
 15.66ms   7.60x device const float2* linear
 26.96ms   4.42x device const float2* random
 46.00ms   2.59x device const float2* random+
  5.43ms  21.93x device const float4* uniform
 28.06ms   4.24x device const float4* linear
 62.27ms   1.91x device const float4* random
 64.74ms   1.84x device const float4* random+
  2.57ms  46.33x device const packed_float2* uniform
 15.69ms   7.59x device const packed_float2* linear
 26.95ms   4.42x device const packed_float2* random
 45.95ms   2.59x device const packed_float2* random+
  6.38ms  18.66x device const packed_float3* uniform
 27.02ms   4.41x device const packed_float3* linear
 59.43ms   2.00x device const packed_float3* random
 72.80ms   1.64x device const packed_float3* random+
103.06ms   1.16x device const packed_float4* uniform
105.85ms   1.12x device const packed_float4* linear
109.34ms   1.09x device const packed_float4* random
108.08ms   1.10x device const packed_float4* random+
  4.15ms  28.70x device const unaligned packed_float2* uniform
 16.81ms   7.09x device const unaligned packed_float2* linear
 28.02ms   4.25x device const unaligned packed_float2* random
 50.96ms   2.34x device const unaligned packed_float2* random+
103.04ms   1.16x device const unaligned packed_float4* uniform
105.80ms   1.13x device const unaligned packed_float4* linear
105.90ms   1.12x device const unaligned packed_float4* random
106.10ms   1.12x device const unaligned packed_float4* random+
  2.73ms  43.56x constant float1* uniform
  8.46ms  14.07x constant float1* linear
  9.33ms  12.76x constant float1* random
 19.36ms   6.15x constant float1* random+
  2.57ms  46.41x constant float2* uniform
 15.70ms   7.58x constant float2* linear
 26.96ms   4.42x constant float2* random
 46.01ms   2.59x constant float2* random+
  5.40ms  22.05x constant float4* uniform
 28.14ms   4.23x constant float4* linear
 62.32ms   1.91x constant float4* random
 64.72ms   1.84x constant float4* random+
  3.40ms  35.04x constant packed_float2* uniform
 15.72ms   7.58x constant packed_float2* linear
 26.94ms   4.42x constant packed_float2* random
 46.08ms   2.58x constant packed_float2* random+
  6.40ms  18.61x constant packed_float3* uniform
 27.05ms   4.40x constant packed_float3* linear
 59.49ms   2.00x constant packed_float3* random
 72.76ms   1.64x constant packed_float3* random+
103.03ms   1.16x constant packed_float4* uniform
105.77ms   1.13x constant packed_float4* linear
105.88ms   1.12x constant packed_float4* random
105.99ms   1.12x constant packed_float4* random+
 25.85ms   4.61x texture_buffer<R8> uniform
146.98ms   0.81x texture_buffer<R8> linear
127.44ms   0.93x texture_buffer<R8> random
150.12ms   0.79x texture_buffer<R8> random+
 27.74ms   4.29x texture_buffer<RG8> uniform
145.76ms   0.82x texture_buffer<RG8> linear
124.40ms   0.96x texture_buffer<RG8> random
142.49ms   0.84x texture_buffer<RG8> random+
 25.86ms   4.60x texture_buffer<RGBA8> uniform
137.27ms   0.87x texture_buffer<RGBA8> linear
117.15ms   1.02x texture_buffer<RGBA8> random
138.46ms   0.86x texture_buffer<RGBA8> random+
 27.61ms   4.31x texture_buffer<R16> uniform
146.36ms   0.81x texture_buffer<R16> linear
124.23ms   0.96x texture_buffer<R16> random
143.35ms   0.83x texture_buffer<R16> random+
 25.86ms   4.60x texture_buffer<RG16> uniform
137.68ms   0.86x texture_buffer<RG16> linear
119.11ms   1.00x texture_buffer<RG16> random
135.94ms   0.88x texture_buffer<RG16> random+
 25.90ms   4.60x texture_buffer<RGBA16> uniform
128.94ms   0.92x texture_buffer<RGBA16> linear
107.26ms   1.11x texture_buffer<RGBA16> random
125.87ms   0.95x texture_buffer<RGBA16> random+
 27.27ms   4.37x texture_buffer<R32> uniform
137.77ms   0.86x texture_buffer<R32> linear
119.07ms   1.00x texture_buffer<R32> random
136.09ms   0.87x texture_buffer<R32> random+
 25.87ms   4.60x texture_buffer<RG32> uniform
125.27ms   0.95x texture_buffer<RG32> linear
108.54ms   1.10x texture_buffer<RG32> random
127.43ms   0.93x texture_buffer<RG32> random+
 53.93ms   2.21x texture_buffer<RGBA32> uniform
101.07ms   1.18x texture_buffer<RGBA32> linear
 86.23ms   1.38x texture_buffer<RGBA32> random
 99.17ms   1.20x texture_buffer<RGBA32> random+
 12.92ms   9.21x texture2d<R8> uniform
 12.93ms   9.21x texture2d<R8> linear
 12.92ms   9.22x texture2d<R8> random
 12.93ms   9.21x texture2d<R8> random+
 12.93ms   9.21x texture2d<RG8> uniform
 12.93ms   9.21x texture2d<RG8> linear
 12.90ms   9.23x texture2d<RG8> random
 12.94ms   9.20x texture2d<RG8> random+
 12.94ms   9.20x texture2d<RGBA8> uniform
 12.94ms   9.20x texture2d<RGBA8> linear
 12.95ms   9.19x texture2d<RGBA8> random
 12.95ms   9.20x texture2d<RGBA8> random+
 12.93ms   9.21x texture2d<R16> uniform
 12.93ms   9.21x texture2d<R16> linear
 12.94ms   9.21x texture2d<R16> random
 12.94ms   9.20x texture2d<R16> random+
 12.93ms   9.21x texture2d<RG16> uniform
 12.93ms   9.21x texture2d<RG16> linear
 12.95ms   9.20x texture2d<RG16> random
 12.93ms   9.21x texture2d<RG16> random+
 12.95ms   9.19x texture2d<RGBA16> uniform
 14.82ms   8.03x texture2d<RGBA16> linear
 12.94ms   9.20x texture2d<RGBA16> random
 16.20ms   7.35x texture2d<RGBA16> random+
 12.93ms   9.21x texture2d<R32> uniform
 12.94ms   9.20x texture2d<R32> linear
 12.95ms   9.20x texture2d<R32> random
 12.93ms   9.21x texture2d<R32> random+
 25.86ms   4.61x texture2d<RG32> uniform
 25.86ms   4.60x texture2d<RG32> linear
 25.87ms   4.60x texture2d<RG32> random
 32.36ms   3.68x texture2d<RG32> random+
 51.78ms   2.30x texture2d<RGBA32> uniform
 51.79ms   2.30x texture2d<RGBA32> linear
 51.80ms   2.30x texture2d<RGBA32> random
 52.52ms   2.27x texture2d<RGBA32> random+
 13.66ms   8.71x texture2d<R8>.sample(nearest) uniform
 13.46ms   8.85x texture2d<R8>.sample(nearest) linear
 13.18ms   9.03x texture2d<R8>.sample(nearest) random
 13.20ms   9.02x texture2d<R8>.sample(nearest) random+
 13.54ms   8.79x texture2d<RG8>.sample(nearest) uniform
 13.89ms   8.58x texture2d<RG8>.sample(nearest) linear
 14.07ms   8.46x texture2d<RG8>.sample(nearest) random
 14.21ms   8.38x texture2d<RG8>.sample(nearest) random+
 15.81ms   7.53x texture2d<RGBA8>.sample(nearest) uniform
 14.49ms   8.22x texture2d<RGBA8>.sample(nearest) linear
 14.17ms   8.41x texture2d<RGBA8>.sample(nearest) random
 14.33ms   8.31x texture2d<RGBA8>.sample(nearest) random+
 13.67ms   8.71x texture2d<R16>.sample(nearest) uniform
 13.40ms   8.89x texture2d<R16>.sample(nearest) linear
 13.16ms   9.05x texture2d<R16>.sample(nearest) random
 13.18ms   9.03x texture2d<R16>.sample(nearest) random+
 13.54ms   8.80x texture2d<RG16>.sample(nearest) uniform
 13.87ms   8.58x texture2d<RG16>.sample(nearest) linear
 14.07ms   8.47x texture2d<RG16>.sample(nearest) random
 14.20ms   8.39x texture2d<RG16>.sample(nearest) random+
 15.81ms   7.53x texture2d<RGBA16>.sample(nearest) uniform
 15.85ms   7.51x texture2d<RGBA16>.sample(nearest) linear
 14.34ms   8.30x texture2d<RGBA16>.sample(nearest) random
 16.42ms   7.25x texture2d<RGBA16>.sample(nearest) random+
 13.65ms   8.72x texture2d<R32>.sample(nearest) uniform
 13.39ms   8.89x texture2d<R32>.sample(nearest) linear
 13.17ms   9.04x texture2d<R32>.sample(nearest) random
 13.19ms   9.03x texture2d<R32>.sample(nearest) random+
 25.89ms   4.60x texture2d<RG32>.sample(nearest) uniform
 26.08ms   4.56x texture2d<RG32>.sample(nearest) linear
 26.02ms   4.58x texture2d<RG32>.sample(nearest) random
 32.40ms   3.67x texture2d<RG32>.sample(nearest) random+
 51.73ms   2.30x texture2d<RGBA32>.sample(nearest) uniform
 51.77ms   2.30x texture2d<RGBA32>.sample(nearest) linear
 51.78ms   2.30x texture2d<RGBA32>.sample(nearest) random
 51.88ms   2.30x texture2d<RGBA32>.sample(nearest) random+
 13.74ms   8.66x texture2d<R8>.sample(bilinear) uniform
 13.45ms   8.85x texture2d<R8>.sample(bilinear) linear
 13.16ms   9.05x texture2d<R8>.sample(bilinear) random
 13.17ms   9.04x texture2d<R8>.sample(bilinear) random+
 13.56ms   8.78x texture2d<RG8>.sample(bilinear) uniform
 13.91ms   8.56x texture2d<RG8>.sample(bilinear) linear
 14.07ms   8.46x texture2d<RG8>.sample(bilinear) random
 14.20ms   8.39x texture2d<RG8>.sample(bilinear) random+
 15.81ms   7.53x texture2d<RGBA8>.sample(bilinear) uniform
 14.51ms   8.20x texture2d<RGBA8>.sample(bilinear) linear
 14.17ms   8.41x texture2d<RGBA8>.sample(bilinear) random
 14.34ms   8.30x texture2d<RGBA8>.sample(bilinear) random+
 13.68ms   8.70x texture2d<R16>.sample(bilinear) uniform
 13.41ms   8.88x texture2d<R16>.sample(bilinear) linear
 13.19ms   9.03x texture2d<R16>.sample(bilinear) random
 13.21ms   9.01x texture2d<R16>.sample(bilinear) random+
 13.54ms   8.80x texture2d<RG16>.sample(bilinear) uniform
 13.90ms   8.57x texture2d<RG16>.sample(bilinear) linear
 14.07ms   8.46x texture2d<RG16>.sample(bilinear) random
 14.22ms   8.38x texture2d<RG16>.sample(bilinear) random+
 15.81ms   7.53x texture2d<RGBA16>.sample(bilinear) uniform
 15.85ms   7.51x texture2d<RGBA16>.sample(bilinear) linear
 14.35ms   8.30x texture2d<RGBA16>.sample(bilinear) random
 16.46ms   7.23x texture2d<RGBA16>.sample(bilinear) random+
 13.67ms   8.71x texture2d<R32>.sample(bilinear) uniform
 13.40ms   8.89x texture2d<R32>.sample(bilinear) linear
 13.18ms   9.04x texture2d<R32>.sample(bilinear) random
 13.16ms   9.05x texture2d<R32>.sample(bilinear) random+
 25.92ms   4.59x texture2d<RG32>.sample(bilinear) uniform
 26.05ms   4.57x texture2d<RG32>.sample(bilinear) linear
 26.06ms   4.57x texture2d<RG32>.sample(bilinear) random
 32.42ms   3.67x texture2d<RG32>.sample(bilinear) random+
 51.74ms   2.30x texture2d<RGBA32>.sample(bilinear) uniform
 51.78ms   2.30x texture2d<RGBA32>.sample(bilinear) linear
 51.77ms   2.30x texture2d<RGBA32>.sample(bilinear) random
 51.87ms   2.30x texture2d<RGBA32>.sample(bilinear) random+
 25.86ms   4.60x texture_buffer<R8H> uniform
146.26ms   0.81x texture_buffer<R8H> linear
124.37ms   0.96x texture_buffer<R8H> random
145.19ms   0.82x texture_buffer<R8H> random+
 29.65ms   4.02x texture_buffer<RG8H> uniform
145.90ms   0.82x texture_buffer<RG8H> linear
120.91ms   0.98x texture_buffer<RG8H> random
143.74ms   0.83x texture_buffer<RG8H> random+
 25.85ms   4.61x texture_buffer<RGBA8H> uniform
137.01ms   0.87x texture_buffer<RGBA8H> linear
116.20ms   1.02x texture_buffer<RGBA8H> random
136.03ms   0.88x texture_buffer<RGBA8H> random+
 25.85ms   4.61x texture_buffer<R16H> uniform
147.75ms   0.81x texture_buffer<R16H> linear
121.90ms   0.98x texture_buffer<R16H> random
144.40ms   0.82x texture_buffer<R16H> random+
 26.69ms   4.46x texture_buffer<RG16H> uniform
137.60ms   0.87x texture_buffer<RG16H> linear
116.38ms   1.02x texture_buffer<RG16H> random
136.08ms   0.88x texture_buffer<RG16H> random+
 25.87ms   4.60x texture_buffer<RGBA16H> uniform
124.46ms   0.96x texture_buffer<RGBA16H> linear
104.91ms   1.14x texture_buffer<RGBA16H> random
127.39ms   0.93x texture_buffer<RGBA16H> random+
 28.31ms   4.21x texture_buffer<R32H> uniform
138.90ms   0.86x texture_buffer<R32H> linear
116.81ms   1.02x texture_buffer<R32H> random
135.98ms   0.88x texture_buffer<R32H> random+
 25.86ms   4.60x texture_buffer<RG32H> uniform
125.15ms   0.95x texture_buffer<RG32H> linear
107.00ms   1.11x texture_buffer<RG32H> random
123.99ms   0.96x texture_buffer<RG32H> random+
 53.87ms   2.21x texture_buffer<RGBA32H> uniform
102.06ms   1.17x texture_buffer<RGBA32H> linear
 85.63ms   1.39x texture_buffer<RGBA32H> random
 99.02ms   1.20x texture_buffer<RGBA32H> random+
 13.51ms   8.81x texture2d<R8H> uniform
 12.94ms   9.20x texture2d<R8H> linear
 12.93ms   9.21x texture2d<R8H> random
 12.94ms   9.21x texture2d<R8H> random+
 12.93ms   9.21x texture2d<RG8H> uniform
 12.93ms   9.21x texture2d<RG8H> linear
 12.90ms   9.23x texture2d<RG8H> random
 12.94ms   9.20x texture2d<RG8H> random+
 12.94ms   9.20x texture2d<RGBA8H> uniform
 12.95ms   9.19x texture2d<RGBA8H> linear
 12.93ms   9.21x texture2d<RGBA8H> random
 12.93ms   9.21x texture2d<RGBA8H> random+
 12.95ms   9.20x texture2d<R16H> uniform
 12.93ms   9.21x texture2d<R16H> linear
 12.92ms   9.21x texture2d<R16H> random
 12.93ms   9.21x texture2d<R16H> random+
 12.93ms   9.21x texture2d<RG16H> uniform
 12.93ms   9.21x texture2d<RG16H> linear
 12.93ms   9.21x texture2d<RG16H> random
 12.92ms   9.21x texture2d<RG16H> random+
 12.95ms   9.19x texture2d<RGBA16H> uniform
 14.77ms   8.06x texture2d<RGBA16H> linear
 12.92ms   9.21x texture2d<RGBA16H> random
 16.17ms   7.36x texture2d<RGBA16H> random+
 12.93ms   9.21x texture2d<R32H> uniform
 12.94ms   9.20x texture2d<R32H> linear
 12.92ms   9.22x texture2d<R32H> random
 12.93ms   9.21x texture2d<R32H> random+
 25.85ms   4.61x texture2d<RG32H> uniform
 25.86ms   4.60x texture2d<RG32H> linear
 25.85ms   4.61x texture2d<RG32H> random
 32.33ms   3.68x texture2d<RG32H> random+
 51.75ms   2.30x texture2d<RGBA32H> uniform
 51.75ms   2.30x texture2d<RGBA32H> linear
 51.76ms   2.30x texture2d<RGBA32H> random
 51.94ms   2.29x texture2d<RGBA32H> random+
 13.15ms   9.06x texture2d<R8H>.sample(nearest) uniform
 14.28ms   8.34x texture2d<R8H>.sample(nearest) linear
 13.18ms   9.04x texture2d<R8H>.sample(nearest) random
 13.17ms   9.04x texture2d<R8H>.sample(nearest) random+
 13.12ms   9.08x texture2d<RG8H>.sample(nearest) uniform
 13.88ms   8.58x texture2d<RG8H>.sample(nearest) linear
 14.08ms   8.46x texture2d<RG8H>.sample(nearest) random
 14.22ms   8.38x texture2d<RG8H>.sample(nearest) random+
 13.34ms   8.92x texture2d<RGBA8H>.sample(nearest) uniform
 14.50ms   8.21x texture2d<RGBA8H>.sample(nearest) linear
 14.15ms   8.41x texture2d<RGBA8H>.sample(nearest) random
 14.35ms   8.30x texture2d<RGBA8H>.sample(nearest) random+
 13.10ms   9.09x texture2d<R16H>.sample(nearest) uniform
 13.41ms   8.88x texture2d<R16H>.sample(nearest) linear
 13.21ms   9.02x texture2d<R16H>.sample(nearest) random
 13.17ms   9.04x texture2d<R16H>.sample(nearest) random+
 13.12ms   9.07x texture2d<RG16H>.sample(nearest) uniform
 13.88ms   8.58x texture2d<RG16H>.sample(nearest) linear
 14.07ms   8.46x texture2d<RG16H>.sample(nearest) random
 14.21ms   8.38x texture2d<RG16H>.sample(nearest) random+
 13.37ms   8.91x texture2d<RGBA16H>.sample(nearest) uniform
 15.86ms   7.51x texture2d<RGBA16H>.sample(nearest) linear
 14.35ms   8.30x texture2d<RGBA16H>.sample(nearest) random
 16.43ms   7.25x texture2d<RGBA16H>.sample(nearest) random+
 13.08ms   9.10x texture2d<R32H>.sample(nearest) uniform
 13.42ms   8.88x texture2d<R32H>.sample(nearest) linear
 13.18ms   9.04x texture2d<R32H>.sample(nearest) random
 13.17ms   9.04x texture2d<R32H>.sample(nearest) random+
 25.87ms   4.60x texture2d<RG32H>.sample(nearest) uniform
 26.07ms   4.57x texture2d<RG32H>.sample(nearest) linear
 26.01ms   4.58x texture2d<RG32H>.sample(nearest) random
 32.43ms   3.67x texture2d<RG32H>.sample(nearest) random+
 51.74ms   2.30x texture2d<RGBA32H>.sample(nearest) uniform
 51.80ms   2.30x texture2d<RGBA32H>.sample(nearest) linear
 51.77ms   2.30x texture2d<RGBA32H>.sample(nearest) random
 51.86ms   2.30x texture2d<RGBA32H>.sample(nearest) random+
 13.06ms   9.12x texture2d<R8H>.sample(bilinear) uniform
 13.42ms   8.87x texture2d<R8H>.sample(bilinear) linear
 13.18ms   9.04x texture2d<R8H>.sample(bilinear) random
 13.17ms   9.04x texture2d<R8H>.sample(bilinear) random+
 13.12ms   9.08x texture2d<RG8H>.sample(bilinear) uniform
 13.87ms   8.58x texture2d<RG8H>.sample(bilinear) linear
 14.07ms   8.46x texture2d<RG8H>.sample(bilinear) random
 14.20ms   8.39x texture2d<RG8H>.sample(bilinear) random+
 13.36ms   8.91x texture2d<RGBA8H>.sample(bilinear) uniform
 14.52ms   8.20x texture2d<RGBA8H>.sample(bilinear) linear
 14.18ms   8.40x texture2d<RGBA8H>.sample(bilinear) random
 14.34ms   8.30x texture2d<RGBA8H>.sample(bilinear) random+
 13.08ms   9.10x texture2d<R16H>.sample(bilinear) uniform
 13.42ms   8.87x texture2d<R16H>.sample(bilinear) linear
 13.16ms   9.05x texture2d<R16H>.sample(bilinear) random
 13.20ms   9.02x texture2d<R16H>.sample(bilinear) random+
 13.11ms   9.08x texture2d<RG16H>.sample(bilinear) uniform
 13.90ms   8.57x texture2d<RG16H>.sample(bilinear) linear
 14.06ms   8.47x texture2d<RG16H>.sample(bilinear) random
 14.21ms   8.38x texture2d<RG16H>.sample(bilinear) random+
 13.35ms   8.92x texture2d<RGBA16H>.sample(bilinear) uniform
 15.85ms   7.51x texture2d<RGBA16H>.sample(bilinear) linear
 14.36ms   8.29x texture2d<RGBA16H>.sample(bilinear) random
 16.44ms   7.24x texture2d<RGBA16H>.sample(bilinear) random+
 13.08ms   9.10x texture2d<R32H>.sample(bilinear) uniform
 13.41ms   8.88x texture2d<R32H>.sample(bilinear) linear
 13.17ms   9.04x texture2d<R32H>.sample(bilinear) random
 13.20ms   9.02x texture2d<R32H>.sample(bilinear) random+
 25.92ms   4.59x texture2d<RG32H>.sample(bilinear) uniform
 26.08ms   4.57x texture2d<RG32H>.sample(bilinear) linear
 26.06ms   4.57x texture2d<RG32H>.sample(bilinear) random
 32.46ms   3.67x texture2d<RG32H>.sample(bilinear) random+
 51.76ms   2.30x texture2d<RGBA32H>.sample(bilinear) uniform
 51.79ms   2.30x texture2d<RGBA32H>.sample(bilinear) linear
 51.78ms   2.30x texture2d<RGBA32H>.sample(bilinear) random
 51.88ms   2.30x texture2d<RGBA32H>.sample(bilinear) random+
```

Half rate RG32, quarter rate RGBA32, regardless of whether you're reading or sampling with nearest or bilinear.

For some reason, texture buffers are 9x slower than everything else.
</details>

<details>
<summary>Intel Gen9 (UHD 630 / i9-9980HK)</summary>

```
  2.64ms  21.00x cbuffer{float4} uniform
 34.74ms   1.59x cbuffer{float4} linear
 68.96ms   0.80x cbuffer{float4} random
 80.33ms   0.69x cbuffer{float4} random+
  2.82ms  19.65x device const rgba8unorm<float4>* uniform
 27.71ms   2.00x device const rgba8unorm<float4>* linear
 27.29ms   2.03x device const rgba8unorm<float4>* random
 27.27ms   2.03x device const rgba8unorm<float4>* random+
  2.81ms  19.70x device const rgba8unorm<half4>* uniform
 33.92ms   1.63x device const rgba8unorm<half4>* linear
 33.46ms   1.66x device const rgba8unorm<half4>* random
 33.48ms   1.65x device const rgba8unorm<half4>* random+
  2.68ms  20.69x device const half2* uniform
 14.25ms   3.89x device const half2* linear
 14.20ms   3.90x device const half2* random
 22.75ms   2.44x device const half2* random+
  3.22ms  17.19x device const half4* uniform
 18.94ms   2.93x device const half4* linear
 29.84ms   1.86x device const half4* random
 55.39ms   1.00x device const half4* random+
  2.68ms  20.68x device const float1* uniform
 11.30ms   4.90x device const float1* linear
 11.11ms   4.99x device const float1* random
 22.11ms   2.51x device const float1* random+
  2.77ms  20.01x device const float2* uniform
 18.38ms   3.01x device const float2* linear
 28.39ms   1.95x device const float2* random
 54.10ms   1.02x device const float2* random+
  2.64ms  21.02x device const float4* uniform
 34.36ms   1.61x device const float4* linear
 68.16ms   0.81x device const float4* random
 79.89ms   0.69x device const float4* random+
  2.68ms  20.63x device const packed_float2* uniform
 18.38ms   3.01x device const packed_float2* linear
 28.47ms   1.95x device const packed_float2* random
 54.16ms   1.02x device const packed_float2* random+
  3.02ms  18.37x device const packed_float3* uniform
 33.19ms   1.67x device const packed_float3* linear
 63.10ms   0.88x device const packed_float3* random
 89.22ms   0.62x device const packed_float3* random+
  2.64ms  21.02x device const packed_float4* uniform
 33.89ms   1.63x device const packed_float4* linear
 67.07ms   0.83x device const packed_float4* random
 79.06ms   0.70x device const packed_float4* random+
  2.94ms  18.82x device const unaligned packed_float2* uniform
 19.63ms   2.82x device const unaligned packed_float2* linear
 29.58ms   1.87x device const unaligned packed_float2* random
 60.26ms   0.92x device const unaligned packed_float2* random+
  3.18ms  17.43x device const unaligned packed_float4* uniform
 38.69ms   1.43x device const unaligned packed_float4* linear
 74.36ms   0.75x device const unaligned packed_float4* random
 98.44ms   0.56x device const unaligned packed_float4* random+
  2.70ms  20.50x constant float1* uniform
 11.35ms   4.88x constant float1* linear
 11.37ms   4.87x constant float1* random
 22.50ms   2.46x constant float1* random+
  4.74ms  11.69x constant float2* uniform
 18.51ms   2.99x constant float2* linear
 28.89ms   1.92x constant float2* random
 54.89ms   1.01x constant float2* random+
  2.64ms  21.00x constant float4* uniform
 34.30ms   1.62x constant float4* linear
 68.15ms   0.81x constant float4* random
 79.96ms   0.69x constant float4* random+
  2.69ms  20.62x constant packed_float2* uniform
 18.49ms   3.00x constant packed_float2* linear
 28.90ms   1.92x constant packed_float2* random
 54.77ms   1.01x constant packed_float2* random+
  3.07ms  18.06x constant packed_float3* uniform
 33.19ms   1.67x constant packed_float3* linear
 63.06ms   0.88x constant packed_float3* random
 89.34ms   0.62x constant packed_float3* random+
  2.64ms  21.00x constant packed_float4* uniform
 33.90ms   1.63x constant packed_float4* linear
 67.07ms   0.83x constant packed_float4* random
 78.99ms   0.70x constant packed_float4* random+
  9.43ms   5.87x texture_buffer<R8> uniform
 46.78ms   1.18x texture_buffer<R8> linear
 55.43ms   1.00x texture_buffer<R8> random
 51.94ms   1.07x texture_buffer<R8> random+
  9.43ms   5.88x texture_buffer<RG8> uniform
 46.80ms   1.18x texture_buffer<RG8> linear
 55.41ms   1.00x texture_buffer<RG8> random
 52.01ms   1.07x texture_buffer<RG8> random+
  9.42ms   5.88x texture_buffer<RGBA8> uniform
 46.83ms   1.18x texture_buffer<RGBA8> linear
 55.43ms   1.00x texture_buffer<RGBA8> random
 52.00ms   1.07x texture_buffer<RGBA8> random+
  9.44ms   5.87x texture_buffer<R16> uniform
 46.82ms   1.18x texture_buffer<R16> linear
 55.41ms   1.00x texture_buffer<R16> random
 52.00ms   1.07x texture_buffer<R16> random+
  9.41ms   5.88x texture_buffer<RG16> uniform
 46.81ms   1.18x texture_buffer<RG16> linear
 55.45ms   1.00x texture_buffer<RG16> random
 52.01ms   1.07x texture_buffer<RG16> random+
  9.45ms   5.86x texture_buffer<RGBA16> uniform
 46.87ms   1.18x texture_buffer<RGBA16> linear
 55.37ms   1.00x texture_buffer<RGBA16> random
 51.96ms   1.07x texture_buffer<RGBA16> random+
  9.43ms   5.88x texture_buffer<R32> uniform
 46.83ms   1.18x texture_buffer<R32> linear
 55.40ms   1.00x texture_buffer<R32> random
 52.04ms   1.06x texture_buffer<R32> random+
  9.43ms   5.88x texture_buffer<RG32> uniform
 46.83ms   1.18x texture_buffer<RG32> linear
 55.43ms   1.00x texture_buffer<RG32> random
 51.99ms   1.07x texture_buffer<RG32> random+
  9.44ms   5.87x texture_buffer<RGBA32> uniform
 46.78ms   1.18x texture_buffer<RGBA32> linear
 55.41ms   1.00x texture_buffer<RGBA32> random
 51.93ms   1.07x texture_buffer<RGBA32> random+
  4.72ms  11.74x texture2d<R8> uniform
 18.85ms   2.94x texture2d<R8> linear
 18.86ms   2.94x texture2d<R8> random
 18.84ms   2.94x texture2d<R8> random+
  4.73ms  11.71x texture2d<RG8> uniform
 18.85ms   2.94x texture2d<RG8> linear
 18.84ms   2.94x texture2d<RG8> random
 18.86ms   2.94x texture2d<RG8> random+
  4.72ms  11.73x texture2d<RGBA8> uniform
 19.30ms   2.87x texture2d<RGBA8> linear
 19.22ms   2.88x texture2d<RGBA8> random
 19.21ms   2.88x texture2d<RGBA8> random+
  4.74ms  11.70x texture2d<R16> uniform
 18.84ms   2.94x texture2d<R16> linear
 18.86ms   2.94x texture2d<R16> random
 18.84ms   2.94x texture2d<R16> random+
  4.74ms  11.69x texture2d<RG16> uniform
 18.84ms   2.94x texture2d<RG16> linear
 18.84ms   2.94x texture2d<RG16> random
 18.85ms   2.94x texture2d<RG16> random+
  4.73ms  11.72x texture2d<RGBA16> uniform
 19.29ms   2.87x texture2d<RGBA16> linear
 19.26ms   2.88x texture2d<RGBA16> random
 25.93ms   2.14x texture2d<RGBA16> random+
  4.73ms  11.71x texture2d<R32> uniform
 18.85ms   2.94x texture2d<R32> linear
 18.85ms   2.94x texture2d<R32> random
 18.85ms   2.94x texture2d<R32> random+
  4.73ms  11.71x texture2d<RG32> uniform
 18.84ms   2.94x texture2d<RG32> linear
 18.84ms   2.94x texture2d<RG32> random
 25.90ms   2.14x texture2d<RG32> random+
  4.72ms  11.73x texture2d<RGBA32> uniform
 47.11ms   1.18x texture2d<RGBA32> linear
 47.10ms   1.18x texture2d<RGBA32> random
 65.99ms   0.84x texture2d<RGBA32> random+
 18.85ms   2.94x texture2d<R8>.sample(nearest) uniform
 18.85ms   2.94x texture2d<R8>.sample(nearest) linear
 18.85ms   2.94x texture2d<R8>.sample(nearest) random
 18.84ms   2.94x texture2d<R8>.sample(nearest) random+
 18.87ms   2.94x texture2d<RG8>.sample(nearest) uniform
 18.84ms   2.94x texture2d<RG8>.sample(nearest) linear
 18.85ms   2.94x texture2d<RG8>.sample(nearest) random
 18.85ms   2.94x texture2d<RG8>.sample(nearest) random+
 19.08ms   2.90x texture2d<RGBA8>.sample(nearest) uniform
 19.49ms   2.84x texture2d<RGBA8>.sample(nearest) linear
 19.09ms   2.90x texture2d<RGBA8>.sample(nearest) random
 19.10ms   2.90x texture2d<RGBA8>.sample(nearest) random+
 18.87ms   2.94x texture2d<R16>.sample(nearest) uniform
 18.84ms   2.94x texture2d<R16>.sample(nearest) linear
 18.84ms   2.94x texture2d<R16>.sample(nearest) random
 18.84ms   2.94x texture2d<R16>.sample(nearest) random+
 18.88ms   2.94x texture2d<RG16>.sample(nearest) uniform
 18.86ms   2.94x texture2d<RG16>.sample(nearest) linear
 18.87ms   2.94x texture2d<RG16>.sample(nearest) random
 18.84ms   2.94x texture2d<RG16>.sample(nearest) random+
 19.11ms   2.90x texture2d<RGBA16>.sample(nearest) uniform
 19.49ms   2.84x texture2d<RGBA16>.sample(nearest) linear
 19.07ms   2.91x texture2d<RGBA16>.sample(nearest) random
 25.93ms   2.14x texture2d<RGBA16>.sample(nearest) random+
 18.87ms   2.94x texture2d<R32>.sample(nearest) uniform
 18.84ms   2.94x texture2d<R32>.sample(nearest) linear
 18.86ms   2.94x texture2d<R32>.sample(nearest) random
 18.84ms   2.94x texture2d<R32>.sample(nearest) random+
 18.86ms   2.94x texture2d<RG32>.sample(nearest) uniform
 18.84ms   2.94x texture2d<RG32>.sample(nearest) linear
 18.87ms   2.94x texture2d<RG32>.sample(nearest) random
 25.93ms   2.14x texture2d<RG32>.sample(nearest) random+
 19.10ms   2.90x texture2d<RGBA32>.sample(nearest) uniform
 47.14ms   1.18x texture2d<RGBA32>.sample(nearest) linear
 47.13ms   1.18x texture2d<RGBA32>.sample(nearest) random
 66.14ms   0.84x texture2d<RGBA32>.sample(nearest) random+
 18.85ms   2.94x texture2d<R8>.sample(bilinear) uniform
 18.86ms   2.94x texture2d<R8>.sample(bilinear) linear
 18.85ms   2.94x texture2d<R8>.sample(bilinear) random
 18.86ms   2.94x texture2d<R8>.sample(bilinear) random+
 18.85ms   2.94x texture2d<RG8>.sample(bilinear) uniform
 18.84ms   2.94x texture2d<RG8>.sample(bilinear) linear
 18.83ms   2.94x texture2d<RG8>.sample(bilinear) random
 18.84ms   2.94x texture2d<RG8>.sample(bilinear) random+
 19.13ms   2.90x texture2d<RGBA8>.sample(bilinear) uniform
 19.51ms   2.84x texture2d<RGBA8>.sample(bilinear) linear
 19.11ms   2.90x texture2d<RGBA8>.sample(bilinear) random
 19.10ms   2.90x texture2d<RGBA8>.sample(bilinear) random+
 18.83ms   2.94x texture2d<R16>.sample(bilinear) uniform
 18.84ms   2.94x texture2d<R16>.sample(bilinear) linear
 18.83ms   2.94x texture2d<R16>.sample(bilinear) random
 18.86ms   2.94x texture2d<R16>.sample(bilinear) random+
 18.85ms   2.94x texture2d<RG16>.sample(bilinear) uniform
 18.87ms   2.94x texture2d<RG16>.sample(bilinear) linear
 18.85ms   2.94x texture2d<RG16>.sample(bilinear) random
 18.83ms   2.94x texture2d<RG16>.sample(bilinear) random+
 19.08ms   2.90x texture2d<RGBA16>.sample(bilinear) uniform
 19.49ms   2.84x texture2d<RGBA16>.sample(bilinear) linear
 19.07ms   2.91x texture2d<RGBA16>.sample(bilinear) random
 25.91ms   2.14x texture2d<RGBA16>.sample(bilinear) random+
 18.85ms   2.94x texture2d<R32>.sample(bilinear) uniform
 18.85ms   2.94x texture2d<R32>.sample(bilinear) linear
 18.85ms   2.94x texture2d<R32>.sample(bilinear) random
 18.88ms   2.93x texture2d<R32>.sample(bilinear) random+
 37.69ms   1.47x texture2d<RG32>.sample(bilinear) uniform
 37.69ms   1.47x texture2d<RG32>.sample(bilinear) linear
 37.71ms   1.47x texture2d<RG32>.sample(bilinear) random
 40.04ms   1.38x texture2d<RG32>.sample(bilinear) random+
 75.34ms   0.74x texture2d<RGBA32>.sample(bilinear) uniform
 75.93ms   0.73x texture2d<RGBA32>.sample(bilinear) linear
 75.57ms   0.73x texture2d<RGBA32>.sample(bilinear) random
 75.59ms   0.73x texture2d<RGBA32>.sample(bilinear) random+
  9.43ms   5.87x texture_buffer<R8H> uniform
 46.83ms   1.18x texture_buffer<R8H> linear
 55.40ms   1.00x texture_buffer<R8H> random
 51.98ms   1.07x texture_buffer<R8H> random+
  9.43ms   5.88x texture_buffer<RG8H> uniform
 46.82ms   1.18x texture_buffer<RG8H> linear
 55.47ms   1.00x texture_buffer<RG8H> random
 52.00ms   1.07x texture_buffer<RG8H> random+
  9.43ms   5.87x texture_buffer<RGBA8H> uniform
 46.81ms   1.18x texture_buffer<RGBA8H> linear
 55.42ms   1.00x texture_buffer<RGBA8H> random
 51.99ms   1.07x texture_buffer<RGBA8H> random+
  9.42ms   5.88x texture_buffer<R16H> uniform
 46.80ms   1.18x texture_buffer<R16H> linear
 55.42ms   1.00x texture_buffer<R16H> random
 51.96ms   1.07x texture_buffer<R16H> random+
  9.43ms   5.87x texture_buffer<RG16H> uniform
 46.80ms   1.18x texture_buffer<RG16H> linear
 55.40ms   1.00x texture_buffer<RG16H> random
 51.98ms   1.07x texture_buffer<RG16H> random+
  9.44ms   5.87x texture_buffer<RGBA16H> uniform
 46.81ms   1.18x texture_buffer<RGBA16H> linear
 55.40ms   1.00x texture_buffer<RGBA16H> random
 51.96ms   1.07x texture_buffer<RGBA16H> random+
  9.44ms   5.87x texture_buffer<R32H> uniform
 46.80ms   1.18x texture_buffer<R32H> linear
 55.36ms   1.00x texture_buffer<R32H> random
 51.95ms   1.07x texture_buffer<R32H> random+
  9.45ms   5.86x texture_buffer<RG32H> uniform
 46.78ms   1.18x texture_buffer<RG32H> linear
 55.37ms   1.00x texture_buffer<RG32H> random
 51.98ms   1.07x texture_buffer<RG32H> random+
  9.44ms   5.87x texture_buffer<RGBA32H> uniform
 46.82ms   1.18x texture_buffer<RGBA32H> linear
 55.40ms   1.00x texture_buffer<RGBA32H> random
 51.96ms   1.07x texture_buffer<RGBA32H> random+
  4.72ms  11.73x texture2d<R8H> uniform
 18.85ms   2.94x texture2d<R8H> linear
 18.84ms   2.94x texture2d<R8H> random
 18.88ms   2.93x texture2d<R8H> random+
  4.75ms  11.65x texture2d<RG8H> uniform
 18.86ms   2.94x texture2d<RG8H> linear
 18.85ms   2.94x texture2d<RG8H> random
 18.85ms   2.94x texture2d<RG8H> random+
  4.75ms  11.66x texture2d<RGBA8H> uniform
 18.85ms   2.94x texture2d<RGBA8H> linear
 18.86ms   2.94x texture2d<RGBA8H> random
 18.88ms   2.93x texture2d<RGBA8H> random+
  4.72ms  11.73x texture2d<R16H> uniform
 18.86ms   2.94x texture2d<R16H> linear
 18.84ms   2.94x texture2d<R16H> random
 18.87ms   2.94x texture2d<R16H> random+
  4.74ms  11.69x texture2d<RG16H> uniform
 18.83ms   2.94x texture2d<RG16H> linear
 18.84ms   2.94x texture2d<RG16H> random
 18.84ms   2.94x texture2d<RG16H> random+
  4.76ms  11.65x texture2d<RGBA16H> uniform
 18.84ms   2.94x texture2d<RGBA16H> linear
 18.85ms   2.94x texture2d<RGBA16H> random
 25.90ms   2.14x texture2d<RGBA16H> random+
  4.73ms  11.71x texture2d<R32H> uniform
 18.85ms   2.94x texture2d<R32H> linear
 18.85ms   2.94x texture2d<R32H> random
 18.87ms   2.94x texture2d<R32H> random+
  4.74ms  11.70x texture2d<RG32H> uniform
 18.85ms   2.94x texture2d<RG32H> linear
 18.85ms   2.94x texture2d<RG32H> random
 25.87ms   2.14x texture2d<RG32H> random+
  4.75ms  11.66x texture2d<RGBA32H> uniform
 47.16ms   1.17x texture2d<RGBA32H> linear
 47.09ms   1.18x texture2d<RGBA32H> random
 65.94ms   0.84x texture2d<RGBA32H> random+
 18.84ms   2.94x texture2d<R8H>.sample(nearest) uniform
 18.84ms   2.94x texture2d<R8H>.sample(nearest) linear
 18.86ms   2.94x texture2d<R8H>.sample(nearest) random
 18.85ms   2.94x texture2d<R8H>.sample(nearest) random+
 18.86ms   2.94x texture2d<RG8H>.sample(nearest) uniform
 18.87ms   2.94x texture2d<RG8H>.sample(nearest) linear
 18.87ms   2.94x texture2d<RG8H>.sample(nearest) random
 18.86ms   2.94x texture2d<RG8H>.sample(nearest) random+
 18.89ms   2.93x texture2d<RGBA8H>.sample(nearest) uniform
 18.85ms   2.94x texture2d<RGBA8H>.sample(nearest) linear
 18.85ms   2.94x texture2d<RGBA8H>.sample(nearest) random
 18.84ms   2.94x texture2d<RGBA8H>.sample(nearest) random+
 18.84ms   2.94x texture2d<R16H>.sample(nearest) uniform
 18.83ms   2.94x texture2d<R16H>.sample(nearest) linear
 18.85ms   2.94x texture2d<R16H>.sample(nearest) random
 18.84ms   2.94x texture2d<R16H>.sample(nearest) random+
 18.85ms   2.94x texture2d<RG16H>.sample(nearest) uniform
 18.86ms   2.94x texture2d<RG16H>.sample(nearest) linear
 18.85ms   2.94x texture2d<RG16H>.sample(nearest) random
 18.85ms   2.94x texture2d<RG16H>.sample(nearest) random+
 18.88ms   2.93x texture2d<RGBA16H>.sample(nearest) uniform
 18.85ms   2.94x texture2d<RGBA16H>.sample(nearest) linear
 18.84ms   2.94x texture2d<RGBA16H>.sample(nearest) random
 25.92ms   2.14x texture2d<RGBA16H>.sample(nearest) random+
 18.85ms   2.94x texture2d<R32H>.sample(nearest) uniform
 18.87ms   2.94x texture2d<R32H>.sample(nearest) linear
 18.86ms   2.94x texture2d<R32H>.sample(nearest) random
 18.86ms   2.94x texture2d<R32H>.sample(nearest) random+
 18.87ms   2.94x texture2d<RG32H>.sample(nearest) uniform
 18.86ms   2.94x texture2d<RG32H>.sample(nearest) linear
 18.84ms   2.94x texture2d<RG32H>.sample(nearest) random
 25.90ms   2.14x texture2d<RG32H>.sample(nearest) random+
 18.88ms   2.93x texture2d<RGBA32H>.sample(nearest) uniform
 47.08ms   1.18x texture2d<RGBA32H>.sample(nearest) linear
 47.13ms   1.18x texture2d<RGBA32H>.sample(nearest) random
 65.96ms   0.84x texture2d<RGBA32H>.sample(nearest) random+
 18.84ms   2.94x texture2d<R8H>.sample(bilinear) uniform
 18.84ms   2.94x texture2d<R8H>.sample(bilinear) linear
 18.83ms   2.94x texture2d<R8H>.sample(bilinear) random
 18.84ms   2.94x texture2d<R8H>.sample(bilinear) random+
 18.87ms   2.94x texture2d<RG8H>.sample(bilinear) uniform
 18.84ms   2.94x texture2d<RG8H>.sample(bilinear) linear
 18.85ms   2.94x texture2d<RG8H>.sample(bilinear) random
 18.84ms   2.94x texture2d<RG8H>.sample(bilinear) random+
 18.86ms   2.94x texture2d<RGBA8H>.sample(bilinear) uniform
 18.85ms   2.94x texture2d<RGBA8H>.sample(bilinear) linear
 18.85ms   2.94x texture2d<RGBA8H>.sample(bilinear) random
 18.85ms   2.94x texture2d<RGBA8H>.sample(bilinear) random+
 18.83ms   2.94x texture2d<R16H>.sample(bilinear) uniform
 18.83ms   2.94x texture2d<R16H>.sample(bilinear) linear
 18.84ms   2.94x texture2d<R16H>.sample(bilinear) random
 18.84ms   2.94x texture2d<R16H>.sample(bilinear) random+
 18.85ms   2.94x texture2d<RG16H>.sample(bilinear) uniform
 18.86ms   2.94x texture2d<RG16H>.sample(bilinear) linear
 18.87ms   2.94x texture2d<RG16H>.sample(bilinear) random
 18.84ms   2.94x texture2d<RG16H>.sample(bilinear) random+
 18.87ms   2.94x texture2d<RGBA16H>.sample(bilinear) uniform
 18.86ms   2.94x texture2d<RGBA16H>.sample(bilinear) linear
 18.86ms   2.94x texture2d<RGBA16H>.sample(bilinear) random
 25.93ms   2.14x texture2d<RGBA16H>.sample(bilinear) random+
 18.85ms   2.94x texture2d<R32H>.sample(bilinear) uniform
 18.86ms   2.94x texture2d<R32H>.sample(bilinear) linear
 18.85ms   2.94x texture2d<R32H>.sample(bilinear) random
 18.85ms   2.94x texture2d<R32H>.sample(bilinear) random+
 37.73ms   1.47x texture2d<RG32H>.sample(bilinear) uniform
 37.69ms   1.47x texture2d<RG32H>.sample(bilinear) linear
 37.67ms   1.47x texture2d<RG32H>.sample(bilinear) random
 40.04ms   1.38x texture2d<RG32H>.sample(bilinear) random+
 75.36ms   0.74x texture2d<RGBA32H>.sample(bilinear) uniform
 75.42ms   0.73x texture2d<RGBA32H>.sample(bilinear) linear
 75.38ms   0.73x texture2d<RGBA32H>.sample(bilinear) random
 75.45ms   0.73x texture2d<RGBA32H>.sample(bilinear) random+
```

Matches DX11 very well, right down to the weird 3x better texture than texture buffer performance.
</details>
#include <metal_stdlib>
using namespace metal;

// Simple Weyl hash function
// Source: https://gist.github.com/Marc-B-Reynolds/5a939f71fc7237c7af63
uint hash2(uint2 c)
{
	c.x *= 0x3504f333;
	c.y *= 0xf1bbcdcb;
	c.x ^= c.y;
	c.x *= 741103597;
	return c.x;
}

// Modified from the above. Only single channel
uint hash1(uint c)
{
	c *= 0x3504f333;
	return c;
}

constexpr constant uint BUFFER_THREAD_GROUP_SIZE = 256;
constexpr constant uint TEXTURE_THREAD_GROUP_SIZE = 16;

enum class LoadType { Invariant, Linear, Random, RandomLarge };

struct LoadConstants {
	uint elementsMask; // Runtime address mask. Needed to prevent compiler combining narrow raw buffer loads from single thread.
	uint writeIndex;   // Runtime write mask. Always 0xffffffff (= never write). But the compiler doesn't know this :)
};

struct LoadConstantsWithArray {
	uint elementsMask; // Runtime address mask. Needed to prevent compiler combining narrow raw buffer loads from single thread.
	uint writeIndex;   // Runtime write mask. Always 0xffffffff (= never write). But the compiler doesn't know this :)
	float4 benchmarkArray[1024];
};

template <LoadType Load>
uint getIndex(uint lid) {
	switch (Load) {
		case LoadType::Invariant:
			// All threads load from same address. Index is wave invariant.
			return 0;
		case LoadType::Linear:
			// Linearly increasing starting address to allow memory coalescing
			return lid;
		case LoadType::Random:
			// Randomize start address offset (0-15) to prevent memory coalescing
			return (hash1(lid) & 0xf);
		case LoadType::RandomLarge:
			// Randomize start address offset (0-63) to prevent memory coalescing
			return hash1(lid) & 0x3f;
	}
}

template <LoadType Load>
uint2 getIndex(uint2 lid) {
	switch (Load) {
		case LoadType::Invariant:
			// All threads load from same address. Index is wave invariant.
			return 0;
		case LoadType::Linear:
			// Linearly increasing starting address to allow memory coalescing
			return lid;
		case LoadType::Random:
			// Randomize start address offset (0-3, 0-3) to prevent memory coalescing
			return uint2(hash1(lid.x) & 3, hash1(lid.y) & 3);
		case LoadType::RandomLarge:
			// Randomize start address offset (0-7, 0-7) to prevent memory coalescing
			return uint2(hash1(lid.x) & 7, hash1(lid.y) & 7);
	}
}

float4 expand(vec<float, 1> val) { return val.xxxx; }
float4 expand(vec<float, 2> val) { return val.xyxy; }
float4 expand(vec<float, 3> val) { return val.xyzx; }
float4 expand(vec<float, 4> val) { return val.xyzw; }
float4 expand(packed_vec<float, 1> val) { return val.xxxx; }
float4 expand(packed_vec<float, 2> val) { return val.xyxy; }
float4 expand(packed_vec<float, 3> val) { return val.xyzx; }
float4 expand(packed_vec<float, 4> val) { return val.xyzw; }
half4 expand(vec<half, 1> val) { return val.xxxx; }
half4 expand(vec<half, 2> val) { return val.xyxy; }
half4 expand(vec<half, 3> val) { return val.xyzx; }
half4 expand(vec<half, 4> val) { return val.xyzw; }

template <LoadType Load> kernel void loadConstants(
	uint2 gid [[thread_position_in_grid]],
	uint lid [[thread_index_in_threadgroup]],
	constant LoadConstantsWithArray& constants [[buffer(0)]],
	device float* output [[buffer(1)]])
{
	threadgroup float dummyLDS[BUFFER_THREAD_GROUP_SIZE];

	float4 value = 0;
	uint htid = getIndex<Load>(lid);

	for (int i = 0; i < 256; ++i) {
		// Mask with runtime constant to prevent unwanted compiler optimizations
		uint elemIdx = (htid + i) | constants.elementsMask;

		value += constants.benchmarkArray[elemIdx].xyzw;
	}
	// Linear write to LDS (no bank conflicts). Significantly faster than memory loads.
	dummyLDS[lid] = value.x + value.y + value.z + value.w;

	threadgroup_barrier(mem_flags::mem_threadgroup);

	if (constants.writeIndex != 0xffffffff) {
		output[gid.x + gid.y] = dummyLDS[constants.writeIndex];
	}
}

template <LoadType Load, typename T> kernel void loadConstantBuffer(
	uint2 gid [[thread_position_in_grid]],
	uint lid [[thread_index_in_threadgroup]],
	constant LoadConstants& constants [[buffer(0)]],
	device float* output [[buffer(1)]],
	constant T* buffer [[buffer(2)]])
{
	threadgroup float dummyLDS[BUFFER_THREAD_GROUP_SIZE];

	float4 value = 0;
	uint htid = getIndex<Load>(lid);

	for (int i = 0; i < 256; ++i) {
		// Mask with runtime constant to prevent unwanted compiler optimizations
		uint elemIdx = (htid + i) | constants.elementsMask;

		value += expand(buffer[elemIdx]);
	}
	// Linear write to LDS (no bank conflicts). Significantly faster than memory loads.
	dummyLDS[lid] = value.x + value.y + value.z + value.w;

	threadgroup_barrier(mem_flags::mem_threadgroup);

	if (constants.writeIndex != 0xffffffff) {
		output[gid.x + gid.y] = dummyLDS[constants.writeIndex];
	}
}

template <LoadType Load, typename T, typename U> kernel void loadBuffer(
	uint2 gid [[thread_position_in_grid]],
	uint lid [[thread_index_in_threadgroup]],
	constant LoadConstants& constants [[buffer(0)]],
	device U* output [[buffer(1)]],
	device const T* buffer [[buffer(2)]])
{
	threadgroup U dummyLDS[BUFFER_THREAD_GROUP_SIZE];

	vec<U, 4> value = 0;
	uint htid = getIndex<Load>(lid);

	for (int i = 0; i < 256; ++i) {
		// Mask with runtime constant to prevent unwanted compiler optimizations
		uint elemIdx = (htid + i) | constants.elementsMask;

		value += expand(buffer[elemIdx]);
	}
	// Linear write to LDS (no bank conflicts). Significantly faster than memory loads.
	dummyLDS[lid] = value.x + value.y + value.z + value.w;

	threadgroup_barrier(mem_flags::mem_threadgroup);

	if (constants.writeIndex != 0xffffffff) {
		output[gid.x + gid.y] = dummyLDS[constants.writeIndex];
	}
}

template <LoadType Load, uint Size, typename T> kernel void loadTextureBuffer(
	uint2 gid [[thread_position_in_grid]],
	uint lid [[thread_index_in_threadgroup]],
	constant LoadConstants& constants [[buffer(0)]],
	device T* output [[buffer(1)]],
	texture_buffer<T, access::read> texture [[texture(0)]])
{
	threadgroup T dummyLDS[BUFFER_THREAD_GROUP_SIZE];

	vec<T, 4> value = 0;
	uint htid = getIndex<Load>(lid);

	for (int i = 0; i < 256; ++i) {
		// Mask with runtime constant to prevent unwanted compiler optimizations
		uint elemIdx = (htid + i) | constants.elementsMask;

		if (Size == 1)
			value += texture.read(elemIdx).xxxx;
		else if (Size == 2)
			value += texture.read(elemIdx).xyxy;
		else
			value += texture.read(elemIdx).xyzw;
	}
	// Linear write to LDS (no bank conflicts). Significantly faster than memory loads.
	dummyLDS[lid] = value.x + value.y + value.z + value.w;

	threadgroup_barrier(mem_flags::mem_threadgroup);

	if (constants.writeIndex != 0xffffffff) {
		output[gid.x + gid.y] = dummyLDS[constants.writeIndex];
	}
}

template <LoadType Load, uint Size, typename T> kernel void loadTexture(
	uint2 gid [[thread_position_in_grid]],
	uint2 lid [[thread_position_in_threadgroup]],
	constant LoadConstants& constants [[buffer(0)]],
	device T* output [[buffer(1)]],
	texture2d<T, access::read> texture [[texture(0)]])
{
	threadgroup T dummyLDS[TEXTURE_THREAD_GROUP_SIZE][TEXTURE_THREAD_GROUP_SIZE];

	vec<T, 4> value = 0;
	uint2 htid = getIndex<Load>(lid);

	for (int i = 0; i < 16; ++i) {
		for (int j = 0; j < 16; ++j) {
			// Mask with runtime constant to prevent unwanted compiler optimizations
			uint2 elemIdx = (htid + uint2(i, j)) | constants.elementsMask;

			if (Size == 1)
				value += texture.read(elemIdx).xxxx;
			else if (Size == 2)
				value += texture.read(elemIdx).xyxy;
			else
				value += texture.read(elemIdx).xyzw;
		}
	}
	// Linear write to LDS (no bank conflicts). Significantly faster than memory loads.
	dummyLDS[lid.y][lid.x] = value.x + value.y + value.z + value.w;

	threadgroup_barrier(mem_flags::mem_threadgroup);

	if (constants.writeIndex != 0xffffffff) {
		output[gid.x + gid.y] = dummyLDS[(constants.writeIndex >> 8) & 0xff][constants.writeIndex & 0xff];
	}
}

template <LoadType Load, uint Size, typename T> kernel void sampleTexture(
	uint2 gid [[thread_position_in_grid]],
	uint2 lid [[thread_position_in_threadgroup]],
	constant LoadConstants& constants [[buffer(0)]],
	device T* output [[buffer(1)]],
	texture2d<T, access::sample> texture [[texture(0)]],
	sampler samp [[sampler(0)]])
{
	threadgroup T dummyLDS[TEXTURE_THREAD_GROUP_SIZE][TEXTURE_THREAD_GROUP_SIZE];

	vec<T, 4> value = 0;
	uint2 htid = getIndex<Load>(lid);

	const float2 invTextureDims = 1.0f / float2(32.0f, 32.0f);
	const float2 texCenter = invTextureDims * 0.5;

	for (int i = 0; i < 16; ++i) {
		for (int j = 0; j < 16; ++j) {
			// Mask with runtime constant to prevent unwanted compiler optimizations
			uint2 elemIdx = (htid + uint2(i, j)) | constants.elementsMask;

			float2 uv = float2(elemIdx) * invTextureDims + texCenter;

			if (Size == 1)
				value += texture.sample(samp, uv).xxxx;
			else if (Size == 2)
				value += texture.sample(samp, uv).xyxy;
			else
				value += texture.sample(samp, uv).xyzw;
		}
	}
	// Linear write to LDS (no bank conflicts). Significantly faster than memory loads.
	dummyLDS[lid.y][lid.x] = value.x + value.y + value.z + value.w;

	threadgroup_barrier(mem_flags::mem_threadgroup);

	if (constants.writeIndex != 0xffffffff) {
		output[gid.x + gid.y] = dummyLDS[(constants.writeIndex >> 8) & 0xff][constants.writeIndex & 0xff];
	}
}

template <LoadType Load, typename T> kernel void gatherTexture(
	uint2 gid [[thread_position_in_grid]],
	uint2 lid [[thread_position_in_threadgroup]],
	constant LoadConstants& constants [[buffer(0)]],
	device T* output [[buffer(1)]],
	texture2d<T, access::sample> texture [[texture(0)]],
	sampler samp [[sampler(0)]])
{
	threadgroup T dummyLDS[TEXTURE_THREAD_GROUP_SIZE][TEXTURE_THREAD_GROUP_SIZE];

	vec<T, 4> value = 0;
	uint2 htid = getIndex<Load>(lid);

	const float2 invTextureDims = 1.0f / float2(32.0f, 32.0f);
	const float2 texCenter = invTextureDims * 0.5;

	for (int i = 0; i < 16; ++i) {
		for (int j = 0; j < 16; ++j) {
			// Mask with runtime constant to prevent unwanted compiler optimizations
			uint2 elemIdx = (htid + uint2(i, j)) | constants.elementsMask;

			float2 uv = float2(elemIdx) * invTextureDims + texCenter;

			value += texture.gather(samp, uv);
		}
	}
	// Linear write to LDS (no bank conflicts). Significantly faster than memory loads.
	dummyLDS[lid.y][lid.x] = value.x + value.y + value.z + value.w;

	threadgroup_barrier(mem_flags::mem_threadgroup);

	if (constants.writeIndex != 0xffffffff) {
		output[gid.x + gid.y] = dummyLDS[(constants.writeIndex >> 8) & 0xff][constants.writeIndex & 0xff];
	}
}

#define TEMPLATE_ALL_LOADS(macro, name, ...) \
	macro(name "Uniform", LoadType::Invariant, ##__VA_ARGS__) \
	macro(name "Linear", LoadType::Linear, ##__VA_ARGS__) \
	macro(name "Random", LoadType::Random, ##__VA_ARGS__) \
	macro(name "RandomLarge", LoadType::RandomLarge, ##__VA_ARGS__) \

#define TEMPLATE_124(macro, name, ...) \
	TEMPLATE_ALL_LOADS(macro, name "1d", 1, ##__VA_ARGS__) \
	TEMPLATE_ALL_LOADS(macro, name "2d", 2, ##__VA_ARGS__) \
	TEMPLATE_ALL_LOADS(macro, name "4d", 4, ##__VA_ARGS__) \

#define TEMPLATE_1234(macro, name, ...) \
	TEMPLATE_ALL_LOADS(macro, name "1d", 1, ##__VA_ARGS__) \
	TEMPLATE_ALL_LOADS(macro, name "2d", 2, ##__VA_ARGS__) \
	TEMPLATE_ALL_LOADS(macro, name "3d", 3, ##__VA_ARGS__) \
	TEMPLATE_ALL_LOADS(macro, name "4d", 4, ##__VA_ARGS__) \

#define TEMPLATE_CONSTANT(name, type) \
	template [[host_name(name)]] kernel void loadConstants<type>(uint2, uint, constant LoadConstantsWithArray&, device float*);

#define TEMPLATE_BUFFER(name, type, size, fn, loadtype, qualifier, buffer_type) \
	template [[host_name(name)]] kernel void fn<type, buffer_type<float, size>>(uint2, uint, constant LoadConstants&, device loadtype*, qualifier buffer_type<float, size>*);

#define TEMPLATE_UNORM_BUFFER(name, type, fn, loadtype, qualifier, buffer_type) \
	template [[host_name(name)]] kernel void fn<type, buffer_type>(uint2, uint, constant LoadConstants&, device loadtype*, qualifier buffer_type*);

#define TEMPLATE_GATHER(name, type, fn, loadtype) \
	template [[host_name(name)]] kernel void fn<type, loadtype>(uint2, uint2, constant LoadConstants&, device loadtype*, texture2d<loadtype, access::sample>, sampler);

#define TEMPLATE_OTHER(name, type, size, fn, loadtype, lid, ...) \
	template [[host_name(name)]] kernel void fn<type, size, loadtype>(uint2, lid, constant LoadConstants&, device loadtype*, ##__VA_ARGS__);

using half1 = vec<half, 1>;

TEMPLATE_ALL_LOADS(TEMPLATE_CONSTANT, "loadConstant")
TEMPLATE_ALL_LOADS(TEMPLATE_UNORM_BUFFER, "loadUnormBuffer2d", loadBuffer, float, device const, rg8unorm<float2>)
TEMPLATE_ALL_LOADS(TEMPLATE_UNORM_BUFFER, "loadUnormBuffer4d", loadBuffer, float, device const, rgba8unorm<float4>)
TEMPLATE_ALL_LOADS(TEMPLATE_UNORM_BUFFER, "loadUnormHalfBuffer2d", loadBuffer, half, device const, rg8unorm<half2>)
TEMPLATE_ALL_LOADS(TEMPLATE_UNORM_BUFFER, "loadUnormHalfBuffer4d", loadBuffer, half, device const, rgba8unorm<half4>)
TEMPLATE_ALL_LOADS(TEMPLATE_UNORM_BUFFER, "loadHalfBuffer1d", loadBuffer, half, device const, half1)
TEMPLATE_ALL_LOADS(TEMPLATE_UNORM_BUFFER, "loadHalfBuffer2d", loadBuffer, half, device const, half2)
TEMPLATE_ALL_LOADS(TEMPLATE_UNORM_BUFFER, "loadHalfBuffer4d", loadBuffer, half, device const, half4)
TEMPLATE_124(TEMPLATE_BUFFER, "loadBuffer", loadBuffer, float, device const, vec)
TEMPLATE_1234(TEMPLATE_BUFFER, "loadPackedBuffer", loadBuffer, float, device const, packed_vec)
TEMPLATE_124(TEMPLATE_BUFFER, "loadConstantBuffer", loadConstantBuffer, float, constant, vec)
TEMPLATE_1234(TEMPLATE_BUFFER, "loadConstantPackedBuffer", loadConstantBuffer, float, constant, packed_vec)
TEMPLATE_124(TEMPLATE_OTHER, "loadTextureBuffer", loadTextureBuffer, float, uint, texture_buffer<float, access::read>)
TEMPLATE_124(TEMPLATE_OTHER, "loadTexture", loadTexture, float, uint2, texture2d<float, access::read>)
TEMPLATE_124(TEMPLATE_OTHER, "sampleTexture", sampleTexture, float, uint2, texture2d<float, access::sample>, sampler)
TEMPLATE_ALL_LOADS(TEMPLATE_GATHER, "gatherTexture", gatherTexture, float)
TEMPLATE_124(TEMPLATE_OTHER, "loadTextureBufferHalf", loadTextureBuffer, half, uint, texture_buffer<half, access::read>)
TEMPLATE_124(TEMPLATE_OTHER, "loadTextureHalf", loadTexture, half, uint2, texture2d<half, access::read>)
TEMPLATE_124(TEMPLATE_OTHER, "sampleTextureHalf", sampleTexture, half, uint2, texture2d<half, access::sample>, sampler)
TEMPLATE_ALL_LOADS(TEMPLATE_GATHER, "gatherTextureHalf", gatherTexture, half)

import Metal

class BenchTest {
	let dev: MTLDevice
	let queue: MTLCommandQueue
	let output: MTLBuffer
	let constants: MTLBuffer
	let pdesc: MTLComputePassDescriptor
	let scope: MTLCaptureScope
	let fence: MTLFence
	var queries: [String] = []
	var results: [Double] = []
	var cb: MTLCommandBuffer!
	var lastCB: MTLCommandBuffer? = nil
	var enc: MTLComputeCommandEncoder!

	init(queue: MTLCommandQueue) {
		self.dev = queue.device
		self.queue = queue
		self.output = self.dev.makeBuffer(length: 64, options: [.storageModePrivate, .hazardTrackingModeUntracked])!
		self.constants = self.dev.makeBuffer(length: 65536, options: .storageModeManaged)!
		self.constants.contents().initializeMemory(as: UInt8.self, repeating: 0, count: 65536)
		self.constants.contents().storeBytes(of: SIMD2<UInt32>(0, 0xffffffff), as: SIMD2<UInt32>.self)
		self.constants.didModifyRange(0..<65536)
		self.constants.label = "Constants"
		self.scope = MTLCaptureManager.shared().makeCaptureScope(commandQueue: queue)
		self.scope.label = "Benchmark Run"
		self.pdesc = MTLComputePassDescriptor()
		self.fence = self.dev.makeFence()!
		self.fence.label = "Benchmark Fence"
	}

	private func flushCB() {
		if let cb = lastCB {
			cb.waitUntilCompleted()
			results.append(cb.gpuEndTime - cb.gpuStartTime)
			lastCB = nil
		}
	}

	func begin() {
		scope.begin()
	}

	func end() -> [(Double, String)] {
		defer {
			queries.removeAll(keepingCapacity: true)
			results.removeAll(keepingCapacity: true)
			scope.end()
		}
		flushCB()
		return Array(zip(results, queries))
	}

	func testCase(_ shader: MTLComputePipelineState, name: String, buffer: MTLBuffer? = nil, texture: MTLTexture? = nil, sampler: MTLSamplerState? = nil, bufferOffset: Int = 0) {
		cb = queue.makeCommandBuffer()!
		let enc = cb.makeComputeCommandEncoder(descriptor: pdesc)!
		enc.label = name
		enc.setBuffer(constants, offset: 0, index: 0)
		enc.setBuffer(output, offset: 0, index: 1)
		enc.waitForFence(fence)

		if let buffer = buffer {
			enc.setBuffer(buffer, offset: bufferOffset, index: 2)
		}
		if let texture = texture {
			enc.setTexture(texture, index: 0)
		}
		if let sampler = sampler {
			enc.setSamplerState(sampler, index: 0)
		}
		enc.setComputePipelineState(shader)
		let tg = MTLSize(width: 16, height: 16, depth: 1)
		enc.dispatchThreadgroups(MTLSize(width: 1024 / tg.width, height: 1024 / tg.height, depth: 1), threadsPerThreadgroup: tg)
		queries.append(name)

		enc.updateFence(fence)
		enc.endEncoding()
		cb.commit()
		flushCB()
		lastCB = cb
		cb = nil
	}
}

extension MTLPixelFormat {
	var bytesPerPixel: Int {
		switch self {
		case .r8Unorm:     return 1
		case .r16Float:    return 2
		case .r32Float:    return 4
		case .rg8Unorm:    return 2
		case .rg16Float:   return 4
		case .rg32Float:   return 8
		case .rgba8Unorm:  return 4
		case .rgba16Float: return 8
		case .rgba32Float: return 16
		default: return 0
		}
	}
}

func test(gpu: MTLDevice) {
	fputs("Testing \(gpu.name)...\n", stderr)
	let q = gpu.makeCommandQueue()!
	let lib = gpu.makeDefaultLibrary()!
	let bench = BenchTest(queue: q)
	typealias ShaderPack = (uniform: MTLComputePipelineState, linear: MTLComputePipelineState, random: MTLComputePipelineState, randoml: MTLComputePipelineState)
	func makeTexture(name: String, format: MTLPixelFormat, type: MTLTextureType) -> MTLTexture {
		let desc: MTLTextureDescriptor
		if type == .type2D {
			desc = .texture2DDescriptor(pixelFormat: format, width: 32, height: 32, mipmapped: false)
		} else {
			desc = .textureBufferDescriptor(with: format, width: 1024, usage: .shaderRead)
		}
		desc.storageMode = .private
		desc.usage = .shaderRead
		let tex = gpu.makeTexture(descriptor: desc)!
		tex.label = name
		return tex
	}
	func makeSampler(name: String, filter: MTLSamplerMinMagFilter) -> MTLSamplerState {
		let desc = MTLSamplerDescriptor()
		desc.minFilter = filter
		desc.magFilter = filter
		desc.label = name
		return gpu.makeSamplerState(descriptor: desc)!
	}
	func loadShader(name: String) -> MTLComputePipelineState? {
		return try? gpu.makeComputePipelineState(function: lib.makeFunction(name: name)!)
	}
	func loadShaders(name: String) -> ShaderPack? {
		guard let uniform = loadShader(name: name + "Uniform"),
		      let linear  = loadShader(name: name + "Linear"),
		      let random  = loadShader(name: name + "Random"),
		      let randoml = loadShader(name: name + "RandomLarge") else
		{
			fputs("Failed to compile \(name)\n", stderr)
			return nil
		}
		return (uniform, linear, random, randoml)
	}
	func testAll(shaders: ShaderPack?, name: String, buffer: MTLBuffer? = nil, texture: MTLTexture? = nil, sampler: MTLSamplerState? = nil, bufferOffset: Int = 0) {
		guard let shaders = shaders else { return }
		bench.testCase(shaders.uniform, name: name + " uniform", buffer: buffer, texture: texture, sampler: sampler, bufferOffset: bufferOffset)
		bench.testCase(shaders.linear,  name: name + " linear",  buffer: buffer, texture: texture, sampler: sampler, bufferOffset: bufferOffset)
		bench.testCase(shaders.random,  name: name + " random",  buffer: buffer, texture: texture, sampler: sampler, bufferOffset: bufferOffset)
		bench.testCase(shaders.randoml, name: name + " random+", buffer: buffer, texture: texture, sampler: sampler, bufferOffset: bufferOffset)
	}

	let tex2dR8      = makeTexture(name: "texture2d<R8>",      format: .r8Unorm,     type: .type2D)
	let tex2dR16F    = makeTexture(name: "texture2d<R16F>",    format: .r16Float,    type: .type2D)
	let tex2dR32F    = makeTexture(name: "texture2d<R32F>",    format: .r32Float,    type: .type2D)
	let tex2dRG8     = makeTexture(name: "texture2d<RG8>",     format: .rg8Unorm,    type: .type2D)
	let tex2dRG16F   = makeTexture(name: "texture2d<RG16F>",   format: .rg16Float,   type: .type2D)
	let tex2dRG32F   = makeTexture(name: "texture2d<RG32F>",   format: .rg32Float,   type: .type2D)
	let tex2dRGBA8   = makeTexture(name: "texture2d<RGBA8>",   format: .rgba8Unorm,  type: .type2D)
	let tex2dRGBA16F = makeTexture(name: "texture2d<RGBA16F>", format: .rgba16Float, type: .type2D)
	let tex2dRGBA32F = makeTexture(name: "texture2d<RGBA32F>", format: .rgba32Float, type: .type2D)

	let tbufR8      = makeTexture(name: "texture_buffer<R8>",      format: .r8Unorm,     type: .typeTextureBuffer)
	let tbufR16F    = makeTexture(name: "texture_buffer<R16F>",    format: .r16Float,    type: .typeTextureBuffer)
	let tbufR32F    = makeTexture(name: "texture_buffer<R32F>",    format: .r32Float,    type: .typeTextureBuffer)
	let tbufRG8     = makeTexture(name: "texture_buffer<RG8>",     format: .rg8Unorm,    type: .typeTextureBuffer)
	let tbufRG16F   = makeTexture(name: "texture_buffer<RG16F>",   format: .rg16Float,   type: .typeTextureBuffer)
	let tbufRG32F   = makeTexture(name: "texture_buffer<RG32F>",   format: .rg32Float,   type: .typeTextureBuffer)
	let tbufRGBA8   = makeTexture(name: "texture_buffer<RGBA8>",   format: .rgba8Unorm,  type: .typeTextureBuffer)
	let tbufRGBA16F = makeTexture(name: "texture_buffer<RGBA16F>", format: .rgba16Float, type: .typeTextureBuffer)
	let tbufRGBA32F = makeTexture(name: "texture_buffer<RGBA32F>", format: .rgba32Float, type: .typeTextureBuffer)

	let textures = [
		tex2dR8,    tex2dR16F,    tex2dR32F,
		tex2dRG8,   tex2dRG16F,   tex2dRG32F,
		tex2dRGBA8, tex2dRGBA16F, tex2dRGBA32F,
		tbufR8,     tbufR16F,     tbufR32F,
		tbufRG8,    tbufRG16F,    tbufRG32F,
		tbufRGBA8,  tbufRGBA16F,  tbufRGBA32F,
	]

	let samplerNearest = makeSampler(name: "Nearest", filter: .nearest)
	let samplerBilinear = makeSampler(name: "Bilinear", filter: .linear)

	let buffer = gpu.makeBuffer(length: 2048 * 16, options: .storageModePrivate)!
	buffer.label = "Source Buffer"

	let shaderConstant = loadShaders(name: "loadConstant")
	let shaderUnormBuffer2d = loadShaders(name: "loadUnormBuffer2d")
	let shaderUnormBuffer4d = loadShaders(name: "loadUnormBuffer4d")
	let shaderUnormHalfBuffer2d = loadShaders(name: "loadUnormHalfBuffer2d")
	let shaderUnormHalfBuffer4d = loadShaders(name: "loadUnormHalfBuffer4d")
	let shaderHalfBuffer2d = loadShaders(name: "loadHalfBuffer2d")
	let shaderHalfBuffer4d = loadShaders(name: "loadHalfBuffer4d")
	let shaderBuffer1d = loadShaders(name: "loadBuffer1d")
	let shaderBuffer2d = loadShaders(name: "loadBuffer2d")
	let shaderBuffer4d = loadShaders(name: "loadBuffer4d")
	let shaderPackedBuffer2d = loadShaders(name: "loadPackedBuffer2d")
	let shaderPackedBuffer3d = loadShaders(name: "loadPackedBuffer3d")
	let shaderPackedBuffer4d = loadShaders(name: "loadPackedBuffer4d")
	let shaderConstantBuffer1d = loadShaders(name: "loadConstantBuffer1d")
	let shaderConstantBuffer2d = loadShaders(name: "loadConstantBuffer2d")
	let shaderConstantBuffer4d = loadShaders(name: "loadConstantBuffer4d")
	let shaderConstantPackedBuffer2d = loadShaders(name: "loadConstantPackedBuffer2d")
	let shaderConstantPackedBuffer3d = loadShaders(name: "loadConstantPackedBuffer3d")
	let shaderConstantPackedBuffer4d = loadShaders(name: "loadConstantPackedBuffer4d")
	let shaderTextureBuffer1d = loadShaders(name: "loadTextureBuffer1d")
	let shaderTextureBuffer2d = loadShaders(name: "loadTextureBuffer2d")
	let shaderTextureBuffer4d = loadShaders(name: "loadTextureBuffer4d")
	let shaderTexture1d = loadShaders(name: "loadTexture1d")
	let shaderTexture2d = loadShaders(name: "loadTexture2d")
	let shaderTexture4d = loadShaders(name: "loadTexture4d")
	let shaderSample1d = loadShaders(name: "sampleTexture1d")
	let shaderSample2d = loadShaders(name: "sampleTexture2d")
	let shaderSample4d = loadShaders(name: "sampleTexture4d")
	let shaderGather = loadShaders(name: "gatherTexture")
	let shaderTextureBufferHalf1d = loadShaders(name: "loadTextureBufferHalf1d")
	let shaderTextureBufferHalf2d = loadShaders(name: "loadTextureBufferHalf2d")
	let shaderTextureBufferHalf4d = loadShaders(name: "loadTextureBufferHalf4d")
	let shaderTextureHalf1d = loadShaders(name: "loadTextureHalf1d")
	let shaderTextureHalf2d = loadShaders(name: "loadTextureHalf2d")
	let shaderTextureHalf4d = loadShaders(name: "loadTextureHalf4d")
	let shaderSampleHalf1d = loadShaders(name: "sampleTextureHalf1d")
	let shaderSampleHalf2d = loadShaders(name: "sampleTextureHalf2d")
	let shaderSampleHalf4d = loadShaders(name: "sampleTextureHalf4d")
	let shaderGatherHalf = loadShaders(name: "gatherTextureHalf")

	do {
		let initBuf = gpu.makeBuffer(length: 2048 * 16)!
		initBuf.label = "Texture Init"
		initBuf.contents().initializeMemory(as: UInt8.self, repeating: 0, count: 2048 * 16)
		let cb = q.makeCommandBuffer()!
		let enc = cb.makeBlitCommandEncoder()!
		enc.label = "Texture Init"
		enc.copy(from: initBuf, sourceOffset: 0, to: buffer, destinationOffset: 0, size: buffer.length)
		for tex in textures {
			let bpp = tex.pixelFormat.bytesPerPixel
			let (width, height) = (tex.width, tex.height)
			enc.copy(
				from: initBuf,
				sourceOffset: 0,
				sourceBytesPerRow: bpp * width,
				sourceBytesPerImage: bpp * width * height,
				sourceSize: MTLSize(width: width, height: height, depth: 1),
				to: tex,
				destinationSlice: 0,
				destinationLevel: 0,
				destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0)
			)
		}
		enc.endEncoding()
		cb.commit()
	}

	let numBenchmarkRuns = 30

	var results = [(secs: [Double], name: String)]()

	fputs("Running \(numBenchmarkRuns) benchmark runs...\n", stderr)

	for _ in 0..<numBenchmarkRuns { autoreleasepool {
		bench.begin()

		testAll(shaders: shaderConstant, name: "cbuffer{float4}")

		testAll(shaders: shaderUnormBuffer2d, name: "device const rg8unorm<float2>*", buffer: buffer)
		testAll(shaders: shaderUnormBuffer4d, name: "device const rgba8unorm<float4>*", buffer: buffer)
		testAll(shaders: shaderUnormHalfBuffer2d, name: "device const rg8unorm<half2>*", buffer: buffer)
		testAll(shaders: shaderUnormHalfBuffer4d, name: "device const rgba8unorm<half4>*", buffer: buffer)
		testAll(shaders: shaderHalfBuffer2d, name: "device const half2*", buffer: buffer)
		testAll(shaders: shaderHalfBuffer4d, name: "device const half4*", buffer: buffer)

		testAll(shaders: shaderBuffer1d, name: "device const float1*", buffer: buffer)
		testAll(shaders: shaderBuffer2d, name: "device const float2*", buffer: buffer)
		testAll(shaders: shaderBuffer4d, name: "device const float4*", buffer: buffer)
		testAll(shaders: shaderPackedBuffer2d, name: "device const packed_float2*", buffer: buffer)
		testAll(shaders: shaderPackedBuffer3d, name: "device const packed_float3*", buffer: buffer)
		testAll(shaders: shaderPackedBuffer4d, name: "device const packed_float4*", buffer: buffer)
		testAll(shaders: shaderPackedBuffer2d, name: "device const unaligned packed_float2*", buffer: buffer, bufferOffset: 4)
		testAll(shaders: shaderPackedBuffer4d, name: "device const unaligned packed_float4*", buffer: buffer, bufferOffset: 4)

		testAll(shaders: shaderConstantBuffer1d, name: "constant float1*", buffer: buffer)
		testAll(shaders: shaderConstantBuffer2d, name: "constant float2*", buffer: buffer)
		testAll(shaders: shaderConstantBuffer4d, name: "constant float4*", buffer: buffer)
		testAll(shaders: shaderConstantPackedBuffer2d, name: "constant packed_float2*", buffer: buffer)
		testAll(shaders: shaderConstantPackedBuffer3d, name: "constant packed_float3*", buffer: buffer)
		testAll(shaders: shaderConstantPackedBuffer4d, name: "constant packed_float4*", buffer: buffer)

		testAll(shaders: shaderTextureBuffer1d, name: "texture_buffer<R8>", texture: tbufR8)
		testAll(shaders: shaderTextureBuffer2d, name: "texture_buffer<RG8>", texture: tbufRG8)
		testAll(shaders: shaderTextureBuffer4d, name: "texture_buffer<RGBA8>", texture: tbufRGBA8)
		testAll(shaders: shaderTextureBuffer1d, name: "texture_buffer<R16>", texture: tbufR16F)
		testAll(shaders: shaderTextureBuffer2d, name: "texture_buffer<RG16>", texture: tbufRG16F)
		testAll(shaders: shaderTextureBuffer4d, name: "texture_buffer<RGBA16>", texture: tbufRGBA16F)
		testAll(shaders: shaderTextureBuffer1d, name: "texture_buffer<R32>", texture: tbufR32F)
		testAll(shaders: shaderTextureBuffer2d, name: "texture_buffer<RG32>", texture: tbufRG32F)
		testAll(shaders: shaderTextureBuffer4d, name: "texture_buffer<RGBA32>", texture: tbufRGBA32F)

		testAll(shaders: shaderTexture1d, name: "texture2d<R8>", texture: tex2dR8)
		testAll(shaders: shaderTexture2d, name: "texture2d<RG8>", texture: tex2dRG8)
		testAll(shaders: shaderTexture4d, name: "texture2d<RGBA8>", texture: tex2dRGBA8)
		testAll(shaders: shaderTexture1d, name: "texture2d<R16>", texture: tex2dR16F)
		testAll(shaders: shaderTexture2d, name: "texture2d<RG16>", texture: tex2dRG16F)
		testAll(shaders: shaderTexture4d, name: "texture2d<RGBA16>", texture: tex2dRGBA16F)
		testAll(shaders: shaderTexture1d, name: "texture2d<R32>", texture: tex2dR32F)
		testAll(shaders: shaderTexture2d, name: "texture2d<RG32>", texture: tex2dRG32F)
		testAll(shaders: shaderTexture4d, name: "texture2d<RGBA32>", texture: tex2dRGBA32F)

		testAll(shaders: shaderSample1d, name: "texture2d<R8>.sample(nearest)", texture: tex2dR8, sampler: samplerNearest)
		testAll(shaders: shaderSample2d, name: "texture2d<RG8>.sample(nearest)", texture: tex2dRG8, sampler: samplerNearest)
		testAll(shaders: shaderSample4d, name: "texture2d<RGBA8>.sample(nearest)", texture: tex2dRGBA8, sampler: samplerNearest)
		testAll(shaders: shaderSample1d, name: "texture2d<R16>.sample(nearest)", texture: tex2dR16F, sampler: samplerNearest)
		testAll(shaders: shaderSample2d, name: "texture2d<RG16>.sample(nearest)", texture: tex2dRG16F, sampler: samplerNearest)
		testAll(shaders: shaderSample4d, name: "texture2d<RGBA16>.sample(nearest)", texture: tex2dRGBA16F, sampler: samplerNearest)
		testAll(shaders: shaderSample1d, name: "texture2d<R32>.sample(nearest)", texture: tex2dR32F, sampler: samplerNearest)
		testAll(shaders: shaderSample2d, name: "texture2d<RG32>.sample(nearest)", texture: tex2dRG32F, sampler: samplerNearest)
		testAll(shaders: shaderSample4d, name: "texture2d<RGBA32>.sample(nearest)", texture: tex2dRGBA32F, sampler: samplerNearest)

		testAll(shaders: shaderSample1d, name: "texture2d<R8>.sample(bilinear)", texture: tex2dR8, sampler: samplerBilinear)
		testAll(shaders: shaderSample2d, name: "texture2d<RG8>.sample(bilinear)", texture: tex2dRG8, sampler: samplerBilinear)
		testAll(shaders: shaderSample4d, name: "texture2d<RGBA8>.sample(bilinear)", texture: tex2dRGBA8, sampler: samplerBilinear)
		testAll(shaders: shaderSample1d, name: "texture2d<R16>.sample(bilinear)", texture: tex2dR16F, sampler: samplerBilinear)
		testAll(shaders: shaderSample2d, name: "texture2d<RG16>.sample(bilinear)", texture: tex2dRG16F, sampler: samplerBilinear)
		testAll(shaders: shaderSample4d, name: "texture2d<RGBA16>.sample(bilinear)", texture: tex2dRGBA16F, sampler: samplerBilinear)
		testAll(shaders: shaderSample1d, name: "texture2d<R32>.sample(bilinear)", texture: tex2dR32F, sampler: samplerBilinear)
		testAll(shaders: shaderSample2d, name: "texture2d<RG32>.sample(bilinear)", texture: tex2dRG32F, sampler: samplerBilinear)
		testAll(shaders: shaderSample4d, name: "texture2d<RGBA32>.sample(bilinear)", texture: tex2dRGBA32F, sampler: samplerBilinear)

		testAll(shaders: shaderGather, name: "texture2d<R8>.gather", texture: tex2dR8, sampler: samplerBilinear)
		testAll(shaders: shaderGather, name: "texture2d<R16>.gather", texture: tex2dR16F, sampler: samplerBilinear)
		testAll(shaders: shaderGather, name: "texture2d<R32>.gather", texture: tex2dR32F, sampler: samplerBilinear)

		testAll(shaders: shaderTextureBufferHalf1d, name: "texture_buffer<R8H>", texture: tbufR8)
		testAll(shaders: shaderTextureBufferHalf2d, name: "texture_buffer<RG8H>", texture: tbufRG8)
		testAll(shaders: shaderTextureBufferHalf4d, name: "texture_buffer<RGBA8H>", texture: tbufRGBA8)
		testAll(shaders: shaderTextureBufferHalf1d, name: "texture_buffer<R16H>", texture: tbufR16F)
		testAll(shaders: shaderTextureBufferHalf2d, name: "texture_buffer<RG16H>", texture: tbufRG16F)
		testAll(shaders: shaderTextureBufferHalf4d, name: "texture_buffer<RGBA16H>", texture: tbufRGBA16F)
		testAll(shaders: shaderTextureBufferHalf1d, name: "texture_buffer<R32H>", texture: tbufR32F)
		testAll(shaders: shaderTextureBufferHalf2d, name: "texture_buffer<RG32H>", texture: tbufRG32F)
		testAll(shaders: shaderTextureBufferHalf4d, name: "texture_buffer<RGBA32H>", texture: tbufRGBA32F)

		testAll(shaders: shaderTextureHalf1d, name: "texture2d<R8H>", texture: tex2dR8)
		testAll(shaders: shaderTextureHalf2d, name: "texture2d<RG8H>", texture: tex2dRG8)
		testAll(shaders: shaderTextureHalf4d, name: "texture2d<RGBA8H>", texture: tex2dRGBA8)
		testAll(shaders: shaderTextureHalf1d, name: "texture2d<R16H>", texture: tex2dR16F)
		testAll(shaders: shaderTextureHalf2d, name: "texture2d<RG16H>", texture: tex2dRG16F)
		testAll(shaders: shaderTextureHalf4d, name: "texture2d<RGBA16H>", texture: tex2dRGBA16F)
		testAll(shaders: shaderTextureHalf1d, name: "texture2d<R32H>", texture: tex2dR32F)
		testAll(shaders: shaderTextureHalf2d, name: "texture2d<RG32H>", texture: tex2dRG32F)
		testAll(shaders: shaderTextureHalf4d, name: "texture2d<RGBA32H>", texture: tex2dRGBA32F)

		testAll(shaders: shaderSampleHalf1d, name: "texture2d<R8H>.sample(nearest)", texture: tex2dR8, sampler: samplerNearest)
		testAll(shaders: shaderSampleHalf2d, name: "texture2d<RG8H>.sample(nearest)", texture: tex2dRG8, sampler: samplerNearest)
		testAll(shaders: shaderSampleHalf4d, name: "texture2d<RGBA8H>.sample(nearest)", texture: tex2dRGBA8, sampler: samplerNearest)
		testAll(shaders: shaderSampleHalf1d, name: "texture2d<R16H>.sample(nearest)", texture: tex2dR16F, sampler: samplerNearest)
		testAll(shaders: shaderSampleHalf2d, name: "texture2d<RG16H>.sample(nearest)", texture: tex2dRG16F, sampler: samplerNearest)
		testAll(shaders: shaderSampleHalf4d, name: "texture2d<RGBA16H>.sample(nearest)", texture: tex2dRGBA16F, sampler: samplerNearest)
		testAll(shaders: shaderSampleHalf1d, name: "texture2d<R32H>.sample(nearest)", texture: tex2dR32F, sampler: samplerNearest)
		testAll(shaders: shaderSampleHalf2d, name: "texture2d<RG32H>.sample(nearest)", texture: tex2dRG32F, sampler: samplerNearest)
		testAll(shaders: shaderSampleHalf4d, name: "texture2d<RGBA32H>.sample(nearest)", texture: tex2dRGBA32F, sampler: samplerNearest)

		testAll(shaders: shaderSampleHalf1d, name: "texture2d<R8H>.sample(bilinear)", texture: tex2dR8, sampler: samplerBilinear)
		testAll(shaders: shaderSampleHalf2d, name: "texture2d<RG8H>.sample(bilinear)", texture: tex2dRG8, sampler: samplerBilinear)
		testAll(shaders: shaderSampleHalf4d, name: "texture2d<RGBA8H>.sample(bilinear)", texture: tex2dRGBA8, sampler: samplerBilinear)
		testAll(shaders: shaderSampleHalf1d, name: "texture2d<R16H>.sample(bilinear)", texture: tex2dR16F, sampler: samplerBilinear)
		testAll(shaders: shaderSampleHalf2d, name: "texture2d<RG16H>.sample(bilinear)", texture: tex2dRG16F, sampler: samplerBilinear)
		testAll(shaders: shaderSampleHalf4d, name: "texture2d<RGBA16H>.sample(bilinear)", texture: tex2dRGBA16F, sampler: samplerBilinear)
		testAll(shaders: shaderSampleHalf1d, name: "texture2d<R32H>.sample(bilinear)", texture: tex2dR32F, sampler: samplerBilinear)
		testAll(shaders: shaderSampleHalf2d, name: "texture2d<RG32H>.sample(bilinear)", texture: tex2dRG32F, sampler: samplerBilinear)
		testAll(shaders: shaderSampleHalf4d, name: "texture2d<RGBA32H>.sample(bilinear)", texture: tex2dRGBA32F, sampler: samplerBilinear)

		testAll(shaders: shaderGatherHalf, name: "texture2d<R8H>.gather", texture: tex2dR8, sampler: samplerBilinear)
		testAll(shaders: shaderGatherHalf, name: "texture2d<R16H>.gather", texture: tex2dR16F, sampler: samplerBilinear)
		testAll(shaders: shaderGatherHalf, name: "texture2d<R32H>.gather", texture: tex2dR32F, sampler: samplerBilinear)

		let res = bench.end()
		if results.isEmpty {
			results = res.map { ([$0.0], $0.1) }
		} else {
			for i in 0..<results.count {
				results[i].secs.append(res[i].0)
				assert(results[i].name == res[i].1)
			}
		}
		fputs(".", stderr)
	}}
	print()

	func median(_ res: [Double]) -> Double {
		let sorted = res.sorted()
		return (sorted[(sorted.count - 1) / 2] + sorted[sorted.count / 2]) / 2
	}

	let reference = median(results.first(where: { $0.name == "texture_buffer<R32> random" })!.secs)

	for result in results {
		let secs = median(result.secs)
		let ms = String(format: "%6.2f", secs * 1000)
		let xref = String(format: "%6.2f", reference / secs)
		print("\(ms)ms \(xref)x \(result.name)")
	}
}

do {
	var idx = -1

	if CommandLine.arguments.count > 1 {
		if CommandLine.arguments[1].lowercased() != "all" {
			guard let arg = Int(CommandLine.arguments[1]) else {
				print("Usage: \(CommandLine.arguments[0]) [gpuIndex|all]")
				exit(EXIT_FAILURE)
			}
			idx = arg
		}
	}

	if idx < 0 {
		for gpu in MTLCopyAllDevices() {
			test(gpu: gpu)
		}
	} else {
		test(gpu: MTLCopyAllDevices()[idx])
	}
}

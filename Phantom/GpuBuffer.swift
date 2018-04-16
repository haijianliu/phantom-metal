// Copyright © haijian. All rights reserved.

import MetalKit

/// Buffer needs to pass to shaders as uniforms.
///
/// When update, requires semaphore available.
/// TODO: adopt Uniform protocol.
struct GpuBuffer<BufferType> {
	// Function(vertexShader): the offset into the buffer uniforms that is bound at buffer index must be a multiple of 256.
	let alignedSize = (MemoryLayout<BufferType>.size & ~0xFF) + 0x100
	/// The number of copies of the buffer.
	let max: Int
	/// Current data offer in bytes.
	var offset = 0
	/// Current data index.
	var index = 0
	
	let semaphore: DispatchSemaphore
	var buffer: MTLBuffer
	var pointer: UnsafeMutablePointer<BufferType>
	
	/// Create a GpuBuffer with semaphore vaule.
	///
	/// - Parameters:
	///   - semaphoreValue: members of threads can update this buffer by at the same time.
	///   - options: metal resource options.
	init?(semaphoreValue: Int, options: MTLResourceOptions) {
		max = semaphoreValue
		semaphore = DispatchSemaphore(value: semaphoreValue)
		let bufferSize = alignedSize * max
		guard let newBuffer = Display.main.device?.makeBuffer(length: bufferSize, options: options) else { return nil }
		buffer = newBuffer
		buffer.label = String(describing: BufferType.self)
		pointer = UnsafeMutableRawPointer(buffer.contents()).bindMemory(to: BufferType.self, capacity: 1)
	}

	// TODO: private
	mutating func updateBufferState() {
		/// Update the state of our uniform buffers before rendering
		index = (index + 1) % max
		offset = alignedSize * index
		pointer = UnsafeMutableRawPointer(buffer.contents() + offset).bindMemory(to: BufferType.self, capacity:1)
	}
}

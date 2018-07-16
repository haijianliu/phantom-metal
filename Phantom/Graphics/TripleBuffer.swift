// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: When update, requires semaphore available.
// TODO: Add GpuObject which requires init?(_ device: MTLDevice).
/// [Triple buffering model](https://developer.apple.com/library/content/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/TripleBuffering.html#//apple_ref/doc/uid/TP40016642-CH5-SW1) to update dynamic buffer data.
///
/// Adding a third dynamic data buffer is the ideal solution when considering processor idle time, memory overhead, and frame latency.
struct TripleBuffer<DataType> {
	
	/// Shared storgame mode MTLBuffer which can be sent to GPU using:
	///
	/// `setVertexBuffer(_ buffer: MTLBuffer?, offset: Int, index: Int)`
	let buffer: MTLBuffer
	/// Current data offset in bytes.
	var offset: Int { return alignedSize * index }
	/// Current data pointed by current offset. Returns by stored data type.
	var data: DataType { get { return pointer[0] } set { pointer[0] = newValue } }

	/// The offset into the buffer uniforms that is bound at buffer index must be a multiple of 256 to ensure GPU function usage (shader).
	private let alignedSize: Int = (MemoryLayout<DataType>.size & ~0xFF) + 0x100
	/// The number of copies of the buffer.
	private let max: Int = 3
	/// Current data index.
	private var index = 0
	/// Pointer pointing to current data
	private var pointer: UnsafeMutablePointer<DataType>
	
	/// Create a triple buffer.
	///
	/// Allocates a new zero-filled MTLBuffer of a three times length with a `storageModeShared` storage mode which can be both CPU and GPU accessible.
	///
	/// And this initializer also check the buffer length before allocates it. If the data size is bigger than **4K Bytes**, this initializer will fail and return nil.
	///
	/// - Parameter device: MTLDevice
	init?(_ device: MTLDevice) {
		let bufferLength = alignedSize * max
		if bufferLength > 4096 {
			print("The Data size of triple buffer must be less than 4KB ( current: \(bufferLength) bytes ).")
			return nil
		}
		guard let mtlBuffer = device.makeBuffer(length: bufferLength, options: MTLResourceOptions.storageModeShared) else { return nil }
		buffer = mtlBuffer
		buffer.label = String(describing: DataType.self)
		pointer = UnsafeMutableRawPointer(buffer.contents()).bindMemory(to: DataType.self, capacity: 1)
	}

	/// End current buffer writting, and switch pointer to next offset of the bind memory.
	///
	/// Use end writting just before encoding buffer to command.
	mutating func endWritting() {
		index = (index + 1) % max
		pointer = UnsafeMutableRawPointer(buffer.contents() + offset).bindMemory(to: DataType.self, capacity:1)
	}
}

// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: GpuObject.
public class Shader {

	let renderPipelineState: MTLRenderPipelineState
	let vertexDescriptor: MTLVertexDescriptor

	public init?(_ device: MTLDevice, filepath: String = "Default") {
		// TODO: load metal library.
		guard let library = device.makeDefaultLibrary() else { return nil }

		// TODO: function name enum
		let vertexFunction = library.makeFunction(name: "vertexShader")
		let fragmentFunction = library.makeFunction(name: "fragmentShader")
		vertexDescriptor = Shader.buildVertexDescriptor() // TODO: by library

		// TODO: automatically make vertex descriptor according to current metal library
		let pipelineDescriptor = MTLRenderPipelineDescriptor()
		pipelineDescriptor.label = filepath // TODO: only the library name
		pipelineDescriptor.sampleCount = View.main.sampleCount
		pipelineDescriptor.vertexFunction = vertexFunction
		pipelineDescriptor.fragmentFunction = fragmentFunction
		pipelineDescriptor.vertexDescriptor = vertexDescriptor

		// TODO: though these settings are only for final render pass, may be customizable from render pipeline.
		pipelineDescriptor.colorAttachments[0].pixelFormat = View.main.colorPixelFormat
		pipelineDescriptor.depthAttachmentPixelFormat = View.main.depthStencilPixelFormat
		pipelineDescriptor.stencilAttachmentPixelFormat = View.main.depthStencilPixelFormat

		// pipeline state
		do {
			try renderPipelineState = device.makeRenderPipelineState(descriptor: pipelineDescriptor)
		} catch {
			print("Unable to compile render pipeline state.  Error info: \(error)")
			return nil
		}
	}
}

extension Shader: Encodable {
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder) {
		renderCommandEncoder.setRenderPipelineState(renderPipelineState)
	}
}

extension Shader {
	// TODO: remove this
	static func buildVertexDescriptor() -> MTLVertexDescriptor {
		// Creete a Metal vertex descriptor specifying how vertices will by laid out for input into our render pipeline and how we'll layout our Model IO vertices
		let vertexDescriptor = MTLVertexDescriptor()

		vertexDescriptor.attributes[VertexAttribute.position.rawValue].format = .float3
		vertexDescriptor.attributes[VertexAttribute.position.rawValue].offset = 0
		vertexDescriptor.attributes[VertexAttribute.position.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue

		vertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].format = .float2
		vertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].offset = 0
		vertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].bufferIndex = BufferIndex.meshTexcoords.rawValue

		vertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stride = 12
		vertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepRate = 1
		vertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepFunction = .perVertex

		vertexDescriptor.layouts[BufferIndex.meshTexcoords.rawValue].stride = 8
		vertexDescriptor.layouts[BufferIndex.meshTexcoords.rawValue].stepRate = 1
		vertexDescriptor.layouts[BufferIndex.meshTexcoords.rawValue].stepFunction = .perVertex

		return vertexDescriptor
	}
}

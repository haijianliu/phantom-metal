// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: GpuObject.
class Shader {
	
	let renderPipelineState: MTLRenderPipelineState
	let vertexDescriptor: MTLVertexDescriptor
	/// TODO: use global default library and customize library option.
	let library: MTLLibrary

	init?(_ device: MTLDevice, filepath: String? = nil, _ shaderType: ShaderType = ShaderType.standard) {
		// TODO: if has filepath then load customize libraray.
		do {
			library = try device.makeLibrary(filepath: "DefaultShaders.metallib")
		} catch {
			print(error)
			return nil
		}
		
		// TODO: function name enum
		let vertexFunction = library.makeFunction(name: shaderType.vertex)
		let fragmentFunction = library.makeFunction(name: shaderType.fragment)
		vertexDescriptor = Shader.buildVertexDescriptor() // TODO: by library
		
		// TODO: automatically make vertex descriptor according to current metal library
		let pipelineDescriptor = MTLRenderPipelineDescriptor()
		pipelineDescriptor.label = "DefaultShaders" // TODO: check if using default
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

extension Shader: RenderEncodable {
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder) {
		renderCommandEncoder.setRenderPipelineState(renderPipelineState)
	}
}

extension Shader {
	// TODO: remove this
	static func buildVertexDescriptor() -> MTLVertexDescriptor {
		// Creete a Metal vertex descriptor specifying how vertices will by laid out for input into our render pipeline and how we'll layout our Model IO vertices
		let vertexDescriptor = MTLVertexDescriptor()
		
		vertexDescriptor.attributes[VertexAttribute.position.rawValue].format = MTLVertexFormat.float3
		vertexDescriptor.attributes[VertexAttribute.position.rawValue].offset = 0
		vertexDescriptor.attributes[VertexAttribute.position.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue
		
		vertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].format = MTLVertexFormat.float2
		vertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].offset = 0
		vertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].bufferIndex = BufferIndex.meshTexcoords.rawValue
		
		vertexDescriptor.attributes[VertexAttribute.normal.rawValue].format = MTLVertexFormat.float3
		vertexDescriptor.attributes[VertexAttribute.normal.rawValue].offset = 0
		vertexDescriptor.attributes[VertexAttribute.normal.rawValue].bufferIndex = BufferIndex.meshNormals.rawValue
		
		vertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stride = 12
		vertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepRate = 1
		vertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepFunction = MTLVertexStepFunction.perVertex
		
		vertexDescriptor.layouts[BufferIndex.meshTexcoords.rawValue].stride = 8
		vertexDescriptor.layouts[BufferIndex.meshTexcoords.rawValue].stepRate = 1
		vertexDescriptor.layouts[BufferIndex.meshTexcoords.rawValue].stepFunction = MTLVertexStepFunction.perVertex
		
		vertexDescriptor.layouts[BufferIndex.meshNormals.rawValue].stride = 12
		vertexDescriptor.layouts[BufferIndex.meshNormals.rawValue].stepRate = 1
		vertexDescriptor.layouts[BufferIndex.meshNormals.rawValue].stepFunction = MTLVertexStepFunction.perVertex
		
		return vertexDescriptor
	}
}

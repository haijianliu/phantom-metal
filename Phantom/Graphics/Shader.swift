// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: GpuObject.
class Shader {
	private let renderPipelineState: MTLRenderPipelineState
	
	/// An object that describes how vertex data is organized and mapped to a vertex function.
	let vertexDescriptor: MTLVertexDescriptor

	/// TODO: use global default library and customize library option.
	let library: MTLLibrary
	
	init?(_ device: MTLDevice, filepath: String? = nil, _ shaderType: ShaderType = ShaderType.standard) {
		let vertexFunction: MTLFunction
		let fragmentFunction: MTLFunction
		
		// TODO: if has filepath then load customize libraray.
		do {
			library = try device.makeLibrary(filepath: "DefaultShaders.metallib")
			vertexFunction = try library.makeFunction(name: shaderType.vertex, constantValues: shaderType.functionConstantValues)
			fragmentFunction = try library.makeFunction(name: shaderType.fragment, constantValues: shaderType.functionConstantValues)
		} catch {
			print(error)
			return nil
		}
		
		// Use vertex function reflection to creete a Metal vertex descriptor specifying how vertices will be laid out for input into the render pipeline and how the layout of Model IO vertices.
		guard let vertexAttributes = vertexFunction.vertexAttributes else { return nil }
		vertexDescriptor = MTLVertexDescriptor()
		for (index, attribute) in vertexAttributes.enumerated() {
			if attribute.isActive {
				vertexDescriptor.attributes[attribute.attributeIndex].format = attribute.attributeType.format
				vertexDescriptor.attributes[attribute.attributeIndex].offset = 0
				vertexDescriptor.attributes[attribute.attributeIndex].bufferIndex = index
				vertexDescriptor.layouts[index].stride = attribute.attributeType.stride
				vertexDescriptor.layouts[index].stepRate = 1
				vertexDescriptor.layouts[index].stepFunction = MTLVertexStepFunction.perVertex
			}
		}
		
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

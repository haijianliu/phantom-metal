// Copyright © haijian. All rights reserved.

import MetalKit

extension Shader {
	func load() {
		// TODO: if has filepath then load customize libraray.
		do {
			vertexFunction = try Application.sharedInstance.library?.makeFunction(name: shaderType.vertex, constantValues: shaderType.functionConstantValues)
			fragmentFunction = try Application.sharedInstance.library?.makeFunction(name: shaderType.fragment, constantValues: shaderType.functionConstantValues)
		} catch {
			print(error)
			return
		}
		
		// Use vertex function reflection to creete a Metal vertex descriptor specifying how vertices will be laid out for input into the render pipeline and how the layout of Model IO vertices.
		guard let vertexAttributes = vertexFunction?.vertexAttributes else { return }
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
		pipelineDescriptor = MTLRenderPipelineDescriptor()
		pipelineDescriptor.vertexDescriptor = vertexDescriptor
		pipelineDescriptor.vertexFunction = vertexFunction
		pipelineDescriptor.fragmentFunction = fragmentFunction
		
		// TODO: use render target settings.
		// TODO: though these settings are only for final render pass, may be customizable from render pipeline.
		pipelineDescriptor.label = "DefaultShaders" // TODO: check if using default. TODO: use shader name and pass name
		pipelineDescriptor.sampleCount = AntialiasingMode.multisampling4X.rawValue // TODO: muti antialias settings in material.
		pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm_srgb
		pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float_stencil8
		pipelineDescriptor.stencilAttachmentPixelFormat = .depth32Float_stencil8
		
		// TODO: reuse pipeline state.
		do {
			try renderPipelineState = Application.sharedInstance.device?.makeRenderPipelineState(descriptor: pipelineDescriptor)
		} catch {
			print("Unable to compile render pipeline state.  Error info: \(error)")
			return
		}
	}
}

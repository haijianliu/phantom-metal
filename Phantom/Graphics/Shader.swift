// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: Automatically register render behaviours to render pass by shader reflections.
// TODO: GpuObject.
class Shader {
	var shaderType = ShaderType.standard
	var renderPipelineState: MTLRenderPipelineState?
	
	/// An object that describes how vertex data is organized and mapped to a vertex function.
	var vertexDescriptor = MTLVertexDescriptor()
	var pipelineDescriptor = MTLRenderPipelineDescriptor()
	
	var vertexFunction: MTLFunction?
	var fragmentFunction: MTLFunction?
}

extension Shader: RenderEncodable {
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder) {
		guard let pipelineState = renderPipelineState else { return }
		renderCommandEncoder.setRenderPipelineState(pipelineState)
	}
}

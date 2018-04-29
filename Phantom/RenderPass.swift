// Copyright © haijian. All rights reserved.

import MetalKit

class RenderPass {
	
	var depthStencilState: MTLDepthStencilState
	var renderPassDescriptor: MTLRenderPassDescriptor?
	
	init?(mtkView: MTKView) {
		// Set device
		guard let device = mtkView.device else { return nil }
		
		// depth descriptor
		let depthStencilDescriptor = MTLDepthStencilDescriptor()
		depthStencilDescriptor.depthCompareFunction = MTLCompareFunction.less // TODO: properties
		depthStencilDescriptor.isDepthWriteEnabled = true // TODO: properties
		guard let depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor) else { return nil }
		self.depthStencilState = depthStencilState
	}
	
	// TODO: customize this function varying from render passes.
	func makeRenderCommandEncoder(commandBuffer: MTLCommandBuffer) -> MTLRenderCommandEncoder? {
		guard let renderPassDescriptor = View.main.currentRenderPassDescriptor else { return nil }
		return commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
	}
}

extension RenderPass: Encodable {
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder) {
		renderCommandEncoder.setDepthStencilState(depthStencilState)
	}
}

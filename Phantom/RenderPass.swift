// Copyright © haijian. All rights reserved.

import MetalKit

class RenderPass {
	
	var depthStencilState: MTLDepthStencilState
	
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
}

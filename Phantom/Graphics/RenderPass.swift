// Copyright © haijian. All rights reserved.

import MetalKit

class RenderPass: Drawable {
	var renderableBehaviours = ContiguousArray<Weak<Renderable>>()
	
	var depthStencilState: MTLDepthStencilState
	
	required convenience init?(device: MTLDevice) {
		let depthStencilDescriptor = MTLDepthStencilDescriptor()
		self.init(device: device, depthStencilDescriptor: depthStencilDescriptor)
	}
	
	init?(device: MTLDevice, depthStencilDescriptor: MTLDepthStencilDescriptor) {
		guard let newDepthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor) else { return nil }
		depthStencilState = newDepthStencilState
		renderableBehaviours.reserveCapacity(0xFF)
	}

	func draw(in view: MTKView, by commandBuffer: MTLCommandBuffer) { }
}

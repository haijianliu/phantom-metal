// Copyright © haijian. All rights reserved.

import MetalKit

class RenderPass: Drawable, Registrable {
	// TODO: use texture class.
	// TODO: color attachments dictionary.
	//TODO: double textures for asyc render?
	var targets = [MTLTexture]()
	
	var renderableBehaviours = ContiguousArray<Weak<Renderable>>()
	
	var renderPassDescriptor = MTLRenderPassDescriptor()
	
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

	func register() { }
	
	func draw(in view: MTKView, by commandBuffer: MTLCommandBuffer) { }
}

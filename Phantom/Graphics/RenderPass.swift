// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: mutiple settings render pass vailiation.
class RenderPass {
	
	// TODO: Add front and back face stencil properties.
	var depthWrite = true
	var compareFunction = MTLCompareFunction.less
	private var depthStencilState: MTLDepthStencilState
	
	init?(view: MTKView) {
		let depthStencilDescriptor = MTLDepthStencilDescriptor()
		depthStencilDescriptor.depthCompareFunction = compareFunction
		depthStencilDescriptor.isDepthWriteEnabled = depthWrite
		guard let newDepthStencilState = view.device?.makeDepthStencilState(descriptor: depthStencilDescriptor) else { return nil }
		depthStencilState = newDepthStencilState
	}
}

extension RenderPass: Drawable {
	func draw(in view: MTKView, by commandBuffer: MTLCommandBuffer) {
		// TODO: customize this function varying from render passes.
		guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
		guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
		
		// Start encoding and setup debug infomation
		renderEncoder.label = String(describing: self)
		// Render pass encoding.
		renderEncoder.setDepthStencilState(depthStencilState)
		
		// render behaviours.
		for renderBehaviour in Application.sharedInstance.renderBehaviours { renderBehaviour.reference?.encode(to: renderEncoder) }
		
		// End encoding.
		renderEncoder.endEncoding()
		
		// TODO: render target.
		// If rendering to core animation layer.
		if let drawable = view.currentDrawable { commandBuffer.present(drawable) }
	}
}

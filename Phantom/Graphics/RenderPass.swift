// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: mutiple settings render pass vailiation.
class RenderPass {
	
	// TODO: Add front and back face stencil properties.
	var depthWrite = true
	var compareFunction = MTLCompareFunction.less
	private var depthStencilState: MTLDepthStencilState
	
	init?(mtkView: MTKView) {
		let depthStencilDescriptor = MTLDepthStencilDescriptor()
		depthStencilDescriptor.depthCompareFunction = compareFunction
		depthStencilDescriptor.isDepthWriteEnabled = depthWrite
		guard let newDepthStencilState = mtkView.device?.makeDepthStencilState(descriptor: depthStencilDescriptor) else { return nil }
		depthStencilState = newDepthStencilState
	}
	
	// TODO: customize this function varying from render passes.
	func makeRenderCommandEncoder(commandBuffer: MTLCommandBuffer) -> MTLRenderCommandEncoder? {
		guard let renderPassDescriptor = View.main.currentRenderPassDescriptor else { return nil }
		return commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
	}
}

extension RenderPass: Drawable {
	func draw(in view: MTKView, by commandBuffer: MTLCommandBuffer) {
		guard let renderEncoder = makeRenderCommandEncoder(commandBuffer: commandBuffer) else { return }
		
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

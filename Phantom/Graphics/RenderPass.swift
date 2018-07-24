// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: mutiple settings render pass vailiation.
class RenderPass {
	
	// TODO: Add front and back face stencil properties.
	var depthWrite = true
	var compareFunction = MTLCompareFunction.less
	private var depthStencilState: MTLDepthStencilState
	
	// TODO: in metal library.
	/// Allow cpu to go 2 steps ahead GPU, before GPU finishes its current command.
	let semaphore = DispatchSemaphore(value: 3)
	
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
	func draw(in view: MTKView) {
		guard
		let commandBuffer = View.sharedInstance.commandQueue?.makeCommandBuffer(),
		let renderEncoder = makeRenderCommandEncoder(commandBuffer: commandBuffer)
		else { return }
		
		// TODO: multiple threads draw multiple queue (realtime and offline rendering).
		_ = semaphore.wait(timeout: .distantFuture)
		commandBuffer.addCompletedHandler() { _ in self.semaphore.signal() } // TODO: capture
		
		// Start encoding and setup debug infomation
		renderEncoder.label = String(describing: self)
		// Render pass encoding.
		renderEncoder.setDepthStencilState(depthStencilState)
		
		// render behaviours.
		for renderBehaviour in Application.sharedInstance.renderBehaviours { renderBehaviour.reference?.encode(to: renderEncoder) }
		
		// End encoding.
		renderEncoder.endEncoding()
		
		// If rendering to core animation layer.
		if let drawable = view.currentDrawable { commandBuffer.present(drawable) }
		
		commandBuffer.commit()
	}
}

// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: mutiple settings render pass vailiation.
class RenderPass {
	
	var depthStencilState: MTLDepthStencilState
	var renderPassDescriptor: MTLRenderPassDescriptor?
	
	// TODO: in metal library.
	/// Allow cpu to go 2 steps ahead GPU, before GPU finishes its current command.
	let semaphore = DispatchSemaphore(value: 3)
	
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

extension RenderPass: Drawable {
	func draw(in view: MTKView) {
		guard
			let commandBuffer = View.sharedInstance.commandQueue?.makeCommandBuffer(),
			let renderEncoder = makeRenderCommandEncoder(commandBuffer: commandBuffer)
		else { return }
		
		// TODO: multi-thread CPU.
		// update behaviours
		for updateBehaviour in Application.sharedInstance.updateBehaviours {
			updateBehaviour.reference?.update()
		}
		
		// TODO: multi-thread CPU to GPU.
		// TODO: multiple threads draw multiple queue (realtime and offline rendering).
		// TODO: semaphore.
		_ = semaphore.wait(timeout: .distantFuture)
		commandBuffer.addCompletedHandler() { _ in self.semaphore.signal() } // TODO: capture
		
		// Start encoding and setup debug infomation
		renderEncoder.label = String(describing: self)
		// Render pass encoding.
		renderEncoder.setDepthStencilState(depthStencilState)
		
		// render behaviours.
		for renderBehaviour in Application.sharedInstance.renderBehaviours {
			renderBehaviour.reference?.encode(to: renderEncoder)
		}
		
		// End encoding.
		renderEncoder.endEncoding()
		
		// If rendering to core animation layer.
		if let drawable = view.currentDrawable { commandBuffer.present(drawable) }
		
		commandBuffer.commit()
	}
}

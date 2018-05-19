// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: mutiple settings render pass vailiation.
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

extension RenderPass: Drawable {
	func draw(in view: MTKView) {
		guard
			let renderPass = View.sharedInstance.renderPass,
			let commandBuffer = View.sharedInstance.commandQueue?.makeCommandBuffer(),
			let renderEncoder = renderPass.makeRenderCommandEncoder(commandBuffer: commandBuffer)
			else { return }
		
		// update behaviours
		// TODO: multi-thread update
		for updateBehaviour in Application.sharedInstance.updateBehaviours {
			updateBehaviour.reference?.update()
		}
		
		// TODO: semaphore.
		//		_ = semaphore.wait(timeout: .distantFuture)
		//		commandBuffer.addCompletedHandler() { _ in self.semaphore.signal() } // TODO: capture
		
		// Start encoding and setup debug infomation
		// TODO: setup with render pass names
		renderEncoder.label = "Primary Render Encoder"
		// Render pass encoding.
		renderPass.encode(to: renderEncoder)
		
		// drawable behaviours
		// TODO: multiple threads draw multiple queue (realtime and offline rendering)
		for renderBehaviour in Application.sharedInstance.renderBehaviours {
			renderBehaviour.reference?.encode(to: renderEncoder)
		}
		
		// End encoding.
		renderEncoder.endEncoding()
		
		// If rendering to core animation layer.
		// TODO: in render pass
		if let drawable = view.currentDrawable { commandBuffer.present(drawable) }
		
		commandBuffer.commit()
	}
}

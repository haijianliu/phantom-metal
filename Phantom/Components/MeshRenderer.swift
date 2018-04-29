// Copyright © haijian. All rights reserved.

import MetalKit

public class MeshRenderer: Renderer, Drawable {
	
	public var mesh: Mesh?
	
	// TODO: can this skip some encoding phases?
	func draw(in view: MTKView) {
		// Check all the resources available.
		guard
			let commandBuffer = View.sharedInstance.commandQueue?.makeCommandBuffer(),
			let renderPassDescriptor = view.currentRenderPassDescriptor,
			let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor),
			let material = self.material,
			let depthStencilState = View.sharedInstance.renderPass?.depthStencilState,
			let mesh = self.mesh
		else { return }
			
		// TODO: wait in game object? It seems impossible.
		let semaphore = gameObject.getSemaphore()
		_ = semaphore.wait(timeout: .distantFuture)
		commandBuffer.addCompletedHandler() { _ in semaphore.signal() }

		// Start encoding and setup debug infomation
		// TODO: setup with object names
		renderEncoder.label = "Primary Render Encoder"
		renderEncoder.pushDebugGroup("Draw Box")
		// TODO: render pass encoding.
		renderEncoder.setDepthStencilState(depthStencilState)
		// Material encoding: including shader and texture encoding.
		material.encode(to: renderEncoder)
		// Game object encoding: update triple buffer.
		gameObject.encode(to: renderEncoder)
		// Mesh encoding: contents draw call encoding, which must be encoded at last (just before end encoding).
		mesh.encode(to: renderEncoder)
		// End encoding.
		renderEncoder.popDebugGroup()
		renderEncoder.endEncoding()
		
		// If rendering to core animation layer.
		// TODO: in render pass
		if let drawable = view.currentDrawable { commandBuffer.present(drawable) }
	
		commandBuffer.commit()
	}
}

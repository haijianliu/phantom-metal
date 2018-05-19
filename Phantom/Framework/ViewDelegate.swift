// Copyright © haijian. All rights reserved.

// Our platform independent renderer class

import Metal
import MetalKit

class ViewDelegate: NSObject, MTKViewDelegate {

	// TODO: only render render pass here.
	func draw(in view: MTKView) {
		
		// TODO: in render pass.
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

	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
		// TODO: Camera
		let aspect = Float(size.width) / Float(size.height)
		guard let camera: Camera = Camera.main else { return }
		camera.projectionMatrix = Math.perspective(fovyRadians: camera.fieldOfView, aspect: aspect, near: camera.nearClipPlane, far: camera.farClipPlane)
	}
}

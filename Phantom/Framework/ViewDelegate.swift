// Copyright © haijian. All rights reserved.

// Our platform independent renderer class

import Metal
import MetalKit

extension View: MTKViewDelegate {
	
	// TODO: only render render pass here.
	public func draw(in view: MTKView) {
		// Dpdatable behaviours.
		DispatchQueue.global(qos: .userInitiated).async {
			for updateBehaviour in Application.sharedInstance.updateBehaviours { updateBehaviour.reference?.update() }
		}
		// Drawable behaviours.
		DispatchQueue.global(qos: .userInteractive).sync {
			guard let commandBuffer = commandQueue?.makeCommandBuffer() else { return }
			// TODO: multiple threads draw multiple queue (realtime and offline rendering)
			_ = semaphore.wait(timeout: .distantFuture)
			commandBuffer.addCompletedHandler() { _ in self.semaphore.signal() } // TODO: capture
			// TODO: multiple rendering passes
			renderPass?.draw(in: view, by: commandBuffer)
			commandBuffer.commit()
		}
	}

	public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
		// TODO: Camera
		let aspect = Float(size.width) / Float(size.height)
		guard let camera: Camera = Camera.main else { return }
		camera.projectionMatrix = Math.perspective(fovyRadians: camera.fieldOfView, aspect: aspect, near: camera.nearClipPlane, far: camera.farClipPlane)
	}
}

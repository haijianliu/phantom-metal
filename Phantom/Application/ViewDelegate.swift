// Copyright © haijian. All rights reserved.

// Our platform independent renderer class

import Metal
import MetalKit

// TODO: [SCNView](https://developer.apple.com/documentation/scenekit/scnview)
// TODO: UX refactor.
/// Provides access to an application view for rendering operations.
class ViewDelegate: NSObject, MTKViewDelegate {
	// TODO: multiple command queues
	var commandQueue: MTLCommandQueue?
	// TODO: in metal library.
	/// Allow cpu to go 2 steps ahead GPU, before GPU finishes its current command.
	let semaphore = DispatchSemaphore(value: 3)
	
	private var drawables = ContiguousArray<Weak<Drawable>>()
	
	func addRenderPass(_ renderPass: RenderPass) {
		drawables.append(Weak(reference: renderPass))
	}
	
	override init() {
		super.init()
		drawables.reserveCapacity(0xF)
	}
	
	// TODO: only render render pass here.
	public func draw(in view: MTKView) {
		// Updatable behaviours.
		DispatchQueue.global(qos: .userInitiated).async {
			Application.sharedInstance.scene?.update()
		}
		// Drawable behaviours.
		DispatchQueue.global(qos: .userInteractive).sync {
			guard let commandBuffer = commandQueue?.makeCommandBuffer() else { return }
			// TODO: multiple threads draw multiple queue (realtime and offline rendering)
			_ = semaphore.wait(timeout: .distantFuture)
			commandBuffer.addCompletedHandler() { _ in self.semaphore.signal() } // TODO: capture
			for drawable in drawables { drawable.reference?.draw(in: view, by: commandBuffer) }
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

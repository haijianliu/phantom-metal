// Copyright © haijian. All rights reserved.

// Our platform independent renderer class

import Metal
import MetalKit

// TODO: [SCNView](https://developer.apple.com/documentation/scenekit/scnview)
// TODO: UX refactor.
// TODO: view descriptor.
/// Provides access to an application view for rendering operations, and defines render passes.
class ViewDelegate: NSObject, MTKViewDelegate {
	// TODO: multiple command queues
	var commandQueue: MTLCommandQueue?
	// TODO: in metal library.
	/// Allow cpu to go 2 steps ahead GPU, before GPU finishes its current command.
	let semaphore = DispatchSemaphore(value: 3)

	/// Renderpass references.
	var renderPasses = [String: RenderPass]()
	/// Renderpass drawable behaviours.
	private var drawables = ContiguousArray<Weak<Drawable>>()

	override init() {
		super.init()
		drawables.reserveCapacity(0xF)
	}

	/// Initialize renderpasses.
	func launch() {
		// TODO: order.
		guard let shadowMapRenderPass: ShadowMapRenderPass = addRenderPass() else { return }
		guard let mainRenderPass: MainRenderPass = addRenderPass() else { return }
		guard let _: PostEffectRenderPass = addRenderPass() else { return }

		// Set shadowmap renderpass target to main renderpass texture.
		// TODO: target type?
		mainRenderPass.shadowMap = shadowMapRenderPass.targets[0].makeTextureView(pixelFormat: .depth32Float)
	}

	/// Add renderpasses.
	private func addRenderPass<RenderPassType: RenderPass>() -> RenderPassType? {
		let typeName = String(describing: RenderPassType.self)
		if renderPasses[typeName] == nil {
			guard let device = Application.sharedInstance.device else { return nil }
			guard let renderPass = RenderPassType(device: device) else { return nil }
			renderPasses[typeName] = renderPass
			renderPass.register()
			drawables.append(Weak(reference: renderPass))
		}
		return renderPasses[typeName] as? RenderPassType
	}

	// TODO: only render render pass here.
	public func draw(in view: MTKView) {
		// Updatable behaviours.
		// TODO: support triple buffer dispatch updates.
//		DispatchQueue.global(qos: .userInitiated).async {
			Application.sharedInstance.scene?.update()
//		}
		// Drawable behaviours.
//		DispatchQueue.main.async {
			guard let commandBuffer = self.commandQueue?.makeCommandBuffer() else { return }
			// TODO: multiple threads draw multiple queue (realtime and offline rendering)
			_ = self.semaphore.wait(timeout: .distantFuture)
			commandBuffer.addCompletedHandler() { _ in self.semaphore.signal() } // TODO: capture
			for drawable in self.drawables { drawable.reference?.draw(in: view, by: commandBuffer) }
			// TODO: render target.
			// If rendering to core animation layer.
			if let currentDrawable = view.currentDrawable { commandBuffer.present(currentDrawable) }
			commandBuffer.commit()
//		}
	}

	public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
		// TODO: Camera.
		let aspect = Float(size.width) / Float(size.height)
		guard let camera: Camera = Camera.main else { return }
		camera.projectionMatrix = Math.perspective(fovyRadians: camera.fieldOfView, aspect: aspect, near: camera.nearClipPlane, far: camera.farClipPlane)
		// TODO: refactor.
		guard let shadow: Camera = Camera.shadow else { return }
		shadow.projectionMatrix = Math.perspective(fovyRadians: shadow.fieldOfView, aspect: aspect, near: shadow.nearClipPlane, far: shadow.farClipPlane)

		renderPasses[String(describing: PostEffectRenderPass.self)]?.isViewDirty = true
	}
}

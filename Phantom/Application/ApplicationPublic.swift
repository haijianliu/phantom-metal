// Copyright © haijian. All rights reserved.

import MetalKit

// MARK: - Extension for public functions.
extension Application {
	/// Launch application. After launched this delegate will be released.
	///
	/// - Parameter application: An user class that confirms ApplicationDelegate protocol.
	public static func launch(application: ApplicationDelegate) {
		application.start()
		// Only for the first time, should initiate the view manually
		guard let view = Application.sharedInstance.view else { return }
		Application.sharedInstance.viewDelegate.mtkView(view, drawableSizeWillChange: view.drawableSize)
	}
	
	/// Add a mtkView to views and set it as the current active view (since only supported for one view by now)
	public static func launch(view: MTKView) {
		// Select the default device to render with.
		guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
			print("Metal is not supported on this device")
			return
		}
		Application.sharedInstance.device = defaultDevice
		
		// Set metal kit view
		view.device = defaultDevice
		view.colorPixelFormat = ShaderType.standard.colorAttachmentsPixelFormat[0]
		view.depthStencilPixelFormat = ShaderType.standard.depthAttachmentPixelFormat
		view.sampleCount = ShaderType.standard.sampleCount  // TODO: Max sampling test.
		view.clearColor = MTLClearColorMake(0.01, 0.01, 0.03, 1)
		Application.sharedInstance.view = view
		
		// TODO: This will be a Display process
		// Set MTKViewDelegate to current Renderer instance
		// TODO: multiple command queues
		Application.sharedInstance.viewDelegate.commandQueue = defaultDevice.makeCommandQueue()
		
		view.delegate = Application.sharedInstance.viewDelegate
		
		// TODO: load xml.
		// Initialize scenes.
		Application.sharedInstance.scene = Scene(device: defaultDevice)
		
		// TODO: build library according to application delegate.
		do {
			Application.sharedInstance.library = try defaultDevice.makeLibrary(filepath: "DefaultShaders.metallib")
		} catch {
			print(error)
			return
		}
		
		// Initialize renderpasses.
		// TODO: order.
		// TODO: in renderpass manager.
		guard let shadowMapRenderPass: ShadowMapRenderPass = Application.addRenderPass() else { return }
		guard let mainRenderPass: MainRenderPass = Application.addRenderPass() else { return }
		
		// Set shadowmap renderpass target to main renderpass texture.
		// TODO: target type?
		mainRenderPass.shadowMap = shadowMapRenderPass.targets[0].makeTextureView(pixelFormat: MTLPixelFormat.depth32Float)
	}
	
	// TODO: in Scene
	// TODO: when add twice.
	/// Add gameobjects to application.
	public static func addGameObject(_ gameObjcet: GameObject) {
		// Register to scene.
		// TODO: multi scene.
		Application.sharedInstance.scene?.addGameObject(gameObjcet)
		// TODO: check same?
		// TODO: leak?
		// Recurve add all children.
		for child in gameObjcet.children { addGameObject(child) }
	}
}

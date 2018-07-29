// Copyright © haijian. All rights reserved.

import MetalKit

extension Application {
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
		
		// Set metal kit view
		view.device = defaultDevice
		view.depthStencilPixelFormat = MTLPixelFormat.depth32Float_stencil8
		view.colorPixelFormat = MTLPixelFormat.bgra8Unorm_srgb
		view.sampleCount = AntialiasingMode.multisampling4X.rawValue  // TODO: Max sampling test.
		view.clearColor = MTLClearColorMake(0.01, 0.01, 0.03, 1)
		Application.sharedInstance.view = view
		
		// TODO: This will be a Display process
		// Set MTKViewDelegate to current Renderer instance
		// TODO: multiple command queues
		Application.sharedInstance.viewDelegate.commandQueue = defaultDevice.makeCommandQueue()
		// TODO: multiple rendering passes
		Application.sharedInstance.viewDelegate.renderPass = RenderPass(view: view)
		view.delegate = Application.sharedInstance.viewDelegate
		
		// Set references.
		Application.sharedInstance.view = view
		Application.sharedInstance.device = defaultDevice
	}
	
	// TODO: in Scene
	public static func addGameObject(_ gameObjcet: GameObject) {
		Application.sharedInstance.gameObjects.append(gameObjcet)
		for component in gameObjcet.components {
			if let updateBehaviour = component.value as? Updatable {
				Application.sharedInstance.updateBehaviours.append(Weak(reference: updateBehaviour))
			}
			if let renderBehaviour = component.value as? Renderable {
				Application.sharedInstance.renderBehaviours.append(Weak(reference: renderBehaviour))
			}
		}
	}
}

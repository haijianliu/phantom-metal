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
		
		// TODO: build library according to application delegate.
		do {
			Application.sharedInstance.library = try defaultDevice.makeLibrary(filepath: "DefaultShaders.metallib")
		} catch {
			print(error)
			return
		}
	}
	
	// TODO: in Scene
	// TODO: when add twice.
	/// Add gameobjects to application.
	public static func addGameObject(_ gameObjcet: GameObject) {
		// Add gameobject strong references to application.
		Application.sharedInstance.gameObjects.append(gameObjcet)
		// If there is mesh renderer attached then load shaders and meshes.
		if let meshRenderer: MeshRenderer = gameObjcet.getComponent() {
			meshRenderer.material.shader.load()
			meshRenderer.mesh.load(from: meshRenderer.material.shader.vertexDescriptor)
		}
		// Add behaviour weak references to application.
		for component in gameObjcet.components {
			// TODO: registerable.
			if let updatableBehaviour = component.value as? Updatable {
				Application.sharedInstance.updatableBehaviours.append(Weak(reference: updatableBehaviour))
			}
			if let renderableBehaviour = component.value as? Renderable {
				Application.sharedInstance.renderableBehaviours.append(Weak(reference: renderableBehaviour))
			}
			if let lightableBehaviour = component.value as? Lightable {
				Application.sharedInstance.lightableBehaviours.append(Weak(reference: lightableBehaviour))
			}
		}
	}
}

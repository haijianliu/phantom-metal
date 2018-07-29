// Copyright © haijian. All rights reserved.

import MetalKit

/// The single instance of application interface that manages game resources, event loop and status.
public class Application {
	// TODO: no singleton
	static let sharedInstance: Application = Application()
	// TODO: initialize capacity.
	private init() {
		// TODO: use library settings.
		updateBehaviours.reserveCapacity(0xFF)
		renderBehaviours.reserveCapacity(0xFF)
	}
	
	weak var view: MTKView?
	weak var device: MTLDevice?
	
	// TODO: remove
	/// MTKViewDelegat reference holder.
	private var viewDelegate = ViewDelegate()
	
	/// The only game object references holder.
	private var gameObjects = [GameObject]()
	
	// TODO: clean up nil reference.
	/// A [contiguous array](http://jordansmith.io/on-performant-arrays-in-swift/) to update behaviour weak reference list in real time, reserving a capacity of 256 elements.
	var updateBehaviours = ContiguousArray<Weak<Updatable>>()
	/// A [contiguous array](http://jordansmith.io/on-performant-arrays-in-swift/) to update behaviours weak reference list in real time, reserving a capacity of 256 elements.
	var renderBehaviours = ContiguousArray<Weak<Renderable>>()

	public static func launch(application: ApplicationDelegate) {
		application.start()
		// Only for the first time, should initiate the view manually
		guard let view = Application.sharedInstance.view else { return }
		Application.sharedInstance.viewDelegate.mtkView(view, drawableSizeWillChange: view.drawableSize)
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
}

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
	
	// Delegate
	weak var delegate: ApplicationDelegate?
	
	/// The only game object references holder.
	private var gameObjects = [GameObject]()
	
	// TODO: clean up nil reference.
	/// A [contiguous array](http://jordansmith.io/on-performant-arrays-in-swift/) to update behaviour weak reference list in real time, reserving a capacity of 256 elements.
	var updateBehaviours = ContiguousArray<Weak<Updatable>>()
	/// A [contiguous array](http://jordansmith.io/on-performant-arrays-in-swift/) to update behaviours weak reference list in real time, reserving a capacity of 256 elements.
	var renderBehaviours = ContiguousArray<Weak<Renderable>>()

	public static func launch(application: ApplicationDelegate) {
		Application.sharedInstance.delegate = application
		Application.sharedInstance.delegate?.start()
		// Only for the first time, should initiate the view manually
		View.sharedInstance.mtkView(View.main, drawableSizeWillChange: View.main.drawableSize)
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
	public static func launch(mtkView: MTKView) {
		
		// Select the default device to render with.
		guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
			print("Metal is not supported on this device")
			return
		}
		
		// Set metal kit view
		mtkView.device = defaultDevice
		mtkView.depthStencilPixelFormat = MTLPixelFormat.depth32Float_stencil8
		mtkView.colorPixelFormat = MTLPixelFormat.bgra8Unorm_srgb
		mtkView.sampleCount = AntialiasingMode.multisampling4X.rawValue  // TODO: Max sampling test.
		mtkView.clearColor = MTLClearColorMake(0.01, 0.01, 0.03, 1)
		View.sharedInstance.mtkView = mtkView
		
		// TODO: multiple command queues
		if View.sharedInstance.commandQueue == nil {
			View.sharedInstance.commandQueue = mtkView.device?.makeCommandQueue()
		}
		// TODO: multiple rendering passes
		if View.sharedInstance.renderPass == nil {
			View.sharedInstance.renderPass = RenderPass(mtkView: mtkView)
		}
		
		// TODO: This will be a Display process
		// Set MTKViewDelegate to current Renderer instance
		View.main.delegate = View.sharedInstance
	}
}

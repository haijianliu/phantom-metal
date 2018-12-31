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
	public static func launch(view: MTKView, descriptor: ViewDescriptor = ViewDescriptor()) {
		// Select the default device to render with.
		guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
			print("Metal is not supported on this device")
			return
		}
		Application.sharedInstance.device = defaultDevice

		// Set MTKView.
		// TODO: refactor.
		view.device = defaultDevice
		// TODO: use this view descriptor color format to set resolve color target format.
		view.colorPixelFormat = descriptor.colorPixelFormat
		view.depthStencilPixelFormat = descriptor.depthStencilPixelFormat
		// TODO: Max sampling test.
		view.sampleCount = descriptor.sampleCount
		view.clearColor = descriptor.clearColor
		view.clearDepth = descriptor.clearDepth
		view.clearStencil = descriptor.clearStencil
		view.framebufferOnly = false
		#if os(iOS)
		view.isMultipleTouchEnabled = descriptor.isMultipleTouchEnabled
		#endif
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
		Application.sharedInstance.library = defaultDevice.makeDefaultLibrary()

		// Initialize renderpasses.
		Application.sharedInstance.viewDelegate.launch()
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

	#if os(iOS)

	// TODO: inout parameters
	// https://github.com/apple/swift-evolution/blob/master/proposals/0003-remove-var-parameters.md

	/// Tells this object that one or more new touches occurred in a view or window.
	///
	/// - Parameters:
	///   - touches: A set of UITouch instances that represent the touches for the starting phase of the event, which is represented by event.
	///   - event: The event to which the touches belong.
	public static func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		Application.sharedInstance.scene?.touchesBegan(touches, with: event)
	}

	/// Tells the responder when one or more touches associated with an event changed.
	///
	/// - Parameters:
	///   - touches: A set of UITouch instances that represent the touches for the starting phase of the event, which is represented by event.
	///   - event: The event to which the touches belong.
	public static func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		Application.sharedInstance.scene?.touchesMoved(touches, with: event)
	}

	/// Tells the responder when one or more fingers are raised from a view or window.
	///
	/// - Parameters:
	///   - touches: A set of UITouch instances that represent the touches for the starting phase of the event, which is represented by event.
	///   - event: The event to which the touches belong.
	public static func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		Application.sharedInstance.scene?.touchesEnded(touches, with: event)
	}

	/// Tells the responder when a system event (such as a system alert) cancels a touch sequence.
	///
	/// - Parameters:
	///   - touches: A set of UITouch instances that represent the touches for the starting phase of the event, which is represented by event.
	///   - event: The event to which the touches belong.
	public static func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		Application.sharedInstance.scene?.touchesCancelled(touches, with: event)
	}

	#endif
}

// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: [SCNView](https://developer.apple.com/documentation/scenekit/scnview)
// TODO: UX refactor.
/// Provides access to an application view for rendering operations.
///
/// Multi-view rendering is unavailable by now
public class View : NSObject {
	// TODO: no singleton?
	/// Singleton
	static let sharedInstance: View = View()
	private override init() {}
	
	weak var mtkView: MTKView?
	
	// TODO: multiple command queues
	var commandQueue: MTLCommandQueue?
	// TODO: in metal library.
	/// Allow cpu to go 2 steps ahead GPU, before GPU finishes its current command.
	let semaphore = DispatchSemaphore(value: 3)
	// TODO: multiple rendering passes. only store protoco. reference in application.
	var renderPass: RenderPass?
}

extension View {
	/// Main view.
	/// (Force wrapped. If there is not one single view, this will get a run time error)
	static var main: MTKView {
		// guard let currentIndex = Display.sharedInstance.currentIndex else { return nil }
		return View.sharedInstance.mtkView!
	}
}

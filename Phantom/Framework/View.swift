// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: UX refactor.
/// Provides access to an application view for rendering operations.
///
/// Multi-view rendering is unavailable by now
public class View {

	/// Singleton
	static let sharedInstance: View = View()
	private init() {}

	/// The list of currently connected views. Contains at least one (main) view.
	private var views = [MTKView]()
	private var currentViewIndex: Int?

	private var depthStencilPixelFormat = MTLPixelFormat.depth32Float_stencil8
	private var colorPixelFormat = MTLPixelFormat.bgra8Unorm_srgb
	// TODO: Max sampling test.
	private var antialiasingMode: AntialiasingMode = AntialiasingMode.multisampling4X

	// TODO: multiple command queues
	var commandQueue: MTLCommandQueue?
	// TODO: multiple rendering passes
	var renderPass: RenderPass?
}

// TODO: [SCNView](https://developer.apple.com/documentation/scenekit/scnview)
extension View {
	/// Main view.
	/// (Force wrapped. If there is not one single view, this will get a run time error)
	static var main: MTKView {
		// guard let currentIndex = Display.sharedInstance.currentIndex else { return nil }
		let index = View.sharedInstance.currentViewIndex!
		return View.sharedInstance.views[index]
	}

	/// Add a mtkView to views and set it as the current active view (since only supported for one view by now)
	public static func addView(mtkView: MTKView) {

		// Select the default device to render with.
		guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
			print("Metal is not supported on this device")
			return
		}

		// Set metal kit view
		mtkView.device = defaultDevice
		mtkView.depthStencilPixelFormat = View.sharedInstance.depthStencilPixelFormat
		mtkView.colorPixelFormat = View.sharedInstance.colorPixelFormat
		mtkView.sampleCount = View.sharedInstance.antialiasingMode.rawValue
		// TODO: clear color property.
		mtkView.clearColor = MTLClearColorMake(0.01, 0.01, 0.03, 1)
		View.sharedInstance.views.append(mtkView)
		View.sharedInstance.currentViewIndex = View.sharedInstance.views.startIndex

		// TODO: multiple command queues
		if View.sharedInstance.commandQueue == nil {
			View.sharedInstance.commandQueue = mtkView.device?.makeCommandQueue()
		}
		// TODO: multiple rendering passes
		if View.sharedInstance.renderPass == nil {
			View.sharedInstance.renderPass = RenderPass(mtkView: mtkView)
		}
	}
}

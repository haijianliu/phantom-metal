// Copyright © haijian. All rights reserved.

import MetalKit

/// Provides access to an application view for rendering operations.
///
/// Multi-display rendering is unavailable by now
public class Display {
	
	/// Singleton
	static let sharedInstance: Display = Display()
	private init() {}
	
	/// The list of currently connected Displays. Contains at least one (main) display.
	private var displays = [MTKView]()
	private var currentDisplayIndex: Int?
	
	private var depthStencilPixelFormat = MTLPixelFormat.depth32Float_stencil8
	private var colorPixelFormat = MTLPixelFormat.bgra8Unorm_srgb
	private var sampleCount: Int = 1 // TODO: enum
	
	/// Main Display.
	/// (Force wrapped. If there is not a display, this will get a run time error)
	static var main: MTKView {
		// guard let currentIndex = Display.sharedInstance.currentIndex else { return nil }
		let index = Display.sharedInstance.currentDisplayIndex!
		return Display.sharedInstance.displays[index]
	}
	
	/// Add a mtkView to displays and set it as the current active display (since only supported for one display by now)
	public static func addDisplay(mtkView: MTKView) {
		
		// Select the default device to render with.
		guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
			print("Metal is not supported on this device")
			return
		}
		
		// Set metal kit view
		mtkView.device = defaultDevice
		mtkView.depthStencilPixelFormat = Display.sharedInstance.depthStencilPixelFormat
		mtkView.colorPixelFormat = Display.sharedInstance.colorPixelFormat
		mtkView.sampleCount = Display.sharedInstance.sampleCount
		Display.sharedInstance.displays.append(mtkView)
		Display.sharedInstance.currentDisplayIndex = Display.sharedInstance.displays.startIndex
	}
}

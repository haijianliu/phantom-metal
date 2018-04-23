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
	
	/// Main Display.
	/// (Force wrapped. If there is not a display, this will get a run time error)
	static var main: MTKView {
		// guard let currentIndex = Display.sharedInstance.currentIndex else { return nil }
		let index = Display.sharedInstance.currentDisplayIndex!
		return Display.sharedInstance.displays[index]
	}
	
	/// Add a mtkView to displays and set it as the current active display (since only supported for one display by now)
	public static func addDisplay(mtkView: MTKView) {
		Display.sharedInstance.displays.append(mtkView)
		Display.sharedInstance.currentDisplayIndex = Display.sharedInstance.displays.startIndex
	}
}

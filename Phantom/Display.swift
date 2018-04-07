// Copyright © haijian. All rights reserved.

import MetalKit

class Display {
	
	/// Singleton
	static let sharedInstance: Display = Display()
	private init() {}
	
	/// The list of currently connected Displays. Contains at least one (main) display.
	private var displays = [MTKView]()
	private var currentIndex: Int?
	
	/// Main Display.
	static var main: MTKView? {
		guard let currentIndex = Display.sharedInstance.currentIndex else { return nil }
		return Display.sharedInstance.displays[currentIndex]
	}
	
	/// Add a mtkView to displays and set it as the current active display (since only supported for one display by now)
	static func addDisplay(mtkView: MTKView) {
		Display.sharedInstance.displays.append(mtkView)
		Display.sharedInstance.currentIndex = Display.sharedInstance.displays.startIndex
	}
}

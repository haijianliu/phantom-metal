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
}

// Copyright © haijian. All rights reserved.

import Cocoa
import MetalKit

/// macOS specific view controller
class GameViewController: NSViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Create Metalkit view
		guard let mtkView = self.view as? MTKView else {
			print("View attached to GameViewController is not an MTKView")
			return
		}
		
		// Select the default device to render with.
		guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
			print("Metal is not supported on this device")
			return
		}
		
		// Set metal device
		mtkView.device = defaultDevice
		
		// add this mtkview and set it as the current active display
		Display.addDisplay(mtkView: mtkView)
	}
}

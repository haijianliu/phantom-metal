// Copyright © haijian. All rights reserved.

import Cocoa
import MetalKit
import PhantomKit

/// macOS specific view controller
class GameViewController: NSViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Create Metalkit view
		guard let mtkView = self.view as? MTKView else {
			print("View attached to GameViewController is not an MTKView")
			return
		}
		
		// Add this mtkview and set it as the current active display
		View.addView(mtkView: mtkView)
	}
}

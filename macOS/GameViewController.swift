// Copyright © haijian. All rights reserved.

import Cocoa
import MetalKit

// Our macOS specific view controller
class GameViewController: NSViewController {

	var application: Application?

	override func viewDidLoad() {
		super.viewDidLoad()

		guard let mtkView = self.view as? MTKView else {
			print("View attached to GameViewController is not an MTKView")
			return
		}

		application = Application.init(mtkView: mtkView)
		guard (application != nil)  else {
			print("View attached to GameViewController is not an MTKView")
			return
		}
	}
}

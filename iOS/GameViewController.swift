// Copyright © haijian. All rights reserved.

import UIKit
import MetalKit

// Our iOS specific view controller
class GameViewController: UIViewController {

	var application: Application?

	override func viewDidLoad() {
		super.viewDidLoad()

		guard let mtkView = self.view as? MTKView else {
			print("View attached to GameViewController is not an MTKView")
			return
		}

		application = Application(mtkView: mtkView)
		guard (application != nil)  else {
			print("View attached to GameViewController is not an MTKView")
			return
		}
	}
}

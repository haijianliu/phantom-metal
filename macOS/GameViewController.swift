// Copyright © haijian. All rights reserved.

import Cocoa
import MetalKit

// Our macOS specific view controller
class GameViewController: NSViewController {
	var renderer: Renderer?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let mtkView = self.view as? MTKView else {
			print("View attached to GameViewController is not an MTKView")
			return
		}
		
		mtkView.device = MetalDevice.sharedInstance.device

		guard let newRenderer = Renderer(metalKitView: mtkView) else {
			print("Renderer cannot be initialized")
			return
		}
		
		renderer = newRenderer
		
		renderer?.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
		
		mtkView.delegate = renderer
	}

}

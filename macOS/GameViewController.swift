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
		
		// Select the device to render with.  We choose the default device
		guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
			print("Metal is not supported on this device")
			return
		}
		
		mtkView.device = defaultDevice
		
		let test = MetalDevice.sharedInstance
				let test3 = MetalDevice.sharedInstance
//		MetalDevice.sharedInstance = test

		
		guard let newRenderer = Renderer(metalKitView: mtkView) else {
			print("Renderer cannot be initialized")
			return
		}
		
		renderer = newRenderer
		
		renderer?.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
		
		mtkView.delegate = renderer
	}

}

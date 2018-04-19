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
		
		// Select the default device to render with.
		guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
			print("Metal is not supported on this device")
			return
		}
		
		// Set metal kit view
		mtkView.device = defaultDevice
		mtkView.depthStencilPixelFormat = MTLPixelFormat.depth32Float_stencil8
		mtkView.colorPixelFormat = MTLPixelFormat.bgra8Unorm_srgb
		mtkView.sampleCount = 1
		
		// add this mtkview and set it as the current active display
		Display.addDisplay(mtkView: mtkView)
	}
}

// Copyright © haijian. All rights reserved.

import UIKit
import MetalKit
import PhantomTouchKit

// Our iOS specific view controller
class GameViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Create Metalkit view
		guard let mtkView = self.view as? MTKView else {
			print("View attached to GameViewController is not an MTKView")
			return
		}
		
		var descriptor = ViewDescriptor()
		descriptor.colorPixelFormat = .bgra8Unorm_srgb
		descriptor.depthStencilPixelFormat = .depth32Float_stencil8
		// TODO: setup posteffect.
		descriptor.usePostEffect = true
		
		// Add this mtkview and set it as the current active display
		Application.launch(view: mtkView, descriptor: descriptor)
		
		let sampleApplication = SampleApplication()
		Application.launch(application: sampleApplication)
	}
}

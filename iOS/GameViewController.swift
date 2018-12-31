// Copyright © haijian. All rights reserved.

import UIKit
import MetalKit
import PhantomKit

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

		// Launch sample application.
		let sampleApplication = SampleApplication()
		Application.launch(application: sampleApplication)
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		Application.touchesBegan(touches, with: event)
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		Application.touchesMoved(touches, with: event)
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		Application.touchesEnded(touches, with: event)
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesCancelled(touches, with: event)
		Application.touchesCancelled(touches, with: event)
	}
}

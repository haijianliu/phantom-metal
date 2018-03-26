// Copyright © haijian. All rights reserved.

import MetalKit

class Application {

	var mtkView: MTKView
	var renderer: Renderer?

	init?(mtkView: MTKView) {
		self.mtkView = mtkView

		// Select the device to render with.  We choose the default device
		guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
			print("Metal is not supported on this device")
			return
		}
		mtkView.device = defaultDevice

		renderer = Renderer(metalKitView: mtkView)
		guard (renderer != nil) else {
			print("Renderer cannot be initialized")
			return
		}
		renderer?.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
		mtkView.delegate = renderer
	}
}

// Copyright © haijian. All rights reserved.

class Application {
	
	var renderer: Renderer?

	func launch() {
		// Create Renderer
		guard let newRenderer = Renderer(mtkView: Display.main) else {
			print("Renderer cannot be initialized")
			return
		}
		renderer = newRenderer
		
		// TODO: This will be a Display process
		// Set MTKViewDelegate to current Renderer instance
		Display.main.delegate = renderer

		// Only for the first time, should initiate the view manually
		renderer?.mtkView(Display.main, drawableSizeWillChange: Display.main.drawableSize)
	}
}

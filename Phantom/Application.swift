// Copyright © haijian. All rights reserved.

class Application {
	
	var renderer: Renderer?
	
	var gameObjects = [GameObject]()
	

	func launch() {
		// Create Renderer
		guard let newRenderer = Renderer(mtkView: Display.main) else {
			print("Renderer cannot be initialized")
			return
		}
		renderer = newRenderer
		

		// GameObject
		let gameObject = GameObject()
		// MeshRenderer
		let meshRenderer: MeshRenderer? = gameObject.addComponent()
		// Attach Mesh
		guard let mesh = Mesh() else { return }
		meshRenderer?.mesh = mesh
		// Attach Texture
		// Texture
		let texture = Texture()
		do {
			texture.mtlTexture = try Texture.load(textureName: "UV_Grid_Sm")
		} catch {
			print("Unable to load texture. Error info: \(error)")
			return
		}
		meshRenderer?.texture = texture
		// Add GameObject
		gameObjects.append(gameObject)
		
		renderer?.gameObject = gameObject
		
		// TODO: This will be a Display process
		// Set MTKViewDelegate to current Renderer instance
		Display.main.delegate = renderer
		
		// Only for the first time, should initiate the view manually
		renderer?.mtkView(Display.main, drawableSizeWillChange: Display.main.drawableSize)
		
		
	}
}

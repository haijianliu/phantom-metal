// Copyright © haijian. All rights reserved.

public class Application {
	
	/// Singleton
	static let sharedInstance: Application = Application()
	private init() {}
	
	var renderer: Renderer?
	var gameObjects = [GameObject]()

	public static func launch() {
		Application.sharedInstance.createGameObjects()
		Application.sharedInstance.createMainCamera()
		Application.sharedInstance.createRenderer()
	}
	
	private func createGameObjects() {
		// GameObject
		guard let gameObject = GameObject() else { return }
		// Transform
		guard let _: Transform = gameObject.addComponent() else { return }
		// MeshRenderer
		guard let meshRenderer: MeshRenderer = gameObject.addComponent() else { return }
		// Attach Mesh
		guard let mesh = Mesh() else { return }
		meshRenderer.mesh = mesh
		// Attach Texture
		guard let texture = Texture(name: "UV_Grid_Sm") else { return }
		meshRenderer.texture = texture
		// Add GameObject
		gameObjects.append(gameObject)
	}
	
	private func createMainCamera() {
		// GameObject
		guard let gameObject = GameObject() else { return }
		// Transform
		guard let _: Transform = gameObject.addComponent() else { return }
		// Camera
		guard let _: Camera = gameObject.addComponent() else { return }
		gameObject.tag = .mainCamera // TODO: set mainCamera before add a camera component
		// Add GameObject
		gameObjects.append(gameObject)
	}
	
	private func createRenderer() {
		// Create Renderer
		guard let newRenderer = Renderer(mtkView: Display.main) else {
			print("Renderer cannot be initialized")
			return
		}
		newRenderer.application = self
		renderer = newRenderer
		
		// TODO: This will be a Display process
		// Set MTKViewDelegate to current Renderer instance
		Display.main.delegate = renderer
		
		// Only for the first time, should initiate the view manually
		renderer?.mtkView(Display.main, drawableSizeWillChange: Display.main.drawableSize)
	}
}

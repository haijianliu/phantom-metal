// Copyright © haijian. All rights reserved.

import PhantomKit

class SampleApplication: ApplicationDelegate {
	func start() {
		createGameObjects()
		createMainCamera()
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
		addGameObject(gameObject)
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
		addGameObject(gameObject)
	}
	
}
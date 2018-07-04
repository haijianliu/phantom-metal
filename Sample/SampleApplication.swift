// Copyright © haijian. All rights reserved.

import PhantomKit

class SampleApplication: ApplicationDelegate {
	func start() {
		createGameObjects(position: Vector3(x: -3, y: 0, z: 0))
		createGameObjects(position: Vector3(x:  3, y: 0, z: 0))
		createMainCamera()
	}
	
	private func createGameObjects(position: Vector3) {
		// GameObject
		guard let gameObject = GameObject() else { return }
		// Transform
		gameObject.transform.position = position
		// MeshRenderer
		guard let meshRenderer: MeshRenderer = gameObject.addComponent() else { return }
		// Attach material
		let material = Material()
		guard let shader = Shader() else { return }
		guard let texture = Texture(name: "UV_Grid_Sm") else { return }
		material.texture = texture
		material.shader = shader
		meshRenderer.material = material
		// Attach Mesh.
		// TODO: automatically link mesh and vertex descriptor from shader when attach mesh to mesh renderer.
		guard let mesh = Mesh(shader: shader) else { return }
		meshRenderer.mesh = mesh
		// SampleBehaviour
		guard let _: SampleBehaviour = gameObject.addComponent() else { return }
		// Add GameObject
		Application.addGameObject(gameObject)
	}
	
	private func createMainCamera() {
		// GameObject
		guard let gameObject = GameObject() else { return }
		// Camera
		guard let _: Camera = gameObject.addComponent() else { return }
		// Transform.
		gameObject.transform.position.z = -8.0;
		// Add GameObject
		Application.addGameObject(gameObject)
	}
}

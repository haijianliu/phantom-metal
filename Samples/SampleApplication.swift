// Copyright © haijian. All rights reserved.

import PhantomKit

class SampleApplication: ApplicationDelegate {
	func start() {

		// Create cube.
		cube: do {
			// GameObject
			guard let gameObject = GameObject.createCube(withDimensions: Vector3(2, 2, 2)) else { break cube }
			// Transform
			gameObject.transform.position = Vector3(x: 2.5, y: 2.5, z: 0)
			// Set texture
			gameObject.material?.texture = Texture(name: "UV_Grid_Sm")
			// SampleBehaviour
			guard let _: SampleBehaviour = gameObject.addComponent() else { break cube }
			// Add GameObject
			Application.addGameObject(gameObject)
		}

		// Create plane.
		plane: do {
			// GameObject
			guard let gameObject = GameObject.createPlane(withDimensions: Vector2(20, 20), segments: Uint2(20, 20)) else { break plane }
			// Set texture
			gameObject.material?.texture = Texture(name: "UV_Grid_Sm")
			// SampleBehaviour
			guard let _: SampleBehaviour = gameObject.addComponent() else { break plane }
			// Add GameObject
			Application.addGameObject(gameObject)
		}

		// Create camera.
		camera: do {
			// GameObject
			guard let gameObject = GameObject() else { break camera }
			// Camera
			guard let _: Camera = gameObject.addComponent() else { break camera }
			// Transform.
			gameObject.transform.position = Vector3(0, 10, 10);
			// Add GameObject
			Application.addGameObject(gameObject)
		}
	}
}

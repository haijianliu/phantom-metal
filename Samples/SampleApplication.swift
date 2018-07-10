// Copyright © haijian. All rights reserved.

import PhantomKit

class SampleApplication: ApplicationDelegate {
	func start() {

		// Create cube.
		cube: do {
			// GameObject
			guard let gameObject = GameObject.createCube(withDimensions: Vector3(2, 2, 2)) else { break cube }
			// Transform
			gameObject.transform.position = Vector3(x: -3, y: 0, z: 0)
			// SampleBehaviour
			guard let _: SampleBehaviour = gameObject.addComponent() else { break cube }
			// Add GameObject
			Application.addGameObject(gameObject)
		}

		// Create plane.
		plane: do {
			// GameObject
			guard let gameObject = GameObject.createPlane() else { break plane }
			// Set texture
			gameObject.material?.texture = Texture(name: "UV_Grid_Sm")
			// Transform
			gameObject.transform.position = Vector3(x: 3, y: 0, z: 0)
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
			gameObject.transform.position.z = -8.0;
			// Add GameObject
			Application.addGameObject(gameObject)
		}
	}
}

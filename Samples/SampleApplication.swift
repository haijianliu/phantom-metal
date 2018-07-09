// Copyright © haijian. All rights reserved.

import PhantomKit

class SampleApplication: ApplicationDelegate {
	func start() {

		// Create cube.
		do {
			// GameObject
			guard let gameObject = GameObject.createCube(withDimensions: Vector3(2, 2, 2)) else { return }
			// Transform
			gameObject.transform.position = Vector3(x: -3, y: 0, z: 0)
			// SampleBehaviour
			guard let _: SampleBehaviour = gameObject.addComponent() else { return }
			// Add GameObject
			Application.addGameObject(gameObject)
		}

		// Create plane.
		do {
			// GameObject
			guard let gameObject = GameObject.createPlane() else { return }
			// Set texture
			gameObject.material?.texture = Texture(name: "UV_Grid_Sm")
			// Transform
			gameObject.transform.position = Vector3(x: 3, y: 0, z: 0)
			// SampleBehaviour
			guard let _: SampleBehaviour = gameObject.addComponent() else { return }
			// Add GameObject
			Application.addGameObject(gameObject)
		}

		// Create camera.
		do {
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
}

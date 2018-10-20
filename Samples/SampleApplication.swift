// Copyright © haijian. All rights reserved.

import PhantomKit

class SampleApplication: ApplicationDelegate {
	func start() {
		// Create cube.
		cube: do {
			guard let gameObject = GameObject.createBox(withDimensions: Vector3(2, 2, 2)) else { break cube }
			gameObject.transform.position = Vector3(x: 2.5, y: 2.5, z: 0)
			gameObject.material?.texture = Texture(name: "UV_Grid_Lrg", type: TextureType.color) // Set material.
			guard let _: SampleTouchBehaviour = gameObject.addComponent() else { break cube }
			Application.addGameObject(gameObject) // Register to renderer.
		}

		// Create plane.
		plane: do {
			guard let gameObject = GameObject.createPlane(withDimensions: Vector2(20, 20), segments: Uint2(20, 20)) else { break plane }
			gameObject.material?.texture = Texture(name: "UV_Grid_Sm", type: TextureType.color) // Set texture.
			gameObject.material?.fillMode = .lines // Set fill mode.
			Application.addGameObject(gameObject) // Register to renderer.
		}
		
		// Create ellipsoid.
		ellipsoid: do {
			guard let gameObject = GameObject.createEllipsoid(shaderType: ShaderType.normalColor) else { break ellipsoid }
			gameObject.transform.position = Vector3(x: -2.5, y: 2.5, z: 0)
			gameObject.transform.scale = Vector3(1.4)
			Application.addGameObject(gameObject) // Register to renderer.
		}
		
		// Create camera.
		camera: do {
			// Root gameobject.
			guard let gameObject = GameObject() else { break camera }
			gameObject.transform.position = Vector3(0, 0, 0) // Transform.
			guard let _: SampleBehaviour = gameObject.addComponent() else { break camera }
			// Camera child gameobject attached to root gameobject.
			guard let cameraObject = GameObject() else { break camera } // TODO: GameObject.createCamera(main???).
			guard let _: Camera = cameraObject.addComponent() else { break camera }
			cameraObject.transform.position = Vector3(0, 10, 10) // Transform.
			gameObject.addChild(cameraObject) // Add camera node to root gameobject.
			cameraObject.tag = .mainCamera
			// Add GameObject
			Application.addGameObject(gameObject) // Register to renderer.
		}
		
		// TODO: convienice function.
		// Create light.
		light: do {
			// Root gameobject.
			guard let gameObject = GameObject() else { break light }
			gameObject.transform.position = Vector3(5) // Transform.
			guard let _: Light = gameObject.addComponent() else { break light }
			// Add GameObject
			Application.addGameObject(gameObject) // Register to renderer.
		}
		
		// Create shadowmap camera.
		shadowCamera: do {
			// Root gameobject.
			guard let gameObject = GameObject() else { break shadowCamera }
			gameObject.transform.position = Vector3(5) // Position is the same as the light.
			guard let _: Camera = gameObject.addComponent() else { break shadowCamera }
			gameObject.tag = .shadowMapCamera // Set gameobject tags defer.
			// Add GameObject
			Application.addGameObject(gameObject) // Register to renderer.
		}
	}
}

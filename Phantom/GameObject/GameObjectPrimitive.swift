// Copyright © haijian. All rights reserved.

// MARK: - Primitive extension for creating various primitive gameobjects by using the GameObject.create... functions.
extension GameObject {

	/// Create a basic mesh type gameobject by all default settings.
	///
	/// - Returns: GameObject
	private static func createBase() -> GameObject? {
		// GameObject
		guard let gameObject = GameObject() else { return nil }
		// MeshRenderer
		guard let meshRenderer: MeshRenderer = gameObject.addComponent() else { return nil }
		// Attach material
		let material = Material()
		guard let shader = Shader() else { return nil }
		// TODO: None texture.
		guard let texture = Texture(name: "UV_Grid_Sm") else { return nil }
		material.texture = texture
		material.shader = shader
		meshRenderer.material = material
		return gameObject
	}
	
	/// Create a cube primitive.

	public static func createCube() -> GameObject? {
		guard let gameObject = GameObject.createBase() else { return nil }
		guard let meshRenderer: MeshRenderer = gameObject.getComponent() else { return nil }
		// TODO: refactor!
		guard let mesh = Mesh(shader: (meshRenderer.material?.shader)!) else { return nil }
		meshRenderer.mesh = mesh
		return gameObject
	}
}

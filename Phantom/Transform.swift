// Copyright © haijian. All rights reserved.

// TODO: ...
class Transform: Component {
	
	var rotation: Float = 0
	
	var viewMatrix = Matrix4x4()
	var modelMatrix = Matrix4x4()
	
	// TODO: refactor
	func update() {
		let rotationAxis = float3(1, 1, 0)
		modelMatrix = Math.rotate(radians: rotation, axis: rotationAxis)
		viewMatrix = Math.translate(0.0, 0.0, -8.0)
		rotation += 0.01
	}
}

// Copyright © haijian. All rights reserved.

class Transform: Component {
	
	var projectionMatrix: Matrix4x4 = Matrix4x4()
	var rotation: Float = 0
	
	func update() {
		
		gameObject.updateDynamicBufferState()
		
		gameObject.uniforms[0].projectionMatrix = projectionMatrix
		
		let rotationAxis = float3(1, 1, 0)
		let modelMatrix = Math.rotate(radians: rotation, axis: rotationAxis)
		let viewMatrix = Math.translate(0.0, 0.0, -8.0)
		gameObject.uniforms[0].modelViewMatrix = viewMatrix * modelMatrix;
		rotation += 0.01
	}
}

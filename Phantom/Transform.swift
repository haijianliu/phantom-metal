// Copyright © haijian. All rights reserved.

class Transform: Component {
	
	var rotation: Float = 0
	
	func update() {
		
		gameObject.updateDynamicBufferState()
		
		// TODO: in game object
		gameObject.uniforms[0].projectionMatrix = (Camera.main?.projectionMatrix)!
		
		let rotationAxis = float3(1, 1, 0)
		let modelMatrix = Math.rotate(radians: rotation, axis: rotationAxis)
		let viewMatrix = Math.translate(0.0, 0.0, -8.0)
		
		// TODO: Camera set view matrix
		gameObject.uniforms[0].modelViewMatrix = viewMatrix * modelMatrix;
		
		rotation += 0.01
	}
}

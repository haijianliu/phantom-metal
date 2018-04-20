// Copyright © haijian. All rights reserved.

/// Position, rotation and scale of an object.
///
/// Every object in a scene has a Transform. It's used to store and manipulate the position, rotation and scale of the object. Every Transform can have a parent, which allows you to apply position, rotation and scale hierarchically. This is the hierarchy seen in the Hierarchy pane. They also support enumerators so you can loop through children using:
public class Transform: Component {

	/// The position of the transform in world space.
	///
	/// The position member can be accessed by the Game code. Setting this value can be used to animate the GameObject. The example below makes an attached sphere bounce by updating the position. This bouncing slowly comes to an end. The position can also be use to determine where in 3D space the transform.
	public var position: Vector3 = Vector3()
	
	// TODO: rotation ...
	
	
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

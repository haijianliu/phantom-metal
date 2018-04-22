// Copyright © haijian. All rights reserved.

/// Position, rotation and scale of an object.
///
/// Every object in a scene has a Transform. It's used to store and manipulate the position, rotation and scale of the object. Every Transform can have a parent, which allows you to apply position, rotation and scale hierarchically. This is the hierarchy seen in the Hierarchy pane. They also support enumerators so you can loop through children using:
public class Transform: Component {

	/// The position of the transform in world space.
	///
	/// The position member can be accessed by the Game code. Setting this value can be used to animate the GameObject. The example below makes an attached sphere bounce by updating the position. This bouncing slowly comes to an end. The position can also be use to determine where in 3D space the transform.
	// TODO: setter getter dirty
	public var position: Vector3 = Vector3()

	/// The rotation of the transform in world space stored as a Quaternion (Read Only).
	///
	/// To rotate an object, use Transform.rotate. TODO: Use Transform.eulerAngles for setting the rotation as euler angles. Transform.rotation will provide or accept the rotation using a Quaternion.
	public var rotation: Quaternion {
		// TODO: matrix to quaternion
		return Quaternion()
	}
	
	// TODO: extension
	var modelMatrix = Matrix4x4(1)

	// TODO: will in camera. public temporarily
	public var viewMatrix = Matrix4x4()
}

extension Transform {

	/// Applies a rotation of radians around the axis
	///
	/// - Parameters:
	///   - relativeTo: TODO: If relativeTo is not specified or set to Space.local the rotation is applied around the transform's local axes. If relativeTo is set to Space.World the rotation is applied around the world x, y, z axes.
	public func rotate(angle: Radian, axis: Vector3, relativeTo: Space = Space.local) {
		let rotateMatrix = Math.rotate(angle, axis)
		modelMatrix = rotateMatrix * modelMatrix
	}
}

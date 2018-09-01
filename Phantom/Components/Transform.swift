// Copyright © haijian. All rights reserved.

import MetalKit

/// Position, rotation and scale of an object.
///
/// Every object in a scene has a Transform. It's used to store and manipulate the position, rotation and scale of the object. Every Transform can have a parent, which allows you to apply position, rotation and scale hierarchically. This is the hierarchy seen in the Hierarchy pane. They also support enumerators so you can loop through children using:
public class Transform: Component, Updatable, RenderEncodable {
	// TODO: refactor.
	private var transformUniformBuffer: TripleBuffer<NodeBuffer>
	
	// TODO: dirty protocol?
	/// True if the associated properties is modifed. Initialized value is true.
	private var dirty = true {
		didSet { if dirty == true { for child in gameObject.children { child.transform.dirty = true } } } }
	
	// TODO: Use local, lossy, world transform. https://docs.unity3d.com/ScriptReference/Transform.html

	// TODO: setter getter dirty
	/// The position of the transform relative to the parent.
	///
	/// The position member can be accessed by the Game code. Setting this value can be used to animate the GameObject. The example below makes an attached sphere bounce by updating the position. This bouncing slowly comes to an end. The position can also be use to determine where in 3D space the transform.
	public var position = Vector3(0) { didSet { dirty = true } }
	
	/// The scale of the transform relative to the parent.
	public var scale = Vector3(1) { didSet { dirty = true } }

	/// The rotation of the transform relative to the parent stored as a Quaternion.
	///
	/// To rotate an object, use Transform.rotate.
	/// TODO: Use Transform.eulerAngles for setting the rotation as euler angles. Transform.rotation will provide or accept the rotation using a Quaternion.
	public var rotation = Quaternion(real: 1, imag: Vector3(0)) { didSet { dirty = true } }
	
	/// Storage of the local to world matrix.
	/// When dirty flag is true, this value will be updated when first time the local to world matrix is called.
	private var currentLocalToWorldMatrix = Matrix4x4(1)
	
	/// The position of the transform in world space (Read Only).
	public var worldPosition: Vector3 {
		// TODO: Vector extension
		let vector = localToWorldMatrix * Vector4(0, 0, 0, 1)
		return Vector3(vector.x, vector.y, vector.z)
	}
	
	/// Matrix that transforms a point from local space into world space (Read Only).
	var localToWorldMatrix: Matrix4x4 {
		if dirty {
			currentLocalToWorldMatrix = Math.translate(position) * Matrix4x4(rotation) * Math.scale(scale)
			if gameObject.parent != nil {
				currentLocalToWorldMatrix = gameObject.parent!.transform.localToWorldMatrix * currentLocalToWorldMatrix
			}
			dirty = false
		}
		return currentLocalToWorldMatrix
	}
	
	required public init?(_ gameObject: GameObject) {
		guard let device = Application.sharedInstance.device else { return nil }
		// TODO: init dynamic semaphore value
		guard let newBuffer = TripleBuffer<NodeBuffer>(device) else { return nil }
		transformUniformBuffer = newBuffer
		
		super.init(gameObject)
	}
	
	public func update() {
		transformUniformBuffer.data.update(by: self)
		transformUniformBuffer.endWritting()
	}
	
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder) {
		renderCommandEncoder.setVertexBuffer(transformUniformBuffer.buffer, offset: transformUniformBuffer.offset, index: BufferIndex.nodeBuffer.rawValue)
	}
}

extension Transform {
	// TODO: update transform.
	/// Applies a rotation of radians around the axis.
	///
	/// - Parameters:
	///   - angle: The angle to rotate by measured in radians.
	///   - axis: The axis to rotate around.
	///   - relativeTo: TODO: If relativeTo is not specified or set to Space.local the rotation is applied around the transform's local axes. If relativeTo is set to Space.World the rotation is applied around the world x, y, z axes.
	public func rotate(angle: Radian, axis: Vector3, relativeTo: Space = Space.local) {
		rotation = Quaternion.init(angle: angle, axis: axis) * rotation
	}
}

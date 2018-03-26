// Copyright © haijian. All rights reserved.

// Generic matrix math utility functions
extension Math {
	
	/// Creates a matrix for a symetric perspective-view frustum. (Right hand)
	public static func perspective(fovyRadians fovy: Float, aspect: Float, near: Float, far: Float) -> Matrix4x4 {
		let ys = 1 / tanf(fovy * 0.5)
		let xs = ys / aspect
		let zs = far / (near - far)
		return Matrix4x4.init(columns:(Vector4(xs,0, 0, 0), Vector4( 0, ys, 0, 0), Vector4( 0,  0, zs, -1), Vector4( 0, 0, zs * near, 0)))
	}
	
	/// Builds a rotation 4 * 4 matrix created from an axis of 3 scalars and an angle expressed in radians.
	public static func rotate(radians: Float, axis: Vector3) -> Matrix4x4 {
		let unitAxis = normalize(axis)
		let ct = cosf(radians)
		let st = sinf(radians)
		let ci = 1 - ct
		let x = unitAxis.x, y = unitAxis.y, z = unitAxis.z
		return Matrix4x4.init(columns:(Vector4(ct + x * x * ci, y * x * ci + z * st, z * x * ci - y * st, 0), Vector4(x * y * ci - z * st, ct + y * y * ci, z * y * ci + x * st, 0), Vector4(x * z * ci + y * st, y * z * ci - x * st, ct + z * z * ci, 0), Vector4(0, 0, 0, 1)))
	}
	
	/// Builds a translation 4 * 4 matrix created from 3 scalars.
	public static func translate(_ translationX: Float, _ translationY: Float, _ translationZ: Float) -> Matrix4x4 {
		return Matrix4x4.init(columns:(Vector4(1, 0, 0, 0), Vector4(0, 1, 0, 0), Vector4(0, 0, 1, 0), Vector4(translationX, translationY, translationZ, 1)))
	}
}

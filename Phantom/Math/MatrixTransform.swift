// Copyright © haijian. All rights reserved.

import GLKit

// Defines functions that generate common transformation matrices
extension Math {
	
	/// Builds a translation 4 * 4 matrix created from a vector of 3 components.
	///
	/// [glm/glm/gtc/matrix_transform.inl](https://github.com/g-truc/glm/blob/master/glm/gtc/matrix_transform.inl)
	/// - Parameters:
	///   - matrix: Input matrix multiplied by this translation matrix. Default value is `Matrix4x4(1)`.
	///   - vector: Coordinates of a translation vector.
	public static func translate(from matrix: Matrix4x4 = Matrix4x4(1), _ vector: Vector3) -> Matrix4x4 {
		var result = matrix
		result[3] = matrix[0] * vector[0] + matrix[1] * vector[1] + matrix[2] * vector[2] + matrix[3];
		return result;
	}
	
	/// Builds a translation 4 * 4 matrix created from 3 scalars.
	public static func translate(_ translationX: Float, _ translationY: Float, _ translationZ: Float) -> Matrix4x4 {
		return Matrix4x4.init(columns:(Vector4(1, 0, 0, 0), Vector4(0, 1, 0, 0), Vector4(0, 0, 1, 0), Vector4(translationX, translationY, translationZ, 1)))
	}
	
	/// Builds a rotation 4 * 4 matrix created from an axis vector and an angle.
	///
	/// [glm/glm/gtc/matrix_transform.inl](https://github.com/g-truc/glm/blob/master/glm/gtc/matrix_transform.inl)
	/// - Parameters:
	///   - angle: Rotation angle expressed in radians.
	///   - axis: Rotation axis, recommended to be normalized.
	public static func rotate(_ angle: Radian, _ axis: Vector3) -> Matrix4x4 {
		let a = angle
		let c = cosf(a)
		let s = sinf(a)
		
		var unitAxis = normalize(axis)
		var temp = (1 - c) * axis
		
		var Rotate = simd_float4x4()
		Rotate[0][0] = c + temp[0] * unitAxis[0]
		Rotate[0][1] = temp[0] * unitAxis[1] + s * unitAxis[2]
		Rotate[0][2] = temp[0] * unitAxis[2] - s * unitAxis[1]
		Rotate[0][3] = 0
		
		Rotate[1][0] = temp[1] * unitAxis[0] - s * unitAxis[2]
		Rotate[1][1] = c + temp[1] * unitAxis[1]
		Rotate[1][2] = temp[1] * unitAxis[2] + s * unitAxis[0]
		Rotate[1][3] = 0
		
		Rotate[2][0] = temp[2] * unitAxis[0] + s * unitAxis[1]
		Rotate[2][1] = temp[2] * unitAxis[1] - s * unitAxis[0]
		Rotate[2][2] = c + temp[2] * unitAxis[2]
		Rotate[2][3] = 0
		
		Rotate[3][0] = 0
		Rotate[3][1] = 0
		Rotate[3][2] = 0
		Rotate[3][3] = 1
		
		return Rotate
	}
	
	/// Builds a rotation 4 * 4 matrix created from an axis vector and an angle.
	///
	/// [glm/glm/gtc/matrix_transform.inl](https://github.com/g-truc/glm/blob/master/glm/gtc/matrix_transform.inl)
	/// - Parameters:
	///   - matrix4x4: Input matrix multiplied by this rotation matrix.
	///   - angle: Rotation angle expressed in radians.
	///   - axis: Rotation axis, recommended to be normalized.
	public static func rotate(_ matrix4x4: Matrix4x4, _ angle: Radian, _ axis: Vector3) -> Matrix4x4 {
		let Rotate = Math.rotate(angle, axis)
		var Result = simd_float4x4()
		Result[0] = matrix4x4[0] * Rotate[0][0] + matrix4x4[1] * Rotate[0][1] + matrix4x4[2] * Rotate[0][2];
		Result[1] = matrix4x4[0] * Rotate[1][0] + matrix4x4[1] * Rotate[1][1] + matrix4x4[2] * Rotate[1][2];
		Result[2] = matrix4x4[0] * Rotate[2][0] + matrix4x4[1] * Rotate[2][1] + matrix4x4[2] * Rotate[2][2];
		Result[3] = matrix4x4[3];
		return Result;
	}
	
	/// Creates a matrix for a symetric perspective-view frustum. (Right hand)
	public static func perspective(fovyRadians fovy: Float, aspect: Float, near: Float, far: Float) -> Matrix4x4 {
		let ys = 1 / tanf(fovy * 0.5)
		let xs = ys / aspect
		let zs = far / (near - far)
		return Matrix4x4.init(columns:(Vector4(xs,0, 0, 0), Vector4( 0, ys, 0, 0), Vector4( 0,  0, zs, -1), Vector4( 0, 0, zs * near, 0)))
	}
	
	/// Build a right handed look at view matrix.
	///
	/// [glm/glm/gtc/matrix_transform.inl](https://github.com/g-truc/glm/blob/master/glm/gtc/matrix_transform.inl)
	/// - Parameters:
	///   - eye: Position of the camera.
	///   - center: Position where the camera is looking at.
	///   - up: Normalized up vector, how the camera is oriented. Typically (0, 1, 0).
	public static func lookAt(eye: Vector3, center: Vector3, up: Vector3 = Vector3(0, 1, 0)) -> Matrix4x4 {
		let f = normalize(center - eye)
		let s = normalize(cross(f, up))
		let u = cross(s, f)
		var Result = Matrix4x4(1)
		Result[0][0] = s.x
		Result[1][0] = s.y
		Result[2][0] = s.z
		Result[0][1] = u.x
		Result[1][1] = u.y
		Result[2][1] = u.z
		Result[0][2] = -f.x
		Result[1][2] = -f.y
		Result[2][2] = -f.z
		Result[3][0] = -dot(s, eye)
		Result[3][1] = -dot(u, eye)
		Result[3][2] = dot(f, eye)
		return Result
	}
}

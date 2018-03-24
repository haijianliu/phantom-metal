// Copyright © haijian. All rights reserved.

// Generic matrix math utility functions

typealias Vector3 = simd_float3
typealias Vector4 = simd_float4
typealias Matrix4x4 = simd_float4x4

class Math {
	static func matrix4x4_rotation(radians: Float, axis: Vector3) -> Matrix4x4 {
		let unitAxis = normalize(axis)
		let ct = cosf(radians)
		let st = sinf(radians)
		let ci = 1 - ct
		let x = unitAxis.x, y = unitAxis.y, z = unitAxis.z
		return Matrix4x4.init(columns:(Vector4(ct + x * x * ci, y * x * ci + z * st, z * x * ci - y * st, 0), Vector4(x * y * ci - z * st, ct + y * y * ci, z * y * ci + x * st, 0), Vector4(x * z * ci + y * st, y * z * ci - x * st, ct + z * z * ci, 0), Vector4(0, 0, 0, 1)))
	}
	
	static func matrix4x4_translation(_ translationX: Float, _ translationY: Float, _ translationZ: Float) -> Matrix4x4 {
		return Matrix4x4.init(columns:(Vector4(1, 0, 0, 0), Vector4(0, 1, 0, 0), Vector4(0, 0, 1, 0), Vector4(translationX, translationY, translationZ, 1)))
	}
	
	static func matrix_perspective_right_hand(fovyRadians fovy: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> Matrix4x4 {
		let ys = 1 / tanf(fovy * 0.5)
		let xs = ys / aspectRatio
		let zs = farZ / (nearZ - farZ)
		return Matrix4x4.init(columns:(Vector4(xs,0, 0, 0), Vector4( 0, ys, 0, 0), Vector4( 0,  0, zs, -1), Vector4( 0, 0, zs * nearZ, 0)))
	}
	
	static func radians_from_degrees(_ degrees: Float) -> Float {
		return (degrees / 180) * .pi
	}
}


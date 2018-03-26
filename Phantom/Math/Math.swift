// Copyright © haijian. All rights reserved.

// Generic math type alias from simd types
typealias Vector3 = simd_float3
typealias Vector4 = simd_float4
typealias Matrix4x4 = simd_float4x4

// Generic math base class
class Math {
	/// The mathematical constant pi.
	/// pi = 3.14159265358979
	public static let pi = Float.pi;

	/// Converts degrees to radians and returns the result.
	public static func radians(_ degrees: Float) -> Float {
		return (degrees / 180) * self.pi
	}
}




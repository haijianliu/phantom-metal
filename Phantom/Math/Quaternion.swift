// Copyright © haijian. All rights reserved.

extension Math {
	
	// TODO: test
	/// Build a quaternion from an angle and a normalized axis.
	///
	/// - Parameters:
	///   - angle: Angle expressed in radians.
	///   - axis: Axis of the quaternion, must be normalized.
	public static func angleAxis(_ angle: Radian, _ axis: Vector3) -> Quaternion {
		return simd_quatf(angle: angle, axis: axis)
	}
}

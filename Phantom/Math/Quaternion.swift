// Copyright © haijian. All rights reserved.

extension Math {
	/// Build a quaternion from an angle and a normalized axis.
	///
	/// - Parameters:
	///   - angle: Angle expressed in radians.
	///   - axis: Axis of the quaternion, must be normalized.
	// TODO: test
	public static func angleAxis(_ angle: Radian, _ axis: Vector3) -> Quaternion {
		return simd_quatf(angle: angle, axis: axis)
	}
}

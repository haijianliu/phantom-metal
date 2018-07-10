// Copyright © haijian. All rights reserved.

// Function parameters specified as angle are assumed to be in units of radians
extension Math {

	/// Converts degrees to radians and returns the result.
	public static func radians(_ degrees: Float) -> Float {
		return (degrees / 180) * self.pi
	}
}

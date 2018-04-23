// Copyright © haijian. All rights reserved.

/// The coordinate space in which to operate.
///
/// - local: Use Space.local to transform a GameObject using its own coordinates and consider its rotations.
/// - world: Use Space.world to transform a GameObject using world coordinates, ignoring the GameObject’s rotation state.
public enum Space {
	case local
	case world
}

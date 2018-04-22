// Copyright © haijian. All rights reserved.

/// Base class for everything attached to GameObject(s).
open class Component: Object {
	
	/// The game object this component is attached to.
	/// A component is always attached to a game object.
	public let gameObject: GameObject
	
	/// The Transform attached to this GameObject.
	public var transform: Transform {
		return gameObject.transform
	}
	
	// TODO: no public
	required public init(_ gameObject: GameObject) {
		self.gameObject = gameObject
	}
}

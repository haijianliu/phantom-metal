// Copyright © haijian. All rights reserved.

/// Base class for everything attached to GameObject(s).
open class Component {

	/// Enabled Behaviours are updated, disabled Behaviours are not.
	///
	/// Automatically adopts and comforms to Behaviour protocol (Default: true).
	@objc public var enabled: Bool = true

	/// The game object this component is attached to.
	/// A component is always attached to a game object.
	public unowned let gameObject: GameObject

	/// The Transform attached to this GameObject.
	public var transform: Transform { return gameObject.transform }

	// TODO: no public
	required public init(_ gameObject: GameObject) {
		self.gameObject = gameObject
	}
}

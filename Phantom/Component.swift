// Copyright © haijian. All rights reserved.

/// Protocol for everything attached to GameObject(s).
protocol Component {
	
	/// The game object this component is attached to.
	/// A component is always attached to a game object.
	var gameObject: GameObject? { get set }
	
	/// The Transform attached to this GameObject.
	var transform: Transform? { get set }
	
	init()
}

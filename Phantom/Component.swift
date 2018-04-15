// Copyright © haijian. All rights reserved.

/// Base class for everything attached to GameObject(s).
class Component {
	
	/// The game object this component is attached to.
	/// A component is always attached to a game object.
	let gameObject: GameObject
	
	/// The Transform attached to this GameObject.
	var transform: Transform {
		return gameObject.transform
	}
	
	required init(_ gameObject: GameObject) {
		self.gameObject = gameObject
	}
}


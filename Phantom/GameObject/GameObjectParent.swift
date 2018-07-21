// Copyright © haijian. All rights reserved.

// MARK: - Parent extension.
extension GameObject {
	/// Add a gameobject(as child) to self(as parent).
	///
	/// One gameobject can only have one parent at one time. If you reassign a gameobjec to another, this action will break the link between the old one automatically.
	/// - Parameter gameObject: GameObject as child.
	public func addChild(_ gameObject: GameObject) {
		// TODO: reassign and register to renderer directly.
		children.append(gameObject)
		gameObject.parent = self
	}
	
	// TODO: delete parent and child.
}

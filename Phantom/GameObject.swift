// Copyright © haijian. All rights reserved.

import MetalKit

class GameObject {
	var transform = Transform()
	
	private var components = [String: Component]()
	
	init() {
		
	}
	
	/// Adds a component class named type name to the game object.
	///
	/// If there is already a same type of componet added, this function will do nothing, and return a nil
	/// - Returns: Componet instance if succeed, otherwise nil
	func addComponent<T: Component>() -> T? {
		let typeName = String(describing: T.self)
		if components[typeName] == nil {
			var componet = T()
			componet.gameObject = self
			componet.transform = transform
			components[typeName] = componet
			return components[typeName] as? T
		} else {
			return nil
		}
	}
	
	/// Get a component instance attached to the game object by component type.
	/// - Returns: Component instance of component type if the game object has one attached, nil if it doesn't.
	func getComponent<T: Component>() -> T? {
		return components[String(describing: T.self)] as? T
	}
}


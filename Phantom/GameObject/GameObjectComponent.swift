// Copyright © haijian. All rights reserved.

// MARK: - Extension functions for Component.
extension GameObject {
	
	/// Adds a component class named type name to the game object.
	///
	/// If there is already a same type of componet added, this function will do nothing, and return a nil
	/// - Returns: Componet instance if succeed, otherwise nil
	public func addComponent<ComponentType: Component>() -> ComponentType? {
		let typeName = String(describing: ComponentType.self)
		if components[typeName] == nil {
			let component = ComponentType(self)
			components[typeName] = component
			return components[typeName] as? ComponentType
		} else {
			return nil
		}
	}
	
	/// Get a component instance attached to the game object by component type.
	/// - Returns: Component instance of component type if the game object has one attached, nil if it doesn't.
	public func getComponent<ComponentType: Component>() -> ComponentType? {
		return components[String(describing: ComponentType.self)] as? ComponentType
	}
}

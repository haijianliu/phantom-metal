// Copyright © haijian. All rights reserved.

// MARK: - Component extension.
extension GameObject {
	/// Adds a component class named type name to the game object.
	///
	/// If there is already a same type of componet added, this function will do nothing, and return a nil
	/// - Returns: Componet instance if succeed, otherwise nil
	public func addComponent<ComponentType: Component>() -> ComponentType? {
		let typeName = String(describing: ComponentType.self)
		if components[typeName] == nil {
			guard let component = ComponentType(self) else { return nil }
			components[typeName] = component
			return components[typeName] as? ComponentType // TODO: no optional type return.
		} else {
			return nil // TODO: return exists.
		}
	}

	/// Get a component instance attached to the game object by component type. Calling this function during real time updating is not recommended.
	/// - Returns: Component instance of component type if the game object has one attached, nil if it doesn't.
	public func getComponent<ComponentType: Component>() -> ComponentType? {
		return components[String(describing: ComponentType.self)] as? ComponentType
	}
}

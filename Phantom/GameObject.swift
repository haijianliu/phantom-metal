// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: description
class GameObject {
	
	// TODO: set mainCamera before add a camera component
	/// The tag of this game object.
	var tag: GameObjectTag {
		didSet {
			if tag == .mainCamera {
				Camera.main = self.getComponent()
			}
		}
	}
	
	/// The Transform attached to this GameObject.
	var transform: Transform {
		return components[String(describing: Transform.self)] as! Transform
	}
	
	var transformUniformBuffer: GpuBuffer<Uniforms>

	private var components = [String: Component]()
	
	init?() {
		// TODO: init dynamic semaphore value
		guard let newBuffer = GpuBuffer<Uniforms>(semaphoreValue: 2, options: MTLResourceOptions.storageModeShared) else { return nil }
		transformUniformBuffer = newBuffer
		
		tag = .untagged
	}
}

extension GameObject {
	
	/// Adds a component class named type name to the game object.
	///
	/// If there is already a same type of componet added, this function will do nothing, and return a nil
	/// - Returns: Componet instance if succeed, otherwise nil
	func addComponent<ComponentType: Component>() -> ComponentType? {
		let typeName = String(describing: ComponentType.self)
		if components[typeName] == nil {
			let componet = ComponentType(self)
			components[typeName] = componet
			return components[typeName] as? ComponentType
		} else {
			return nil
		}
	}
	
	/// Get a component instance attached to the game object by component type.
	/// - Returns: Component instance of component type if the game object has one attached, nil if it doesn't.
	func getComponent<ComponentType: Component>() -> ComponentType? {
		return components[String(describing: ComponentType.self)] as? ComponentType
	}
}

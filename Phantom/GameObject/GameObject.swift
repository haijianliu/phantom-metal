// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: Inherits from:Obje
/// Base class for all entities in scenes.
public class GameObject {
	
	/// The tag of this game object.
	public var tag: GameObjectTag { didSet { if tag == .mainCamera, let camera: Camera = self.getComponent() { Camera.main = camera } } }
	
	// TODO: unowned reference?
	/// The Transform attached to this GameObject.
	lazy public private(set) var transform: Transform = {
		return components[String(describing: Transform.self)] as! Transform
	}()

	private var transformUniformBuffer: TripleBuffer<Transformations>
	
	/// Holds a list of strong references of components have attached.
	var components = [String: Component]()
	
	// TODO: named name.
	/// Creates a new game object.
	public init?() {
		// TODO: init dynamic semaphore value
		guard let newBuffer = TripleBuffer<Transformations>() else { return nil }
		transformUniformBuffer = newBuffer
		// Default tag: untagged
		tag = .untagged
		// Transform
		guard let _: Transform = self.addComponent() else { return nil }
	}
	
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
	
	/// Get a component instance attached to the game object by component type. Calling this function during real time updating is not recommended.
	/// - Returns: Component instance of component type if the game object has one attached, nil if it doesn't.
	public func getComponent<ComponentType: Component>() -> ComponentType? {
		return components[String(describing: ComponentType.self)] as? ComponentType
	}
}

extension GameObject: Encodable {
	
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder) {
		
		// TODO: in transform
		// TODO: in game object
		guard let camera = Camera.main else { return }
		transformUniformBuffer.data.projectionMatrix = camera.projectionMatrix
		// TODO: Camera set view matrix
		transformUniformBuffer.data.modelViewMatrix = camera.worldToCameraMatrix * transform.localToWorldMatrix;
		transformUniformBuffer.endWritting()
		
		renderCommandEncoder.setVertexBuffer(transformUniformBuffer.buffer, offset: transformUniformBuffer.offset, index: BufferIndex.transformations.rawValue)
	}
}

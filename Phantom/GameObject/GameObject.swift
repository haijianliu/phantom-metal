// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: Inherits from:Obje
/// Base class for all entities in scenes.
public class GameObject {
	
	/// The tag of this game object.
	public var tag: GameObjectTag { didSet { if tag == .mainCamera, let camera: Camera = self.getComponent() { Camera.main = camera } } }

	/// The material attached of MeshRenderer attached to this GameObject. 
	public var material: Material? { get {
			let meshRenderer: MeshRenderer? = self.getComponent()
			return meshRenderer?.material } }
	
	// TODO: unowned reference?
	/// The Transform attached to this GameObject.
	lazy public private(set) var transform: Transform = {
		return components[String(describing: Transform.self)] as! Transform
	}()

	private var transformUniformBuffer: TripleBuffer<NodeBuffer>
	
	/// Holds a list of strong references of components have attached.
	var components = [String: Component]()
	
	// TODO: named name.
	/// Creates a new game object.
	public init?() {
		guard let device = View.main.device else { return nil }
		// TODO: init dynamic semaphore value
		guard let newBuffer = TripleBuffer<NodeBuffer>(device) else { return nil }
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

extension GameObject: RenderEncodable {
	
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder) {
		
		// TODO: in transform
		// TODO: in game object
		guard let camera = Camera.main else { return }
		transformUniformBuffer.data.projectionMatrix = camera.projectionMatrix
		// TODO: Camera set view matrix.
		// TODO: Use shader type to set buffer.
		transformUniformBuffer.data.viewMatrix = camera.worldToCameraMatrix
		transformUniformBuffer.data.modelMatrix = transform.localToWorldMatrix
		transformUniformBuffer.data.inverseTransposeModelMatrix = transform.localToWorldMatrix.inverse.transpose
		transformUniformBuffer.endWritting()
		
		renderCommandEncoder.setVertexBuffer(transformUniformBuffer.buffer, offset: transformUniformBuffer.offset, index: BufferIndex.nodeBuffer.rawValue)
	}
}

// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: Inherits from:Obje
/// Base class for all entities in scenes.
public class GameObject {
	/// The tag of this game object.
	public var tag: GameObjectTag { didSet { if tag == .mainCamera, let camera: Camera = self.getComponent() { Camera.main = camera } } }
	
	// TODO: Observe changes of properties.
	// TODO: Node system.
	weak var parent: GameObject?
	
	// TODO: use fixed array.
	/// The only strong references holder of child gameobjects.
	var children = [GameObject]()
	
	/// Holds a list of strong references of components have attached.
	var components = [String: Component]()
	
	// TODO: unowned reference?
	/// The Transform attached to this GameObject.
	lazy public private(set) var transform: Transform = {
		return components[String(describing: Transform.self)] as! Transform
	}()
	
	/// The material attached of MeshRenderer attached to this GameObject.
	public var material: Material? { get {
		let meshRenderer: MeshRenderer? = self.getComponent()
		return meshRenderer?.material } }
	
	// TODO: named name.
	/// Creates a new game object.
	public init?() {
		// Default tag: untagged
		tag = .untagged
		// Transform
		guard let _: Transform = self.addComponent() else { return nil }
	}
}

extension GameObject: RenderEncodable {
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder) {
		transform.encode(to: renderCommandEncoder)
	}
}

// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: Inherits from:Obje
/// Base class for all entities in scenes.
public class GameObject {
	
	// TODO: set mainCamera before add a camera component
	/// The tag of this game object.
	public var tag: GameObjectTag {
		didSet {
			if tag == .mainCamera {
				Camera.main = self.getComponent()
			}
		}
	}
	
	// TODO: unowned reference.
	/// The Transform attached to this GameObject.
	public var transform: Transform {
		return components[String(describing: Transform.self)] as! Transform
	}
	
	private var transformUniformBuffer: TripleBuffer<Uniforms>
	
	// TODO: private?
	var components = [String: Component]()
	
	// TODO: named name.
	/// Creates a new game object.
	public init?() {
		// TODO: init dynamic semaphore value
		guard let newBuffer = TripleBuffer<Uniforms>() else { return nil }
		transformUniformBuffer = newBuffer
		// Default tag: untagged
		tag = .untagged
		// Transform
		guard let _: Transform = self.addComponent() else { return nil }
	}
}

extension GameObject: Encodable {
	
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder) {
		
		// TODO: in transform
		// TODO: in game object
		transformUniformBuffer.data.projectionMatrix = (Camera.main?.projectionMatrix)!
		// TODO: Camera set view matrix
		transformUniformBuffer.data.modelViewMatrix = transform.viewMatrix * transform.modelMatrix;
		transformUniformBuffer.endWritting()
		
		renderCommandEncoder.setVertexBuffer(transformUniformBuffer.buffer, offset: transformUniformBuffer.offset, index: BufferIndex.uniforms.rawValue)
	}
}

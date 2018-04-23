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
	
	/// The Transform attached to this GameObject.
	public var transform: Transform {
		return components[String(describing: Transform.self)] as! Transform
	}
	
	// TODO: private
	var transformUniformBuffer: GpuBuffer<Uniforms>
	var components = [String: Component]()
	
	// TODO: named name.
	/// Creates a new game object.
	public init?() {
		// TODO: init dynamic semaphore value
		guard let newBuffer = GpuBuffer<Uniforms>(semaphoreValue: 3, options: MTLResourceOptions.storageModeShared) else { return nil }
		transformUniformBuffer = newBuffer
		// Default tag: untagged
		tag = .untagged
		// Transform
		guard let _: Transform = self.addComponent() else { return nil }
	}
}

// MARK: - Update functions
extension GameObject {
	
	// TODO: update command buffer in game object
	func getSemaphore() -> DispatchSemaphore {
		// TODO: wait in GpuBuffer
		return transformUniformBuffer.semaphore
	}
	
	// TODO: delete this function
	func update() {
		// TODO: automatic
		transformUniformBuffer.updateBufferState()
		// TODO: in game object
		transformUniformBuffer.pointer[0].projectionMatrix = (Camera.main?.projectionMatrix)!
		// TODO: Camera set view matrix
		transformUniformBuffer.pointer[0].modelViewMatrix = transform.viewMatrix * transform.modelMatrix;
	}
}

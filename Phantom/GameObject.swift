// Copyright © haijian. All rights reserved.

import MetalKit

// Function(vertexShader): the offset into the buffer uniforms that is bound at buffer index must be a multiple of 256
let alignedUniformsSize = (MemoryLayout<Uniforms>.size & ~0xFF) + 0x100
let maxBuffersInFlight = 3

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
	
	var uniforms: UnsafeMutablePointer<Uniforms>
	var dynamicUniformBuffer: MTLBuffer
	let inFlightSemaphore = DispatchSemaphore(value: maxBuffersInFlight)
	var uniformBufferOffset = 0
	var uniformBufferIndex = 0
	
	private var components = [String: Component]()
	
	init?() {
		let uniformBufferSize = alignedUniformsSize * maxBuffersInFlight
		guard let buffer = Display.main.device?.makeBuffer(length: uniformBufferSize, options: MTLResourceOptions.storageModeShared) else { return nil }
		dynamicUniformBuffer = buffer
		self.dynamicUniformBuffer.label = "UniformBuffer"
		uniforms = UnsafeMutableRawPointer(dynamicUniformBuffer.contents()).bindMemory(to: Uniforms.self, capacity: 1)
		
		tag = .untagged
	}
	
	func updateDynamicBufferState() {
		/// Update the state of our uniform buffers before rendering
		uniformBufferIndex = (uniformBufferIndex + 1) % maxBuffersInFlight
		
		uniformBufferOffset = alignedUniformsSize * uniformBufferIndex
		
		uniforms = UnsafeMutableRawPointer(dynamicUniformBuffer.contents() + uniformBufferOffset).bindMemory(to:Uniforms.self, capacity:1)
	}
}

extension GameObject {
	
	/// Adds a component class named type name to the game object.
	///
	/// If there is already a same type of componet added, this function will do nothing, and return a nil
	/// - Returns: Componet instance if succeed, otherwise nil
	func addComponent<T: Component>() -> T? {
		let typeName = String(describing: T.self)
		if components[typeName] == nil {
			let componet = T(self)
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

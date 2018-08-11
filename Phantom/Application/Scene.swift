// Copyright © haijian. All rights reserved.

import MetalKit

class Scene {
	/// The only game object references holder.
	var gameObjects = [GameObject]()
	
	// TODO: clean up nil reference.
	/// A [contiguous array](http://jordansmith.io/on-performant-arrays-in-swift/) to update behaviour weak reference list in real time, reserving a capacity of 256 elements.
	var updatableBehaviours = ContiguousArray<Weak<Updatable>>()
	var renderableBehaviours = ContiguousArray<Weak<Renderable>>()
	var lightableBehaviours = ContiguousArray<Weak<Lightable>>()
	
	// TODO: in scene.
	private var lightUniformBuffer: TripleBuffer<LightBuffer>
	
	init?(device: MTLDevice) {
		// TODO: use library settings.
		updatableBehaviours.reserveCapacity(0xFF)
		renderableBehaviours.reserveCapacity(0xFF)
		lightableBehaviours.reserveCapacity(0xF)
		
		// Light uniform buffer.
		// TODO: init dynamic semaphore value
		guard let newBuffer = TripleBuffer<LightBuffer>(device) else { return nil }
		lightUniformBuffer = newBuffer
	}
	
	func addGameObject(_ gameObjcet: GameObject) {
		// Add gameobject strong references.
		gameObjects.append(gameObjcet)
		// Add behaviour weak references to application.
		for component in gameObjcet.components {
			// TODO: registerable.
			if let updatableBehaviour = component.value as? Updatable {
				updatableBehaviours.append(Weak(reference: updatableBehaviour))
			}
			if let renderableBehaviour = component.value as? Renderable {
				renderableBehaviours.append(Weak(reference: renderableBehaviour))
			}
			if let lightableBehaviour = component.value as? Lightable {
				lightableBehaviours.append(Weak(reference: lightableBehaviour))
			}
		}
	}
	
	/// This function to invoke all updatable behaviours.
	func update() {
		for updatableBehaviour in updatableBehaviours { updatableBehaviour.reference?.update() }
	}
	
	/// This function to invoke all encodables.
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder) {
		// Light behaviours.
		var lightDatas = [LightData]()
		for lightableBehaviour in lightableBehaviours {
			guard let lightData = lightableBehaviour.reference?.lightData else { continue }
			lightDatas.append(lightData)
		}
		lightUniformBuffer.data.update(lightDatas)
		renderCommandEncoder.setFragmentBuffer(lightUniformBuffer.buffer, offset: lightUniformBuffer.offset, index: BufferIndex.lightBuffer.rawValue)
		
		// render behaviours.
		for renderableBehaviour in renderableBehaviours { renderableBehaviour.reference?.encode(to: renderCommandEncoder) }
	}
}

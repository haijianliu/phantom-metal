// Copyright © haijian. All rights reserved.

import MetalKit

class Scene: RenderEncodable {
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
	
	func update() {
		for updatableBehaviour in updatableBehaviours { updatableBehaviour.reference?.update() }
	}
	
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

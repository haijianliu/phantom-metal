// Copyright © haijian. All rights reserved.

import MetalKit

class Scene {
	/// The only game object references holder per scene.
	private var gameObjects = [GameObject]()
	
	/// Share uniform buffer by all the lights in this scene.
	private var lightUniformBuffer: TripleBuffer<LightBuffer>
	
	// TODO: clean up nil reference.
	/// A [contiguous array](http://jordansmith.io/on-performant-arrays-in-swift/) to update behaviour weak reference list in real time, reserving a capacity of 256 elements.
	
	// TODO: in renderpass manager.
	var renderPasses = [RenderPass]()
	
	var updatableBehaviours = ContiguousArray<Weak<Updatable>>()
	var lightableBehaviours = ContiguousArray<Weak<Lightable>>()
	
	
	init?(device: MTLDevice) {
		// TODO: use library settings.
		updatableBehaviours.reserveCapacity(0xFF)
		lightableBehaviours.reserveCapacity(0xF)
		
		// Light uniform buffer.
		// TODO: init dynamic semaphore value
		guard let newBuffer = TripleBuffer<LightBuffer>(device) else { return nil }
		lightUniformBuffer = newBuffer
		
		// TODO: in renderpass manager.
		//		if let renderPass = ShadowMapRenderPass(view: view) {
		//			Application.sharedInstance.renderPasses.append(renderPass)
		//			Application.sharedInstance.viewDelegate.addRenderPass(renderPass)
		//		}
		if let renderPass = MainRenderPass(device: device) {
			renderPasses.append(renderPass)
			Application.sharedInstance.viewDelegate.addRenderPass(renderPass)
		}
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
			// TODO: add to mutiple renderpasses.
			if let renderableBehaviour = component.value as? Renderable {
				renderPasses[0].renderableBehaviours.append(Weak(reference: renderableBehaviour))
			}
			if let lightableBehaviour = component.value as? Lightable {
				lightableBehaviours.append(Weak(reference: lightableBehaviour))
			}
		}
	}
	
	/// This function to invoke all updatable behaviours.
	func update() {
		// Light behaviours.
		var lightDatas = [LightData]()
		for lightableBehaviour in lightableBehaviours {
			guard let lightData = lightableBehaviour.reference?.lightData else { continue }
			lightDatas.append(lightData)
		}
		lightUniformBuffer.data.update(lightDatas)
		lightUniformBuffer.endWritting()
		
		for updatableBehaviour in updatableBehaviours { updatableBehaviour.reference?.update() }
	}
	
	/// This function to invoke all encodables.
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder) {
		renderCommandEncoder.setFragmentBuffer(lightUniformBuffer.buffer, offset: lightUniformBuffer.offset, index: BufferIndex.lightBuffer.rawValue)
		
		// TODO: refactor.
		// render behaviours.
		for renderableBehaviour in renderPasses[0].renderableBehaviours { renderableBehaviour.reference?.encode(to: renderCommandEncoder) }
	}
}

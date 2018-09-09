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
	var renderPasses = [String: RenderPass]()
	
	var updatableBehaviours = ContiguousArray<Weak<Updatable>>()
	var lightableBehaviours = ContiguousArray<Weak<Lightable>>()
	
	
	init?(device: MTLDevice) {
		// TODO: use library settings.
		updatableBehaviours.reserveCapacity(0xFF)
		lightableBehaviours.reserveCapacity(0xF)
		
		// Light uniform buffer.
		// TODO: init dynamic semaphore value
		guard let lightBuffer = TripleBuffer<LightBuffer>(device) else { return nil }
		lightUniformBuffer = lightBuffer
	}
	
	func addGameObject(_ gameObject: GameObject) {
		// Setup components.
		for component in gameObject.components {
			// Invoke registrables.
			if let registralbe = component.value as? Registrable {
				registralbe.register()
			}
			// Add behaviour weak references to application.
			if let updatableBehaviour = component.value as? Updatable {
				updatableBehaviours.append(Weak(reference: updatableBehaviour))
			}
			if let lightableBehaviour = component.value as? Lightable {
				lightableBehaviours.append(Weak(reference: lightableBehaviour))
			}
		}
		
		// Register renderable behaviours to renderpasses.
		if let renderer: MeshRenderer = gameObject.getComponent() {
			if renderer.material.shader.shaderType == .postEffect {
				renderPasses[String(describing: PostEffectRenderPass.self)]?.renderableBehaviours.append(Weak(reference: renderer))
				gameObjects.append(gameObject)
				return
			}
		}
		if let renderer: MeshRenderer = gameObject.getComponent() {
			renderPasses[String(describing: MainRenderPass.self)]?.renderableBehaviours.append(Weak(reference: renderer))
		}
		if let renderer: ShadowRenderer = gameObject.getComponent() {
			renderPasses[String(describing: ShadowMapRenderPass.self)]?.renderableBehaviours.append(Weak(reference: renderer))
		}
		
		// Add gameobject strong references.
		gameObjects.append(gameObject)
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
	}
}

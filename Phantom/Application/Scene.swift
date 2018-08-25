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
		guard let newBuffer = TripleBuffer<LightBuffer>(device) else { return nil }
		lightUniformBuffer = newBuffer
		
		// TODO: order.
		// TODO: in renderpass manager.
		if let renderPass = ShadowMapRenderPass(device: device) {
			renderPasses[String(describing: ShadowMapRenderPass.self)] = renderPass
			Application.sharedInstance.viewDelegate.addRenderPass(renderPass)
		}
		
		if let renderPass = MainRenderPass(device: device) {
			renderPasses[String(describing: MainRenderPass.self)] = renderPass
			Application.sharedInstance.viewDelegate.addRenderPass(renderPass)
		}
		
		// Set shadowmap renderpass target to main renderpass texture.
		let mainRenderPass = renderPasses[String(describing: MainRenderPass.self)] as? MainRenderPass
		let shadowMapRenderPass = renderPasses[String(describing: ShadowMapRenderPass.self)] as? ShadowMapRenderPass
		// TODO: renderpass targets.
		mainRenderPass?.shadowMap = shadowMapRenderPass?.texture.makeTextureView(pixelFormat: MTLPixelFormat.depth32Float)
	}
	
	func addGameObject(_ gameObjcet: GameObject) {
		// TODO: refactor.
		// If there is mesh renderer attached, add this render bebaviour to main renderpass.
		// If mesh casts shadows, add a new shadow renderer component and add this render behaviour to shadowmap renderpass.
		if let meshRenderer: MeshRenderer = gameObjcet.getComponent() {
			meshRenderer.material.shader.load()
			meshRenderer.mesh.load(from: meshRenderer.material.shader.vertexDescriptor)
			renderPasses[String(describing: MainRenderPass.self)]?.renderableBehaviours.append(Weak(reference: meshRenderer))
			if meshRenderer.castShadows == true {
				let _: ShadowRenderer? = gameObjcet.addComponent()
				guard let shadowRenderer: ShadowRenderer = gameObjcet.getComponent() else { return }
				shadowRenderer.mesh.mdlMesh = meshRenderer.mesh.mdlMesh // TODO: refactor
				shadowRenderer.material.shader.shaderType = .shadowMap
				shadowRenderer.material.shader.load()
				shadowRenderer.mesh.load(from: shadowRenderer.material.shader.vertexDescriptor)
				renderPasses[String(describing: ShadowMapRenderPass.self)]?.renderableBehaviours.append(Weak(reference: shadowRenderer))
			}
		}
	
		// Add gameobject strong references.
		gameObjects.append(gameObjcet)
		// Add behaviour weak references to application.
		for component in gameObjcet.components {
			// TODO: registerable.
			if let updatableBehaviour = component.value as? Updatable {
				updatableBehaviours.append(Weak(reference: updatableBehaviour))
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
	}
}

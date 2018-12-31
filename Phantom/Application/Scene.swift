// Copyright © haijian. All rights reserved.

import MetalKit

class Scene {
	/// The only game object references holder per scene.
	private var gameObjects = [GameObject]()

	/// Share uniform buffer by all the lights in this scene.
	private var lightUniformBuffer: TripleBuffer<LightBuffer>

	// TODO: clean up nil reference.
	// TODO: in view delegate.
	// TODO: test using of Set<...>
	/// A [contiguous array](http://jordansmith.io/on-performant-arrays-in-swift/) to update behaviour weak reference list in real time, reserving a capacity of 256 elements.
	var updatableBehaviours = ContiguousArray<Weak<Updatable>>()
	var lightableBehaviours = ContiguousArray<Weak<Lightable>>()
	#if os(iOS)
	var touchableBehaviours = ContiguousArray<Weak<Touchabe>>()
	#endif

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
			#if os(iOS)
			if let touchableBehaviour = component.value as? Touchabe {
				touchableBehaviours.append(Weak(reference: touchableBehaviour))
			}
			#endif
		}

		// TODO: generic add functions.
		// Register renderable behaviours to renderpasses.
		if let renderer: MeshRenderer = gameObject.getComponent() {
			if renderer.material.shader.shaderType == .postEffect {
				Application.sharedInstance.viewDelegate.renderPasses[String(describing: PostEffectRenderPass.self)]?.renderableBehaviours.append(Weak(reference: renderer))
				gameObjects.append(gameObject)
				return
			}
		}
		if let renderer: MeshRenderer = gameObject.getComponent() {
			Application.sharedInstance.viewDelegate.renderPasses[String(describing: MainRenderPass.self)]?.renderableBehaviours.append(Weak(reference: renderer))
		}
		if let renderer: ShadowRenderer = gameObject.getComponent() {
			Application.sharedInstance.viewDelegate.renderPasses[String(describing: ShadowMapRenderPass.self)]?.renderableBehaviours.append(Weak(reference: renderer))
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

#if os(iOS)

import UIKit

extension Scene {
	func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touchableBehaviour in touchableBehaviours { touchableBehaviour.reference?.touchesBegan?(touches, with: event) }
	}

	func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touchableBehaviour in touchableBehaviours { touchableBehaviour.reference?.touchesMoved?(touches, with: event) }
	}

	func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touchableBehaviour in touchableBehaviours { touchableBehaviour.reference?.touchesEnded?(touches, with: event) }
	}

	func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touchableBehaviour in touchableBehaviours { touchableBehaviour.reference?.touchesCancelled?(touches, with: event) }
	}
}

#endif

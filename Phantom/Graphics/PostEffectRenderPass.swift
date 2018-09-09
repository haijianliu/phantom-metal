// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: auto resolve renderpass.
// TODO: mutiple settings render pass vailiation.
class PostEffectRenderPass: RenderPass {
	var colorMap: MTLTexture?
	var depthMap: MTLTexture?
	
	required init?(device: MTLDevice) {
		// TODO: renderpass setting, renderpass type.
		let depthStencilDescriptor = MTLDepthStencilDescriptor()
		super.init(device: device, depthStencilDescriptor: depthStencilDescriptor)
	}
	
	override func register() {
		guard let gameObject = GameObject.createPlane(withDimensions: Vector2(2, 2), segments: Uint2(1, 1), shaderType: .postEffect) else { return }
		Application.addGameObject(gameObject)
	}
	
	override func draw(in view: MTKView, by commandBuffer: MTLCommandBuffer) {
				guard let blitCommandeEncoder = commandBuffer.makeBlitCommandEncoder() else { return }
				blitCommandeEncoder.generateMipmaps(for: colorMap!)
				blitCommandeEncoder.endEncoding()
		
		// TODO: safety skip all.
		// TODO: customize this function varying from render passes.
		guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
		
		// TODO: safety skip all.
		guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
		
		// Start encoding and setup debug infomation
		renderCommandEncoder.label = String(describing: self)
		// Render pass encoding.
		renderCommandEncoder.setDepthStencilState(depthStencilState)
		
		// Setup shadow map.
		if let color = colorMap {
			// TODO: sampler states. (MTLSamplerDescriptor) (renderCommandEncoder.setFragmentSamplerStates)
			// TODO: use texture functions.
			renderCommandEncoder.setFragmentTexture(color, index: TextureType.color.textureIndex)
		}
		// Setup shadow map.
		if let shadow = depthMap {
			// TODO: sampler states. (MTLSamplerDescriptor) (renderCommandEncoder.setFragmentSamplerStates)
			// TODO: use texture functions.
			renderCommandEncoder.setFragmentTexture(shadow, index: TextureType.shadow.textureIndex)
		}
		
		// Encode camera.
		guard let camera = Camera.shadow else { return }
		camera.encode(to: renderCommandEncoder)
		
		// render behaviours.
		for renderableBehaviour in renderableBehaviours { renderableBehaviour.reference?.encode(to: renderCommandEncoder) }
		
		// End encoding.
		renderCommandEncoder.endEncoding()
	}
}

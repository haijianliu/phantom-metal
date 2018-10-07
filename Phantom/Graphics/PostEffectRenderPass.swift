// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: auto resolve renderpass.
// TODO: mutiple settings render pass vailiation.
class PostEffectRenderPass: RenderPass {
	
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
		// TODO: safety skip all.
		// TODO: customize this function varying from render passes.
		guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
		
		// Blit view targets.
		guard let currentViewColor = renderPassDescriptor.colorAttachments[0].texture else { return }
		guard let currentViewDepth = renderPassDescriptor.depthAttachment.texture else { return }
		guard let blitCommandEncoder = commandBuffer.makeBlitCommandEncoder() else { return }
		
		guard let color = blitViewColor(in: view, by: blitCommandEncoder, from: currentViewColor, mipmapped: true) else { return }
		guard let depth = blitViewDepth(in: view, by: blitCommandEncoder, from: currentViewDepth) else { return }
		
		blitCommandEncoder.endEncoding()
		
		
		// Setup render command.
		// TODO: safety skip all.
		guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
		
		// Start encoding and setup debug infomation
		renderCommandEncoder.label = String(describing: self)
		// Render pass encoding.
		renderCommandEncoder.setDepthStencilState(depthStencilState)
		
		// Setup effect sources.
		// TODO: sampler states. (MTLSamplerDescriptor) (renderCommandEncoder.setFragmentSamplerStates)
		// TODO: use texture functions.
		renderCommandEncoder.setFragmentTexture(color, index: TextureType.color.textureIndex)
		renderCommandEncoder.setFragmentTexture(depth, index: TextureType.shadow.textureIndex)
		
		// Encode camera.
		// TODO: will use main camera.
		guard let camera = Camera.shadow else { return }
		camera.encode(to: renderCommandEncoder)
		
		// render behaviours.
		for renderableBehaviour in renderableBehaviours { renderableBehaviour.reference?.encode(to: renderCommandEncoder) }
		
		// End encoding.
		renderCommandEncoder.endEncoding()
	}
}

// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: mutiple settings render pass vailiation.
class MainRenderPass: RenderPass {
	var shadowMap: MTLTexture?
	
	required init?(device: MTLDevice) {
		let depthStencilDescriptor = MTLDepthStencilDescriptor()
		depthStencilDescriptor.depthCompareFunction = .less
		depthStencilDescriptor.isDepthWriteEnabled = true
		super.init(device: device, depthStencilDescriptor: depthStencilDescriptor)
	}
	
	override func draw(in view: MTKView, by commandBuffer: MTLCommandBuffer) {
		// TODO: safety skip all.
		// TODO: customize this function varying from render passes.
		guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
		guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
		
		// Start encoding and setup debug infomation
		renderCommandEncoder.label = String(describing: self)
		// Render pass encoding.
		renderCommandEncoder.setDepthStencilState(depthStencilState)
		
		// Setup shadow map.
		if let shadow = shadowMap {
			renderCommandEncoder.setFragmentTexture(shadow, index: TextureType.shadow.textureIndex) // TODO: use texture functions.
		}
		
		// Encode scene (lights).
		Application.sharedInstance.scene?.encode(to: renderCommandEncoder)
		
		// Encode camera.
		guard let camera = Camera.main else { return }
		camera.encode(to: renderCommandEncoder)
		
		// render behaviours.
		for renderableBehaviour in renderableBehaviours { renderableBehaviour.reference?.encode(to: renderCommandEncoder) }
		
		// End encoding.
		renderCommandEncoder.endEncoding()
		
		// TODO: render target.
		// If rendering to core animation layer.
		if let drawable = view.currentDrawable { commandBuffer.present(drawable) }
	}
}

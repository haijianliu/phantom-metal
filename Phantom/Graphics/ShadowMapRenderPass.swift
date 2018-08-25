// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: mutiple settings render pass vailiation.
class ShadowMapRenderPass: RenderPass {
	// TODO: inherate from renderpass.
	let texture: MTLTexture  //TODO: double textures for asyc render?
	
	required init?(device: MTLDevice) {
		let textureDescriptor = MTLTextureDescriptor()
		textureDescriptor.height = 512 // TODO: set size.
		textureDescriptor.width = 512
		textureDescriptor.usage = [.shaderRead, .renderTarget]
		textureDescriptor.pixelFormat = ShaderType.shadowMap.depthAttachmentPixelFormat
		textureDescriptor.resourceOptions = .storageModePrivate
		guard let newTexture = device.makeTexture(descriptor: textureDescriptor) else { return nil }
		texture = newTexture
		
		// TODO: renderpass setting, renderpass type.
		let depthStencilDescriptor = MTLDepthStencilDescriptor()
		depthStencilDescriptor.depthCompareFunction = .less
		depthStencilDescriptor.isDepthWriteEnabled = true
		super.init(device: device, depthStencilDescriptor: depthStencilDescriptor)
	}
	
	override func draw(in view: MTKView, by commandBuffer: MTLCommandBuffer) {
		// TODO: customize this function varying from render passes.
		let renderPassDescriptor = MTLRenderPassDescriptor()
		// TODO: init forward.
		renderPassDescriptor.depthAttachment.storeAction = .store
		renderPassDescriptor.depthAttachment.loadAction = .clear
		renderPassDescriptor.depthAttachment.clearDepth = 1
		renderPassDescriptor.depthAttachment.texture = texture
		
		guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
		
		// Start encoding and setup debug infomation
		renderCommandEncoder.label = String(describing: self)
		// Render pass encoding.
		renderCommandEncoder.setDepthStencilState(depthStencilState)
		
		Application.sharedInstance.scene?.encode(to: renderCommandEncoder)
		
		// render behaviours.
		for renderableBehaviour in renderableBehaviours { renderableBehaviour.reference?.encode(to: renderCommandEncoder) }
		
		// End encoding.
		renderCommandEncoder.endEncoding()
	}
}

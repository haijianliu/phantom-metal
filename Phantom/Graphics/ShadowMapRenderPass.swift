// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: mutiple settings render pass vailiation.
class ShadowMapRenderPass: RenderPass {
	
	let texture: MTLTexture  //TODO: double textures for asyc render?
	let depthTexture: MTLTexture
	
	required init?(device: MTLDevice) {
		let textureDescriptor = MTLTextureDescriptor()
		textureDescriptor.height = 512
		textureDescriptor.width = 512
		textureDescriptor.usage = .renderTarget
		textureDescriptor.pixelFormat = ShaderType.shadowMap.colorAttachmentsPixelFormat[0]
		guard let newTexture = device.makeTexture(descriptor: textureDescriptor) else { return nil }
		texture = newTexture
		textureDescriptor.pixelFormat = ShaderType.shadowMap.depthAttachmentPixelFormat
		textureDescriptor.resourceOptions = .storageModePrivate
		guard let newDepthTexture = device.makeTexture(descriptor: textureDescriptor) else { return nil }
		depthTexture = newDepthTexture
		
		let depthStencilDescriptor = MTLDepthStencilDescriptor()
		depthStencilDescriptor.depthCompareFunction = .less
		depthStencilDescriptor.isDepthWriteEnabled = true
		super.init(device: device, depthStencilDescriptor: depthStencilDescriptor)
	}
	
	override func draw(in view: MTKView, by commandBuffer: MTLCommandBuffer) {
		// TODO: customize this function varying from render passes.
		let renderPassDescriptor = MTLRenderPassDescriptor()
		renderPassDescriptor.colorAttachments[0].texture = texture
		renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)
		renderPassDescriptor.colorAttachments[0].storeAction = .store
		renderPassDescriptor.colorAttachments[0].loadAction = .clear
		renderPassDescriptor.depthAttachment.texture = depthTexture
		renderPassDescriptor.depthAttachment.storeAction = .dontCare
		renderPassDescriptor.depthAttachment.loadAction = .clear
		renderPassDescriptor.stencilAttachment.texture = depthTexture
		renderPassDescriptor.stencilAttachment.storeAction = .dontCare
		renderPassDescriptor.stencilAttachment.loadAction = .clear
		
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

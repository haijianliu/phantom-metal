// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: mutiple settings render pass vailiation.
class ShadowMapRenderPass: RenderPass {
	
	required init?(device: MTLDevice) {
		// TODO: renderpass setting, renderpass type.
		let depthStencilDescriptor = MTLDepthStencilDescriptor()
		depthStencilDescriptor.depthCompareFunction = .less
		depthStencilDescriptor.isDepthWriteEnabled = true
		super.init(device: device, depthStencilDescriptor: depthStencilDescriptor)
	}
	
	override func register() {
		let textureDescriptor = MTLTextureDescriptor()
		textureDescriptor.height = 512 // TODO: set size.
		textureDescriptor.width = 512
		textureDescriptor.usage = [.shaderRead, .renderTarget]
		textureDescriptor.pixelFormat = ShaderType.shadowMap.depthAttachmentPixelFormat
		textureDescriptor.resourceOptions = .storageModePrivate
		guard let newTexture = depthStencilState.device.makeTexture(descriptor: textureDescriptor) else { return }
		targets.append(newTexture)
		
		// TODO: customize this function varying from render passes.
		renderPassDescriptor.depthAttachment.storeAction = .store
		renderPassDescriptor.depthAttachment.loadAction = .clear
		renderPassDescriptor.depthAttachment.clearDepth = 1
		renderPassDescriptor.depthAttachment.texture = targets[0] // TODO: for loop.
	}
	
	override func draw(in view: MTKView, by commandBuffer: MTLCommandBuffer) {
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

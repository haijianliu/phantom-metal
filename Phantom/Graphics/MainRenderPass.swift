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
	
	override func register() {
		let textureDescriptor = MTLTextureDescriptor()
		textureDescriptor.height = 1200 // TODO: set size.
		textureDescriptor.width = 1600
//		textureDescriptor.sampleCount = ShaderType.standard.sampleCount
		textureDescriptor.usage = [.shaderRead, .renderTarget]
		textureDescriptor.pixelFormat = ShaderType.standard.colorAttachmentsPixelFormat[0]
		textureDescriptor.resourceOptions = .storageModePrivate
		textureDescriptor.mipmapLevelCount = 5
		guard let color = depthStencilState.device.makeTexture(descriptor: textureDescriptor) else { return }
		targets.append(color)
		textureDescriptor.pixelFormat = ShaderType.standard.depthAttachmentPixelFormat
		guard let depth = depthStencilState.device.makeTexture(descriptor: textureDescriptor) else { return }
		targets.append(depth)
		
		// TODO: customize this function varying from render passes.
		renderPassDescriptor.colorAttachments[0].storeAction = .store
		renderPassDescriptor.colorAttachments[0].loadAction = .clear
		renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)
		renderPassDescriptor.colorAttachments[0].texture = targets[0] // TODO: for loop.
		renderPassDescriptor.depthAttachment.storeAction = .store
		renderPassDescriptor.depthAttachment.loadAction = .clear
		renderPassDescriptor.depthAttachment.clearDepth = 1
		renderPassDescriptor.depthAttachment.texture = targets[1] // TODO: for loop.
//		renderPassDescriptor.stencilAttachment.storeAction = .dontCare
//		renderPassDescriptor.stencilAttachment.loadAction = .clear
//		renderPassDescriptor.stencilAttachment.clearStencil = 0
//		renderPassDescriptor.stencilAttachment.texture = targets[1] // TODO: for loop.
	}
	
	override func draw(in view: MTKView, by commandBuffer: MTLCommandBuffer) {
		// TODO: safety skip all.
		// TODO: customize this function varying from render passes.
//		guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
//		print(renderPassDescriptor)
		
		guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
		
		// Start encoding and setup debug infomation
		renderCommandEncoder.label = String(describing: self)
		// Render pass encoding.
		renderCommandEncoder.setDepthStencilState(depthStencilState)
		
		// Setup shadow map.
		if let shadow = shadowMap {
			// TODO: sampler states. (MTLSamplerDescriptor) (renderCommandEncoder.setFragmentSamplerStates)
			// TODO: use texture functions.
			renderCommandEncoder.setFragmentTexture(shadow, index: TextureType.shadow.textureIndex)
		}
		
		// Encode scene (lights).
		Application.sharedInstance.scene?.encode(to: renderCommandEncoder)
		
		// Encode camera.
		guard let camera = Camera.main else { return }
		camera.encode(to: renderCommandEncoder)
		
		// Set shadowmap camera buffers.
		guard let shadowCamera = Camera.shadow else { return }
		renderCommandEncoder.setFragmentBuffer(shadowCamera.cameraUniformBuffer.buffer, offset: shadowCamera.cameraUniformBuffer.offset, index: BufferIndex.shadowMapBuffer.rawValue)
		
		// render behaviours.
		for renderableBehaviour in renderableBehaviours { renderableBehaviour.reference?.encode(to: renderCommandEncoder) }
		
		// End encoding.
		renderCommandEncoder.endEncoding()
	}
}

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
		guard let currentViewColor = renderPassDescriptor.colorAttachments[0].texture else { return }
		guard let currentViewDepth = renderPassDescriptor.depthAttachment.texture else { return }
		
		// Dispath init view textures.
		guard let color = viewColor, let depth = viewDepth else {
			DispatchQueue.global(qos: .background).async {
				let colorDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: currentViewColor.pixelFormat, width: currentViewColor.width, height: currentViewColor.height, mipmapped: true)
				let depthDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: currentViewDepth.pixelFormat, width: currentViewDepth.width, height: currentViewDepth.height, mipmapped: false)
				depthDescriptor.storageMode = .private
				self.viewColor = view.device?.makeTexture(descriptor: colorDescriptor)
				self.viewDepth = view.device?.makeTexture(descriptor: depthDescriptor)
				self.isViewDirty = false
			}
			return
		}
		
		let origin = MTLOrigin(x: 0, y: 0, z: 0)
		let size = MTLSize(width: currentViewColor.width, height: currentViewColor.height, depth: currentViewColor.depth)

		if !isViewDirty && size.width == color.width && size.height == color.height {
			guard let blitCommandeEncoder = commandBuffer.makeBlitCommandEncoder() else { return }
			blitCommandeEncoder.copy(from: currentViewColor, sourceSlice: 0, sourceLevel: 0, sourceOrigin: origin, sourceSize: size, to: color, destinationSlice: 0, destinationLevel: 0, destinationOrigin: origin)
			blitCommandeEncoder.generateMipmaps(for: color)
			blitCommandeEncoder.copy(from: currentViewDepth, sourceSlice: 0, sourceLevel: 0, sourceOrigin: origin, sourceSize: size, to: depth, destinationSlice: 0, destinationLevel: 0, destinationOrigin: origin)
			blitCommandeEncoder.endEncoding()
		} else {
			viewColor = nil
			viewDepth = nil
			return
		}
		
		// TODO: safety skip all.
		guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
		
		// Start encoding and setup debug infomation
		renderCommandEncoder.label = String(describing: self)
		// Render pass encoding.
		renderCommandEncoder.setDepthStencilState(depthStencilState)
		
		// Setup shadow map.
//		if let color = colorMap {
			// TODO: sampler states. (MTLSamplerDescriptor) (renderCommandEncoder.setFragmentSamplerStates)
			// TODO: use texture functions.
			renderCommandEncoder.setFragmentTexture(color, index: TextureType.color.textureIndex)
//		}
		// Setup shadow map.
//		if let shadow = depthMap {
			// TODO: sampler states. (MTLSamplerDescriptor) (renderCommandEncoder.setFragmentSamplerStates)
			// TODO: use texture functions.
			renderCommandEncoder.setFragmentTexture(depth, index: TextureType.shadow.textureIndex)
//		}
		
		// Encode camera.
		guard let camera = Camera.shadow else { return }
		camera.encode(to: renderCommandEncoder)
		
		// render behaviours.
		for renderableBehaviour in renderableBehaviours { renderableBehaviour.reference?.encode(to: renderCommandEncoder) }
		
		// End encoding.
		renderCommandEncoder.endEncoding()
	}
}

// Copyright © haijian. All rights reserved.

import MetalKit

class RenderPass: Drawable, Registrable {
	// TODO: use texture class.
	// TODO: color attachments dictionary.
	// TODO: double textures for asyc render?
	var targets = [MTLTexture]()
	
	var isViewDirty = false
	
	private var viewColor: MTLTexture? {
		didSet {
			isViewDirty = (viewColor == nil) ? true : false
		}
	}
	
	private var viewDepth: MTLTexture? {
		didSet {
			isViewDirty = (viewDepth == nil) ? true : false
		}
	}
	
	var renderableBehaviours = ContiguousArray<Weak<Renderable>>()
	
	var renderPassDescriptor = MTLRenderPassDescriptor()
	
	var depthStencilState: MTLDepthStencilState
	
	required convenience init?(device: MTLDevice) {
		let depthStencilDescriptor = MTLDepthStencilDescriptor()
		self.init(device: device, depthStencilDescriptor: depthStencilDescriptor)
	}
	
	init?(device: MTLDevice, depthStencilDescriptor: MTLDepthStencilDescriptor) {
		guard let newDepthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor) else { return nil }
		depthStencilState = newDepthStencilState
		renderableBehaviours.reserveCapacity(0xFF)
	}

	func register() { }
	
	func draw(in view: MTKView, by commandBuffer: MTLCommandBuffer) { }
	
	func blitViewColor(in view: MTKView, by blitCommandEncoder: MTLBlitCommandEncoder, from texture: MTLTexture, mipmapped: Bool = false) -> MTLTexture? {
		// Dispath init view textures.
		guard let color = viewColor else {
			DispatchQueue.global(qos: .background).async {
				let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: texture.pixelFormat, width: texture.width, height: texture.height, mipmapped: mipmapped)
				descriptor.storageMode = .private
				self.viewColor = view.device?.makeTexture(descriptor: descriptor)
			}
			blitCommandEncoder.endEncoding()
			return nil
		}
		
		// Encode blit command.
		if !isViewDirty && texture.width == color.width && texture.height == color.height {
			let origin = MTLOrigin(x: 0, y: 0, z: 0)
			let size = MTLSize(width: texture.width, height: texture.height, depth: texture.depth)
			blitCommandEncoder.copy(from: texture, sourceSlice: 0, sourceLevel: 0, sourceOrigin: origin, sourceSize: size, to: color, destinationSlice: 0, destinationLevel: 0, destinationOrigin: origin)
			if mipmapped {
				blitCommandEncoder.generateMipmaps(for: color)
			}
		} else {
			blitCommandEncoder.endEncoding()
			viewColor = nil
		}
		
		return viewColor
	}
	
	func blitViewDepth(in view: MTKView, by blitCommandEncoder: MTLBlitCommandEncoder, from texture: MTLTexture) -> MTLTexture? {
		// Dispath init view textures.
		guard let depth = viewDepth else {
			DispatchQueue.global(qos: .background).async {
				let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: texture.pixelFormat, width: texture.width, height: texture.height, mipmapped: false)
				descriptor.storageMode = .private
				self.viewDepth = view.device?.makeTexture(descriptor: descriptor)
			}
			blitCommandEncoder.endEncoding()
			return nil
		}
		
		// Encode blit command.
		if !isViewDirty && texture.width == depth.width && texture.height == depth.height {
			let origin = MTLOrigin(x: 0, y: 0, z: 0)
			let size = MTLSize(width: texture.width, height: texture.height, depth: texture.depth)
			blitCommandEncoder.copy(from: texture, sourceSlice: 0, sourceLevel: 0, sourceOrigin: origin, sourceSize: size, to: depth, destinationSlice: 0, destinationLevel: 0, destinationOrigin: origin)
		} else {
			blitCommandEncoder.endEncoding()
			viewDepth = nil
		}
		
		return viewDepth
	}
}

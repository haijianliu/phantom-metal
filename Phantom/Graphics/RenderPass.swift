// Copyright © haijian. All rights reserved.

import MetalKit

class RenderPass: Drawable, Registrable {
	// TODO: use texture class.
	// TODO: color attachments dictionary.
	// TODO: double textures for asyc render?
	var targets = [MTLTexture]()

	var renderableBehaviours = ContiguousArray<Weak<Renderable>>()

	var renderPassDescriptor = MTLRenderPassDescriptor()

	var depthStencilState: MTLDepthStencilState

	var isViewDirty = false

	private var viewTargets = [MTLTexture?](repeating: nil, count: RenderTargetType.allCases.count)

	private func getViewTarget(targetType: RenderTargetType, mipmapped: Bool) -> MTLTexture? {
		// Dispath init view textures.
		if viewTargets[targetType.rawValue] == nil {
			DispatchQueue.global(qos: .background).async {
				guard let target = Application.currentViewTarget(targetType: targetType) else { return }
				let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: target.pixelFormat, width: target.width, height: target.height, mipmapped: mipmapped)
				descriptor.resourceOptions = .storageModePrivate
				self.viewTargets[targetType.rawValue] = Application.sharedInstance.device?.makeTexture(descriptor: descriptor)
				self.isViewDirty = false
			}
		}
		return viewTargets[targetType.rawValue]
	}

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

	func blitViewTarget(by blitCommandEncoder: MTLBlitCommandEncoder, targetType: RenderTargetType, mipmapped: Bool) -> MTLTexture? {
		// Dispath init view textures.
		guard let destinationTexture = getViewTarget(targetType: targetType, mipmapped: mipmapped) else {
			blitCommandEncoder.endEncoding()
			return nil
		}

		guard let sourceTexture = Application.currentViewTarget(targetType: targetType) else {
			blitCommandEncoder.endEncoding()
			return nil
		}

		// Encode blit command.
		if !isViewDirty && sourceTexture.width == destinationTexture.width && sourceTexture.height == destinationTexture.height {
			let origin = MTLOrigin(x: 0, y: 0, z: 0)
			let size = MTLSize(width: destinationTexture.width, height: destinationTexture.height, depth: destinationTexture.depth)
			blitCommandEncoder.copy(from: sourceTexture, sourceSlice: 0, sourceLevel: 0, sourceOrigin: origin, sourceSize: size, to: destinationTexture, destinationSlice: 0, destinationLevel: 0, destinationOrigin: origin)
			if mipmapped {
				blitCommandEncoder.generateMipmaps(for: destinationTexture)
			}
		} else {
			blitCommandEncoder.endEncoding()
			viewTargets[targetType.rawValue] = nil
			isViewDirty = true
		}

		return viewTargets[targetType.rawValue]
	}
}

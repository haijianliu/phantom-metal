// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: mutiple settings render pass vailiation.
class MainRenderPass: RenderPass {
	
	required init?(device: MTLDevice) {
		let depthStencilDescriptor = MTLDepthStencilDescriptor()
		depthStencilDescriptor.depthCompareFunction = .less
		depthStencilDescriptor.isDepthWriteEnabled = true
		super.init(device: device, depthStencilDescriptor: depthStencilDescriptor)
	}
	
	override func draw(in view: MTKView, by commandBuffer: MTLCommandBuffer) {
		// TODO: customize this function varying from render passes.
		guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
		guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
		
		// Start encoding and setup debug infomation
		renderEncoder.label = String(describing: self)
		// Render pass encoding.
		renderEncoder.setDepthStencilState(depthStencilState)
		
		Application.sharedInstance.scene?.encode(to: renderEncoder)
		
		// End encoding.
		renderEncoder.endEncoding()
		
		// TODO: render target.
		// If rendering to core animation layer.
		if let drawable = view.currentDrawable { commandBuffer.present(drawable) }
	}
}

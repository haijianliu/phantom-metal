// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: mutiple settings render pass vailiation.
class RenderPass {
	
	// TODO: Add front and back face stencil properties.
	var depthWrite = true
	var compareFunction = MTLCompareFunction.less
	private var depthStencilState: MTLDepthStencilState
	
	// TODO: in scene.
	private var lightUniformBuffer: TripleBuffer<LightBuffer>
	
	init?(view: MTKView) {
		let depthStencilDescriptor = MTLDepthStencilDescriptor()
		depthStencilDescriptor.depthCompareFunction = compareFunction
		depthStencilDescriptor.isDepthWriteEnabled = depthWrite
		guard let newDepthStencilState = view.device?.makeDepthStencilState(descriptor: depthStencilDescriptor) else { return nil }
		depthStencilState = newDepthStencilState
		
		guard let device = view.device else { return nil }
		// TODO: init dynamic semaphore value
		guard let newBuffer = TripleBuffer<LightBuffer>(device) else { return nil }
		lightUniformBuffer = newBuffer
	}
}

extension RenderPass: Drawable {
	func draw(in view: MTKView, by commandBuffer: MTLCommandBuffer) {
		// TODO: customize this function varying from render passes.
		guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
		guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
		
		// Start encoding and setup debug infomation
		renderEncoder.label = String(describing: self)
		// Render pass encoding.
		renderEncoder.setDepthStencilState(depthStencilState)
		
		// Light behaviours.
		var lightDatas = [LightData]()
		for lightableBehaviour in Application.sharedInstance.lightableBehaviours {
			guard let lightData = lightableBehaviour.reference?.lightData else { continue }
			lightDatas.append(lightData)
		}
		lightUniformBuffer.data.update(lightDatas)
		renderEncoder.setFragmentBuffer(lightUniformBuffer.buffer, offset: lightUniformBuffer.offset, index: BufferIndex.lightBuffer.rawValue)
		
		// render behaviours.
		for renderableBehaviour in Application.sharedInstance.renderableBehaviours { renderableBehaviour.reference?.encode(to: renderEncoder) }
		
		// End encoding.
		renderEncoder.endEncoding()
		
		// TODO: render target.
		// If rendering to core animation layer.
		if let drawable = view.currentDrawable { commandBuffer.present(drawable) }
	}
}

// Copyright © haijian. All rights reserved.

// Our platform independent renderer class

import Metal
import MetalKit

class Renderer: NSObject, MTKViewDelegate {

	let commandQueue: MTLCommandQueue
	var depthState: MTLDepthStencilState
	
	var gameObject: GameObject?

	init?(mtkView: MTKView) {
		// Set device
		guard let device = mtkView.device else { return nil }
		
		guard let queue = mtkView.device?.makeCommandQueue() else { return nil }
		self.commandQueue = queue

		// depth descriptor
		let depthStateDesciptor = MTLDepthStencilDescriptor()
		depthStateDesciptor.depthCompareFunction = MTLCompareFunction.less
		depthStateDesciptor.isDepthWriteEnabled = true
		guard let state = device.makeDepthStencilState(descriptor:depthStateDesciptor) else { return nil }
		depthState = state
		
		super.init()
	}

	class func buildRenderPipelineWithDevice(device: MTLDevice, metalKitView: MTKView, mtlVertexDescriptor: MTLVertexDescriptor) throws -> MTLRenderPipelineState {
		// Build a render state pipeline object

		let library = device.makeDefaultLibrary()

		let vertexFunction = library?.makeFunction(name: "vertexShader")
		let fragmentFunction = library?.makeFunction(name: "fragmentShader")

		let pipelineDescriptor = MTLRenderPipelineDescriptor()
		pipelineDescriptor.label = "RenderPipeline"
		pipelineDescriptor.sampleCount = metalKitView.sampleCount
		pipelineDescriptor.vertexFunction = vertexFunction
		pipelineDescriptor.fragmentFunction = fragmentFunction
		pipelineDescriptor.vertexDescriptor = mtlVertexDescriptor

		pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
		pipelineDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
		pipelineDescriptor.stencilAttachmentPixelFormat = metalKitView.depthStencilPixelFormat

		return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
	}


	func draw(in view: MTKView) {
		// Per frame updates hare
		
		gameObject?.transform?.update()

		if let commandBuffer = commandQueue.makeCommandBuffer() {
			
			let renderPassDescriptor = view.currentRenderPassDescriptor

			if let renderPassDescriptor = renderPassDescriptor, let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {

				/// Final pass rendering code here
				renderEncoder.label = "Primary Render Encoder"

				renderEncoder.pushDebugGroup("Draw Box")

				renderEncoder.setCullMode(.back)

				renderEncoder.setFrontFacing(.counterClockwise)

				let meshRenderer: MeshRenderer? = gameObject?.getComponent()
				renderEncoder.setRenderPipelineState((meshRenderer?.pipelineState)!)

				renderEncoder.setDepthStencilState(depthState)

				renderEncoder.setVertexBuffer(gameObject?.transform?.dynamicUniformBuffer, offset: 0, index: BufferIndex.uniforms.rawValue)
				
				for (index, element) in (meshRenderer?.mesh?.mtkMesh.vertexDescriptor.layouts.enumerated())! {
					guard let layout = element as? MDLVertexBufferLayout else {
						return
					}

					if layout.stride != 0 {
						let buffer = meshRenderer?.mesh?.mtkMesh.vertexBuffers[index]
						renderEncoder.setVertexBuffer(buffer?.buffer, offset: (buffer?.offset)!, index: index)
					}
				}

				renderEncoder.setFragmentTexture(meshRenderer?.texture?.mtlTexture, index: TextureIndex.color.rawValue)

				for submesh in (meshRenderer?.mesh?.mtkMesh.submeshes)! {
						renderEncoder.drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
				}

				renderEncoder.popDebugGroup()

				renderEncoder.endEncoding()

				if let drawable = view.currentDrawable {
					commandBuffer.present(drawable)
				}
			}

			commandBuffer.commit()
		}
	}

	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
		// Respond to drawable size or orientation changes here

		let aspect = Float(size.width) / Float(size.height)
		gameObject?.transform?.projectionMatrix = Math.perspective(fovyRadians: Math.radians(65), aspect: aspect, near: 0.1, far: 100.0)
	}
}


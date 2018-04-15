// Copyright © haijian. All rights reserved.

// Our platform independent renderer class

import Metal
import MetalKit

class Renderer: NSObject, MTKViewDelegate {
	
	let commandQueue: MTLCommandQueue
	var depthState: MTLDepthStencilState
	
	var application: Application?

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


	func draw(in view: MTKView) {
		// Per frame updates hare
		guard let gameObjects = application?.gameObjects else { return }
		for gameObject in gameObjects {
			guard let meshRenderer: MeshRenderer = gameObject.getComponent() else {
				gameObject.transform.update()
				continue
			}
			drawGameObject(meshRenderer: meshRenderer, view: view)
		}
	}

	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
		// Respond to drawable size or orientation changes here

		// TODO: Camera
		let aspect = Float(size.width) / Float(size.height)
		application?.gameObjects[0].transform.projectionMatrix = Math.perspective(fovyRadians: Math.radians(65), aspect: aspect, near: 0.1, far: 100.0)
	}
	
	private func drawGameObject(meshRenderer: MeshRenderer, view: MTKView) {

		let semaphore = meshRenderer.transform.inFlightSemaphore
		_ = semaphore.wait(timeout: .distantFuture)
		
		if let commandBuffer = commandQueue.makeCommandBuffer() {
			
			commandBuffer.addCompletedHandler() { _ in semaphore.signal() }
			
			meshRenderer.transform.update()
			
			let renderPassDescriptor = view.currentRenderPassDescriptor
			
			if let renderPassDescriptor = renderPassDescriptor, let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
				
				/// Final pass rendering code here
				renderEncoder.label = "Primary Render Encoder"
				
				renderEncoder.pushDebugGroup("Draw Box")
				
				renderEncoder.setCullMode(.back)
				
				renderEncoder.setFrontFacing(.counterClockwise)
			
				renderEncoder.setRenderPipelineState(meshRenderer.pipelineState!)
				
				renderEncoder.setDepthStencilState(depthState)
				
				renderEncoder.setVertexBuffer(meshRenderer.transform.dynamicUniformBuffer, offset: meshRenderer.transform.uniformBufferOffset, index: BufferIndex.uniforms.rawValue)
				
				for (index, element) in (meshRenderer.mesh?.mtkMesh.vertexDescriptor.layouts.enumerated())! {
					guard let layout = element as? MDLVertexBufferLayout else {
						return
					}
					
					if layout.stride != 0 {
						let buffer = meshRenderer.mesh?.mtkMesh.vertexBuffers[index]
						renderEncoder.setVertexBuffer(buffer?.buffer, offset: (buffer?.offset)!, index: index)
					}
				}
				
				renderEncoder.setFragmentTexture(meshRenderer.texture?.mtlTexture, index: TextureIndex.color.rawValue)
				
				for submesh in (meshRenderer.mesh?.mtkMesh.submeshes)! {
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
}

extension Renderer {
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
}


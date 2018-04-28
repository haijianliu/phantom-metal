// Copyright © haijian. All rights reserved.

// Our platform independent renderer class

import Metal
import MetalKit

class ViewDelegate: NSObject, MTKViewDelegate {
	
	let commandQueue: MTLCommandQueue
	var depthState: MTLDepthStencilState

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
		// update Behaviours
		// TODO: multi-thread update
		for updateBehaviour in Application.sharedInstance.updateBehaviours {
			updateBehaviour.reference?.update()
		}
		
		// update drawable behaviours
		// TODO: use drawable draw
		for drawBehaviour in Application.sharedInstance.drawBehaviours {
			guard let drawable = drawBehaviour.reference else { continue }
			drawGameObject(drawable: drawable, view: view)
		}
	}

	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
		// TODO: Camera
		let aspect = Float(size.width) / Float(size.height)
		guard let camera: Camera = Camera.main else { return }
		camera.projectionMatrix = Math.perspective(fovyRadians: camera.fieldOfView, aspect: aspect, near: camera.nearClipPlane, far: camera.farClipPlane)
	}
	
	// TODO: in CommandBuffer
	// TODO: delete this function
	private func drawGameObject(drawable: Drawable, view: MTKView) {
		
		// TODO: delete this
		let meshRenderer = drawable as! MeshRenderer

		// TODO: wait in game object
		let semaphore = meshRenderer.gameObject.getSemaphore()
		_ = semaphore.wait()
		
		if let commandBuffer = commandQueue.makeCommandBuffer() {
			
			commandBuffer.addCompletedHandler() { _ in semaphore.signal() }
			
			meshRenderer.gameObject.update()
			
			let renderPassDescriptor = view.currentRenderPassDescriptor
			
			if let renderPassDescriptor = renderPassDescriptor, let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
				
				/// Final pass rendering code here
				renderEncoder.label = "Primary Render Encoder"
				
				renderEncoder.pushDebugGroup("Draw Box")
				
				renderEncoder.setCullMode(.back)
				
				renderEncoder.setFrontFacing(.counterClockwise)
			
				renderEncoder.setRenderPipelineState(meshRenderer.pipelineState!)
				
				renderEncoder.setDepthStencilState(depthState)
				
				// TODO: in game object
				// TODO: BufferIndex
				renderEncoder.setVertexBuffer(meshRenderer.gameObject.transformUniformBuffer.buffer, offset: meshRenderer.gameObject.transformUniformBuffer.offset, index: BufferIndex.uniforms.rawValue)
				
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

extension ViewDelegate {
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


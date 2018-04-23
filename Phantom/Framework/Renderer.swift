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
		// update Behaviours
		// TODO: multi-thread update
		if let updateBehaviours = application?.updateBehaviours {
			for var updateBehaviour in updateBehaviours {
				updateBehaviour?.update()
			}
		}
		
		// update MeshRenderers
		if let gameObjects = application?.gameObjects {
			for gameObject in gameObjects {
				// TODO: check dirty
				gameObject.update()
				guard let meshRenderer: MeshRenderer = gameObject.getComponent() else { continue }
				drawGameObject(meshRenderer: meshRenderer, view: view)
			}
		}
	}

	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
		// TODO: Camera
		let aspect = Float(size.width) / Float(size.height)
		guard let camera: Camera = Camera.main else { return }
		camera.projectionMatrix = Math.perspective(fovyRadians: camera.fieldOfView, aspect: aspect, near: camera.nearClipPlane, far: camera.farClipPlane)
	}
	
	// TODO: in CommandBuffer
	private func drawGameObject(meshRenderer: MeshRenderer, view: MTKView) {

		// TODO: wait in game object
		let semaphore = meshRenderer.gameObject.getSemaphore()
		_ = semaphore.wait()
		
		if let commandBuffer = commandQueue.makeCommandBuffer() {
			
			commandBuffer.addCompletedHandler() { _ in semaphore.signal() }
			
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


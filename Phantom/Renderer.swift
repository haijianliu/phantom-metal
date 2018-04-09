// Copyright © haijian. All rights reserved.

// Our platform independent renderer class

import Metal
import MetalKit

class Renderer: NSObject, MTKViewDelegate {

	let device: MTLDevice
	
	let commandQueue: MTLCommandQueue
	var pipelineState: MTLRenderPipelineState
	var depthState: MTLDepthStencilState
	
	var mesh: Mesh
	var texture: Texture = Texture()
	var transform: Transform

	init?(mtkView: MTKView) {
		// Set device
		guard let device = mtkView.device else { return nil }
		self.device = device
		
		guard let queue = self.device.makeCommandQueue() else { return nil }
		self.commandQueue = queue

		// vertex descriptor
		let mtlVertexDescriptor = Mesh.buildVertexDescriptor()
		
		// pipeline state
		do {
			pipelineState = try Renderer.buildRenderPipelineWithDevice(device: device, metalKitView: mtkView, mtlVertexDescriptor: mtlVertexDescriptor)
		} catch {
			print("Unable to compile render pipeline state.  Error info: \(error)")
			return nil
		}

		// depth descriptor
		let depthStateDesciptor = MTLDepthStencilDescriptor()
		depthStateDesciptor.depthCompareFunction = MTLCompareFunction.less
		depthStateDesciptor.isDepthWriteEnabled = true
		guard let state = device.makeDepthStencilState(descriptor:depthStateDesciptor) else { return nil }
		depthState = state
		
		// Mesh
		guard let newMesh = Mesh.init(vertexDescriptor: mtlVertexDescriptor) else {
			return nil
		}
		mesh = newMesh

		// Texture
		do {
			texture.mtlTexture = try Texture.load(textureName: "UV_Grid_Sm")
		} catch {
			print("Unable to load texture. Error info: \(error)")
			return nil
		}
		
		// Transform
		guard let newTransform = Transform() else { return nil }
		transform = newTransform
		

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
		
		transform.updateGameState()

		if let commandBuffer = commandQueue.makeCommandBuffer() {



			// Delay getting the currentRenderPassDescriptor until we absolutely need it to avoid
			//   holding onto the drawable and blocking the display pipeline any longer than necessary
			let renderPassDescriptor = view.currentRenderPassDescriptor

			if let renderPassDescriptor = renderPassDescriptor, let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {

				/// Final pass rendering code here
				renderEncoder.label = "Primary Render Encoder"

				renderEncoder.pushDebugGroup("Draw Box")

				renderEncoder.setCullMode(.back)

				renderEncoder.setFrontFacing(.counterClockwise)

				renderEncoder.setRenderPipelineState(pipelineState)

				renderEncoder.setDepthStencilState(depthState)

				renderEncoder.setVertexBuffer(transform.dynamicUniformBuffer, offset: 0, index: BufferIndex.uniforms.rawValue)
				renderEncoder.setFragmentBuffer(transform.dynamicUniformBuffer, offset: 0, index: BufferIndex.uniforms.rawValue)

				for (index, element) in mesh.mtkMesh.vertexDescriptor.layouts.enumerated() {
					guard let layout = element as? MDLVertexBufferLayout else {
						return
					}

					if layout.stride != 0 {
						let buffer = mesh.mtkMesh.vertexBuffers[index]
						renderEncoder.setVertexBuffer(buffer.buffer, offset: buffer.offset, index: index)
					}
				}

				renderEncoder.setFragmentTexture(texture.mtlTexture, index: TextureIndex.color.rawValue)

				for submesh in mesh.mtkMesh.submeshes {
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
		transform.projectionMatrix = Math.perspective(fovyRadians: Math.radians(65), aspect: aspect, near: 0.1, far: 100.0)
	}
}


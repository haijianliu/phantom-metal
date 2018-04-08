// Copyright © haijian. All rights reserved.

// Our platform independent renderer class

import Metal
import MetalKit

// The 256 byte aligned size of our uniform structure
let alignedUniformsSize = (MemoryLayout<Uniforms>.size & ~0xFF) + 0x100

let maxBuffersInFlight = 3

class Renderer: NSObject, MTKViewDelegate {

	let device: MTLDevice
	
	let commandQueue: MTLCommandQueue
	var dynamicUniformBuffer: MTLBuffer
	var pipelineState: MTLRenderPipelineState
	var depthState: MTLDepthStencilState

	let inFlightSemaphore = DispatchSemaphore(value: maxBuffersInFlight)

	var uniformBufferOffset = 0

	var uniformBufferIndex = 0

	var uniforms: UnsafeMutablePointer<Uniforms>

	var projectionMatrix: Matrix4x4 = Matrix4x4()

	var rotation: Float = 0
	
	var mesh: Mesh
	var texture: Texture = Texture()

	init?(mtkView: MTKView) {
		// Set device
		guard let device = mtkView.device else { return nil }
		self.device = device
		
		guard let queue = self.device.makeCommandQueue() else { return nil }
		self.commandQueue = queue

		let uniformBufferSize = alignedUniformsSize * maxBuffersInFlight

		guard let buffer = self.device.makeBuffer(length: uniformBufferSize, options: MTLResourceOptions.storageModeShared) else { return nil }
		dynamicUniformBuffer = buffer

		self.dynamicUniformBuffer.label = "UniformBuffer"

		uniforms = UnsafeMutableRawPointer(dynamicUniformBuffer.contents()).bindMemory(to: Uniforms.self, capacity: 1)

		// vertex descriptor
		let mtlVertexDescriptor = Renderer.buildMetalVertexDescriptor()
		
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
		
		// mesh
		guard let newMesh = Mesh.init(vertexDescriptor: mtlVertexDescriptor) else {
			return nil
		}
		mesh = newMesh

		do {
			texture.mtlTexture = try Texture.load(textureName: "UV_Grid_Sm")
		} catch {
			print("Unable to load texture. Error info: \(error)")
			return nil
		}
		

		super.init()
	}

	class func buildMetalVertexDescriptor() -> MTLVertexDescriptor {
		// Creete a Metal vertex descriptor specifying how vertices will by laid out for input into our render
		// pipeline and how we'll layout our Model IO vertices

		let mtlVertexDescriptor = MTLVertexDescriptor()

		mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].format = MTLVertexFormat.float3
		mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].offset = 0
		mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue

		mtlVertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].format = MTLVertexFormat.float2
		mtlVertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].offset = 0
		mtlVertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].bufferIndex = BufferIndex.meshGenerics.rawValue

		mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stride = 12
		mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepRate = 1
		mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepFunction = MTLVertexStepFunction.perVertex

		mtlVertexDescriptor.layouts[BufferIndex.meshGenerics.rawValue].stride = 8
		mtlVertexDescriptor.layouts[BufferIndex.meshGenerics.rawValue].stepRate = 1
		mtlVertexDescriptor.layouts[BufferIndex.meshGenerics.rawValue].stepFunction = MTLVertexStepFunction.perVertex

		return mtlVertexDescriptor
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

	private func updateDynamicBufferState() {
		/// Update the state of our uniform buffers before rendering

		uniformBufferIndex = (uniformBufferIndex + 1) % maxBuffersInFlight

		uniformBufferOffset = alignedUniformsSize * uniformBufferIndex

		uniforms = UnsafeMutableRawPointer(dynamicUniformBuffer.contents() + uniformBufferOffset).bindMemory(to:Uniforms.self, capacity:1)
	}

	private func updateGameState() {
		// Update any game state before rendering

		uniforms[0].projectionMatrix = projectionMatrix

		let rotationAxis = float3(1, 1, 0)
		let modelMatrix = Math.rotate(radians: rotation, axis: rotationAxis)
		let viewMatrix = Math.translate(0.0, 0.0, -8.0)
		uniforms[0].modelViewMatrix = viewMatrix * modelMatrix;
		rotation += 0.01
	}

	func draw(in view: MTKView) {
		// Per frame updates hare

		_ = inFlightSemaphore.wait(timeout: DispatchTime.distantFuture)

		if let commandBuffer = commandQueue.makeCommandBuffer() {

			let semaphore = inFlightSemaphore
			commandBuffer.addCompletedHandler {
				(_ commandBuffer)-> Swift.Void in semaphore.signal()
			}

			self.updateDynamicBufferState()

			self.updateGameState()

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

				renderEncoder.setVertexBuffer(dynamicUniformBuffer, offset: uniformBufferOffset, index: BufferIndex.uniforms.rawValue)
				renderEncoder.setFragmentBuffer(dynamicUniformBuffer, offset: uniformBufferOffset, index: BufferIndex.uniforms.rawValue)

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
		projectionMatrix = Math.perspective(fovyRadians: Math.radians(65), aspect: aspect, near: 0.1, far: 100.0)
	}
}


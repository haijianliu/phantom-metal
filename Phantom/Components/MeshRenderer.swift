// Copyright © haijian. All rights reserved.

import MetalKit

public class MeshRenderer: Renderer, Drawable {
	
	var renderPipelineState: MTLRenderPipelineState?
	
	public var mesh: Mesh? {
		didSet {
			// pipeline state
			do {
				renderPipelineState = try ViewDelegate.buildRenderPipelineWithDevice(device: View.main.device!, metalKitView: View.main, mtlVertexDescriptor: (mesh?.mtlVertexDescriptor)!)
			} catch {
				print("Unable to compile render pipeline state.  Error info: \(error)")
				mesh = nil
			}
		}
	}
	
	public var texture: Texture? // TODO: Material
	
	func draw(in view: MTKView) {
		
		// TODO: wait in game object
		let semaphore = gameObject.getSemaphore()
		_ = semaphore.wait(timeout: .distantFuture)
				
		if let commandBuffer = View.sharedInstance.commandQueue?.makeCommandBuffer() {
			
			commandBuffer.addCompletedHandler() { _ in semaphore.signal() }
			
			gameObject.update()
			
			if let renderPassDescriptor = view.currentRenderPassDescriptor, let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
				
				/// Final pass rendering code here
				renderEncoder.label = "Primary Render Encoder"
				renderEncoder.pushDebugGroup("Draw Box")
				
				// TODO: in material
				renderEncoder.setCullMode(.back)
				renderEncoder.setFrontFacing(.counterClockwise)
				
				// TODO: in rendering pass
				guard let depthStencilState = View.sharedInstance.renderPass?.depthStencilState else { return }
				renderEncoder.setDepthStencilState(depthStencilState)
				
				// TODO: in material
				// TODO: in mesh
				guard let renderPipelineState = self.renderPipelineState else { return }
				renderEncoder.setRenderPipelineState(renderPipelineState)

				// TODO: in game object
				// TODO: BufferIndex
				renderEncoder.setVertexBuffer(gameObject.transformUniformBuffer.buffer, offset: gameObject.transformUniformBuffer.offset, index: BufferIndex.uniforms.rawValue)
				
				// TODO: in mesh
				guard let mesh = self.mesh else { return }
				for (index, element) in mesh.mtkMesh.vertexDescriptor.layouts.enumerated() {
					guard let layout = element as? MDLVertexBufferLayout else { return }
					if layout.stride != 0 {
						let vertexBuffers = mesh.mtkMesh.vertexBuffers[index]
						renderEncoder.setVertexBuffer(vertexBuffers.buffer, offset: vertexBuffers.offset, index: index)
					}
				}
				
				// TODO: in material
				guard let texture = self.texture else { return }
				renderEncoder.setFragmentTexture(texture.mtlTexture, index: TextureIndex.color.rawValue)
				
				// TODO: in mesh
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
}

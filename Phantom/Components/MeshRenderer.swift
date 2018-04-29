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
		
	func draw(in view: MTKView) {
		// Check all the resources available
		guard
		let commandBuffer = View.sharedInstance.commandQueue?.makeCommandBuffer(),
		let renderPassDescriptor = view.currentRenderPassDescriptor,
		let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor),
		let material = self.material,
		let depthStencilState = View.sharedInstance.renderPass?.depthStencilState,
		let renderPipelineState = self.renderPipelineState,
		let mesh = self.mesh,
		let texture = self.material?.texture
		else { return }
			
		// TODO: wait in game object? It seems impossible.
		let semaphore = gameObject.getSemaphore()
		_ = semaphore.wait(timeout: .distantFuture)
		commandBuffer.addCompletedHandler() { _ in semaphore.signal() }

		// Final pass rendering code here
		// TODO: setup with object names
		renderEncoder.label = "Primary Render Encoder"
		renderEncoder.pushDebugGroup("Draw Box")
		
		// Material
		renderEncoder.setCullMode(material.cullMode)
		
		// Render pass
		renderEncoder.setDepthStencilState(depthStencilState)
		
		// TODO: in material
		// TODO: in mesh
		// Render pipeline
		renderEncoder.setRenderPipelineState(renderPipelineState)

		// Game object encodes triple buffer
		gameObject.encode(to: renderEncoder)
		
		// Mesh
		mesh.encode(to: renderEncoder)
		
		// TODO: in material
		// Texture
		renderEncoder.setFragmentTexture(texture.mtlTexture, index: TextureIndex.color.rawValue)
		
		// TODO: in mesh
		for submesh in mesh.mtkMesh.submeshes {
			renderEncoder.drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
		}
		
		renderEncoder.popDebugGroup()
		renderEncoder.endEncoding()
		
		// Render to core animation layer
		// TODO: in render pass
		if let drawable = view.currentDrawable { commandBuffer.present(drawable) }
	
		commandBuffer.commit()
	}
}

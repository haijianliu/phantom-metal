// Copyright © haijian. All rights reserved.

// Our platform independent renderer class

import Metal
import MetalKit

class ViewDelegate: NSObject, MTKViewDelegate {

	func draw(in view: MTKView) {
		// update behaviours
		// TODO: multi-thread update
		for updateBehaviour in Application.sharedInstance.updateBehaviours {
			updateBehaviour.reference?.update()
		}
		
		// drawable behaviours
		// TODO: multiple threads draw multiple queue (realtime and offline rendering)
		for drawBehaviour in Application.sharedInstance.drawBehaviours {
			drawBehaviour.reference?.draw(in: view)
		}
	}

	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
		// TODO: Camera
		let aspect = Float(size.width) / Float(size.height)
		guard let camera: Camera = Camera.main else { return }
		camera.projectionMatrix = Math.perspective(fovyRadians: camera.fieldOfView, aspect: aspect, near: camera.nearClipPlane, far: camera.farClipPlane)
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


// Copyright © haijian. All rights reserved.

// Our platform independent renderer class

import Metal
import MetalKit

class ViewDelegate: NSObject, MTKViewDelegate {

	// TODO: only render render pass here.
	func draw(in view: MTKView) {
		View.sharedInstance.renderPass?.draw(in: view)
	}

	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
		// TODO: Camera
		let aspect = Float(size.width) / Float(size.height)
		guard let camera: Camera = Camera.main else { return }
		camera.projectionMatrix = Math.perspective(fovyRadians: camera.fieldOfView, aspect: aspect, near: camera.nearClipPlane, far: camera.farClipPlane)
	}
}

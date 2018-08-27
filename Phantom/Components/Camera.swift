// Copyright © haijian. All rights reserved.

import MetalKit

public class Camera: Component, Updatable, RenderEncodable {
	/// The last enabled camera tagged GameObject.mainCamera (Read Only).
	///
	/// Returns **nil** if there is no such camera in the scene.
	public internal(set) weak static var main: Camera?
	
	weak static var shadow: Camera?
	
	private var cameraUniformBuffer: TripleBuffer<CameraBuffer>
	
	/// The near clipping plane distance.
	var nearClipPlane: Float = 0.1
	/// The far clipping plane distance.
	var farClipPlane: Float = 100
	/// The field of view of the camera (fovy) in radians.
	var fieldOfView: Float = Math.radians(60)
	
	// TODO: target.
	/// Matrix that transforms from world to camera space (Read only).
	///
	/// Use this to calculate the camera space position of objects or to provide custom camera's location that is not based on the transform.
	var worldToCameraMatrix: Matrix4x4 {
		return Math.lookAt(eye: gameObject.transform.worldPosition, center: Vector3(0, 0, 0))
	}
	
	/// The aspect ratio (width divided by height).
	///
	/// By default the aspect ratio is automatically calculated from the screen's aspect ratio (Read Only).
	var aspect: Float {
		return 0 // TODO
	}
	
	/// Set a custom projection matrix.
	///
	///If you change this matrix, the camera no longer updates its rendering based on its fieldOfView. This lasts until you call ResetProjectionMatrix.
	var projectionMatrix: Matrix4x4 = Matrix4x4()
	
	required public init?(_ gameObject: GameObject) {
		guard let device = Application.sharedInstance.device else { return nil }
		// TODO: init dynamic semaphore value
		guard let newBuffer = TripleBuffer<CameraBuffer>(device) else { return nil }
		cameraUniformBuffer = newBuffer
		
		super.init(gameObject) // TODO: safe wrap.
		if Camera.main == nil {
			gameObject.tag = .mainCamera
			Camera.main = self
		}
	}
	
	public func update() {
		cameraUniformBuffer.data.update(by: self)
		cameraUniformBuffer.endWritting()
	}
	
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder) {
		renderCommandEncoder.setVertexBuffer(cameraUniformBuffer.buffer, offset: cameraUniformBuffer.offset, index: BufferIndex.cameraBuffer.rawValue)
	}
}


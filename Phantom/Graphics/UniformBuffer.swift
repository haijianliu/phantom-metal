// Copyright © haijian. All rights reserved.

protocol UniformBuffer { }

//protocol NodeBuffer: UniformBuffer {
//	mutating func update(by transform: Transform)
//}
//
//protocol SceneBuffer: UniformBuffer {
//	mutating func update()
//}

// TODO: confirm protocol.

extension NodeBuffer: UniformBuffer {
	mutating func update(by transform: Transform) {
		self.modelMatrix = transform.localToWorldMatrix
		self.inverseTransposeModelMatrix = transform.localToWorldMatrix.inverse.transpose // TODO: stored.
	}
}

extension CameraBuffer: UniformBuffer {
	mutating func update(by camera: Camera) {
		self.viewProjectionMatrix = camera.projectionMatrix * camera.worldToCameraMatrix
		self.position = camera.transform.position
	}
}

// https://forums.developer.apple.com/thread/72120
extension LightBuffer: UniformBuffer {
	// TODO: use contigous array.
	mutating func update(_ lightDatas: [LightData]) {
		self.count = Int32(lightDatas.count)
		let pointer = UnsafeMutableBufferPointer<LightData>(start: &self.light.0, count: 16)
		for (index, lightData) in lightDatas.enumerated() { pointer[index] = lightData }
	}
}

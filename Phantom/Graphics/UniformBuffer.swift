// Copyright © haijian. All rights reserved.

protocol UniformBuffer { }

protocol NodeBuffer: UniformBuffer {
	mutating func update(by transform: Transform)
}

protocol SceneBuffer: UniformBuffer {
	mutating func update(by camera: Camera)
}

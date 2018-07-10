// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: struct only protocol
// TODO: when add drawable behaviour to list, check if there is shader and texture attached. If not, assign one.
public class Material {
	public var shader: Shader
	public var texture: Texture?
	public var cullMode: MTLCullMode = MTLCullMode.back
	public var fillMode: MTLTriangleFillMode = MTLTriangleFillMode.fill

	public init(with shader: Shader) { self.shader = shader }
}

extension Material: Encodable {
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder) {
		renderCommandEncoder.setCullMode(cullMode)
		renderCommandEncoder.setTriangleFillMode(fillMode)
		shader.encode(to: renderCommandEncoder)
		texture?.encode(to: renderCommandEncoder)
	}
}

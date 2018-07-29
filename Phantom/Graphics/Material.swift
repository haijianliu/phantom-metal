// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: struct only protocol
// TODO: when add drawable behaviour to list, check if there is shader and texture attached. If not, assign one.
/// All properties from a material.
public class Material {
	public var texture: Texture?
	public var cullMode: MTLCullMode = MTLCullMode.back
	public var fillMode: MTLTriangleFillMode = MTLTriangleFillMode.fill
	/// The shader used by the material.
	let shader = Shader()
}

extension Material: RenderEncodable {
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder) {
		renderCommandEncoder.setCullMode(cullMode)
		renderCommandEncoder.setTriangleFillMode(fillMode)
		texture?.encode(to: renderCommandEncoder)
		shader.encode(to: renderCommandEncoder)
	}
}

// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: struct only protocol
// TODO: when add drawable behaviour to list, check if there is shader and texture attached. If not, assign one.
public struct Material {

	var cullMode: MTLCullMode = MTLCullMode.back
	
	public var shader: Shader?
	public var texture: Texture?
	
	public init() {}
}

extension Material: Encodable {
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder) {
		renderCommandEncoder.setCullMode(cullMode)
		shader?.encode(to: renderCommandEncoder)
		texture?.encode(to: renderCommandEncoder)
	}
}

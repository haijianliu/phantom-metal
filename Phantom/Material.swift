// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: struct only protocol
public struct Material {
	var cullMode: MTLCullMode = MTLCullMode.back
	
	public var texture: Texture?
	
	public init() {}
}

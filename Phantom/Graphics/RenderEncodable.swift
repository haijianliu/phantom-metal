// Copyright © haijian. All rights reserved.

import MetalKit

@objc protocol RenderEncodable {
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder)
}

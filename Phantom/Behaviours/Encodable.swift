// Copyright © haijian. All rights reserved.

import MetalKit

@objc protocol Encodable {
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder)
}

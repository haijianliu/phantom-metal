// Copyright © haijian. All rights reserved.

import MetalKit

protocol Encodable {
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder)
}

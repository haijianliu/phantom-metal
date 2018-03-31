// Copyright © haijian. All rights reserved.

import MetalKit

class Texture: Resource {
	var texture: MTLTexture?
	
	override init?(_ name: String) {
		super.init(name)
	}
	
	func load(name: String) throws {
		
	}
}


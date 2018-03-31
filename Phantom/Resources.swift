// Copyright © haijian. All rights reserved.

import MetalKit

class Resources {
	// Singleton
	static let sharedInstance = Resources()
	private init() {}
	
	private var device: MTLDevice?
	func setDevice(device: MTLDevice) {
		self.device = device
	}
}

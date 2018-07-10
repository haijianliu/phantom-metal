// Copyright © haijian. All rights reserved.

import MetalKit

class Resource {
	let name: String
	init?(_ name: String) {
		self.name = name
	}
}

class Resources {
	// Singleton
	static let sharedInstance = Resources()
	private init() {}

	private var device: MTLDevice?
	func setDevice(device: MTLDevice) {
		self.device = device
	}

	public static func load(name: String) -> Resource? {
		let resource = Resource(name)

		return resource
	}
}


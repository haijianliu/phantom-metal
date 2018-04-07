// Copyright © haijian. All rights reserved.

import MetalKit

class MetalDevice {

	static let sharedInstance: MetalDevice = MetalDevice()

	let device: MTLDevice?

	private init() {
		// Select the default device to render with.
		guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
			print("Metal is not supported on this device")
			device = nil
			return
		}

		device = defaultDevice
	}
}

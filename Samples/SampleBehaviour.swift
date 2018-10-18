// Copyright © haijian. All rights reserved.

#if os(macOS)
import PhantomKit
#elseif os(iOS)
import PhantomTouchKit
#endif

class SampleBehaviour: Component, Updatable {
	func update() {
		let rotationAxis = Vector3(0, 1, 0)
		gameObject.transform.rotate(angle: 0.005, axis: rotationAxis)
	}
}

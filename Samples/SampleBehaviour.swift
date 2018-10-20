// Copyright © haijian. All rights reserved.

import PhantomKit

class SampleBehaviour: Component, Updatable {
	func update() {
		let rotationAxis = Vector3(0, 1, 0)
		gameObject.transform.rotate(angle: 0.005, axis: rotationAxis)
	}
}

#if os(iOS)

import UIKit

class SampleTouchBehaviour: Component, Touchabe {
	func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let force = touches.first?.force else { return }
		gameObject.transform.scale = Vector3(Float(force))
	}
}

#endif

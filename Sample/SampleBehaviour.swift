// Copyright © haijian. All rights reserved.

import PhantomKit

class SampleBehaviour: Behaviour, Updatable {
	func update() {
		let rotationAxis = Vector3(1, 1, 0)
		gameObject.transform.rotate(angle: 0.01, axis: rotationAxis)
		gameObject.transform.viewMatrix = Math.translate(0.0, 0.0, -8.0)
	}
}

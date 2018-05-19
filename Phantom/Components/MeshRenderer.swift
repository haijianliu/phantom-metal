// Copyright © haijian. All rights reserved.

import MetalKit

public class MeshRenderer: Renderer, Drawable {

	public var mesh: Mesh?
	
	// TODO: in game object.
	/// Allow cpu to go 2 steps ahead GPU, before GPU finishes its current command.
	private let semaphore = DispatchSemaphore(value: 3)

	// TODO: can this skip some encoding phases?
	func draw(encoding renderEncoder: MTLRenderCommandEncoder) {
		// Check all the resources available.
		guard
			let mesh = self.mesh,
			let material = self.material
		else { return }

		// Material encoding: including shader and texture encoding.
		material.encode(to: renderEncoder)
		// Game object encoding: update triple buffer.
		gameObject.encode(to: renderEncoder)
		// Mesh encoding: contents draw call encoding, which must be encoded at last (just before end encoding).
		mesh.encode(to: renderEncoder)
	}
}

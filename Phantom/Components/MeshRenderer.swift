// Copyright © haijian. All rights reserved.

import MetalKit

/// Renders meshes.
public class MeshRenderer: Renderer, Renderable {
	
	// TODO: multiple.
	/// Mesh slot for rendering.
	public var mesh: Mesh?
	
	// TODO: in game object.
	/// Allow cpu to go 2 steps ahead GPU, before GPU finishes its current command.
	private let semaphore = DispatchSemaphore(value: 3)
	
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder) {
		// Check all the resources available.
		guard let mesh = self.mesh, let material = self.material else { return }
		// Material encoding: including shader and texture encoding.
		material.encode(to: renderCommandEncoder)
		// Game object encoding: update triple buffer.
		gameObject.encode(to: renderCommandEncoder)
		// Mesh encoding: contents draw call encoding, which must be encoded at last (just before end encoding).
		mesh.encode(to: renderCommandEncoder)
	}
}

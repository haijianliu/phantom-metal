// Copyright © haijian. All rights reserved.

import MetalKit

/// Renders meshes.
class MeshRenderer: Renderer, Renderable {

	// TODO: multiple.
	/// Mesh slot for rendering.
	var mesh: Mesh?

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

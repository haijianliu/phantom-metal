// Copyright © haijian. All rights reserved.

import MetalKit

/// Renders meshes.
class ShadowRenderer: Renderer, Renderable, Registrable {

	let mesh = Mesh()

	func register() {
		material.shader.shaderType = .shadowMap
		material.shader.load()
		mesh.load(from: material.shader.vertexDescriptor)
	}

	func encode(to renderCommandEncoder: MTLRenderCommandEncoder) {
		// Material encoding: including texture and shader encoding.
		material.encode(to: renderCommandEncoder)
		// Game object encoding: update triple buffer.
		gameObject.encode(to: renderCommandEncoder)
		// Mesh encoding: contents draw call encoding, which must be encoded at last (just before end encoding).
		mesh.encode(to: renderCommandEncoder)
	}
}

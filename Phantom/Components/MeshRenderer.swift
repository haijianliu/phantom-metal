// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: main renderer for initialize other renderers.
/// Renders meshes.
class MeshRenderer: Renderer, Renderable, Registrable {
	// TODO: multiple.
	/// Mesh slot for rendering.
	let mesh = Mesh()
	
	// TODO: didset.
	// TODO: [shadowCastingMode](https://docs.unity3d.com/ScriptReference/Renderer-shadowCastingMode.html)
	/// Does this object cast shadows?
	var castShadows: Bool = true
	
	/// Does this object receive shadows?
	/// Note that receive shadows flag is not used when using one of Deferred rendering paths; all objects receive shadows there. (TODO)
	var receiveShadows: Bool = true
	
	func register() {
		material.shader.load()
		mesh.load(from: material.shader.vertexDescriptor)
		// If mesh casts shadows, add a new shadow renderer component and add this render behaviour will be added to shadowmap renderpass.
		if castShadows == true {
			let _: ShadowRenderer? = self.gameObject.addComponent()
			guard let shadowRenderer: ShadowRenderer = gameObject.getComponent() else { return }
			shadowRenderer.mesh.mdlMesh = mesh.mdlMesh // TODO: refactor
			shadowRenderer.register()
		}
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

// Copyright © haijian. All rights reserved.

import MetalKit

class Mesh {
	/// A container for the vertex data of a Model I/O mesh, suitable for use in a Metal app.
	var mtkMesh: MTKMesh?
	var mdlMesh: MDLMesh?

	/// Stroed vertex attribuite indices array for render encoding.
	var vertexBufferIndices = ContiguousArray<Int>()

	/// The vertex winding rule that determines a front-facing primitive (Default: counter-clockwise).
	var winding: MTLWinding = .counterClockwise
}

extension Mesh: RenderEncodable {
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder) {
		// Encode winding order of front-facing primitives.
		renderCommandEncoder.setFrontFacing(winding)
		// Encode a buffer for the vertex shader function.
		guard let mesh = mtkMesh else { return }
		for index in vertexBufferIndices {
			let vertexBuffers = mesh.vertexBuffers[index]
			renderCommandEncoder.setVertexBuffer(vertexBuffers.buffer, offset: vertexBuffers.offset, index: index)
		}
		// Encode draw command.
		for submesh in mesh.submeshes {
			renderCommandEncoder.drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
		}
	}
}

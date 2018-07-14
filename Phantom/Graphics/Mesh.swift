// Copyright © haijian. All rights reserved.

import MetalKit

class Mesh {
	var mtkMesh: MTKMesh
	var winding: MTLWinding = MTLWinding.counterClockwise
	init(with mtkMesh: MTKMesh) { self.mtkMesh = mtkMesh }
}

extension Mesh: RenderEncodable {
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder) {
		// Encode winding order of front-facing primitives.
		renderCommandEncoder.setFrontFacing(winding)
		// Encode a buffer for the vertex shader function.
		for (index, element) in mtkMesh.vertexDescriptor.layouts.enumerated() {
			guard let layout = element as? MDLVertexBufferLayout else { return }
			if layout.stride != 0 {
				let vertexBuffers = mtkMesh.vertexBuffers[index]
				renderCommandEncoder.setVertexBuffer(vertexBuffers.buffer, offset: vertexBuffers.offset, index: index)
			} else {
				break
			}
		}
		// Encode draw command.
		for submesh in mtkMesh.submeshes {
			renderCommandEncoder.drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
		}
	}
}

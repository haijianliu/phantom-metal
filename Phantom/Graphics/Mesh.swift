// Copyright © haijian. All rights reserved.

import MetalKit

class Mesh {
	/// A container for the vertex data of a Model I/O mesh, suitable for use in a Metal app.
	private var mtkMesh: MTKMesh
	
	/// Stroed vertex attribuite indices array for render encoding.
	private var vertexBufferIndices = ContiguousArray<Int>()
	
	/// The vertex winding rule that determines a front-facing primitive (Default: counter-clockwise).
	var winding: MTLWinding = MTLWinding.counterClockwise

	init?(_ device: MTLDevice, from mdlMesh: MDLMesh, with vertexDescriptor: MTLVertexDescriptor) {
		// Create MDLVertexDescriptor.
		let mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
		guard let attributes = mdlVertexDescriptor.attributes as? [MDLVertexAttribute] else { return nil }
		attributes[VertexAttribute.position.rawValue].name = MDLVertexAttributePosition
		attributes[VertexAttribute.texcoord.rawValue].name = MDLVertexAttributeTextureCoordinate
		attributes[VertexAttribute.normal.rawValue].name = MDLVertexAttributeNormal
		mdlMesh.vertexDescriptor = mdlVertexDescriptor
		// Create MTKMesh.
		let mtkMesh: MTKMesh
		do {
			mtkMesh = try MTKMesh(mesh: mdlMesh, device: device)
		} catch {
			print("Unable to build MetalKit Mesh. Error info: \(error)")
			return nil
		}
		self.mtkMesh = mtkMesh
		// TODO: use library settings.
		vertexBufferIndices.reserveCapacity(0x20)
		for (index, element) in mtkMesh.vertexDescriptor.layouts.enumerated() {
			guard let layout = element as? MDLVertexBufferLayout else { return }
			if layout.stride != 0 { vertexBufferIndices.append(index) }
		}
	}
}

extension Mesh: RenderEncodable {
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder) {
		// Encode winding order of front-facing primitives.
		renderCommandEncoder.setFrontFacing(winding)
		// Encode a buffer for the vertex shader function.
		for index in vertexBufferIndices {
			let vertexBuffers = mtkMesh.vertexBuffers[index]
			renderCommandEncoder.setVertexBuffer(vertexBuffers.buffer, offset: vertexBuffers.offset, index: index)
		}
		// Encode draw command.
		for submesh in mtkMesh.submeshes {
			renderCommandEncoder.drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
		}
	}
}

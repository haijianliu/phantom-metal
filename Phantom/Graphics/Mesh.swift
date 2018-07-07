// Copyright © haijian. All rights reserved.

import MetalKit

public class Mesh {
	
	var mtkMesh: MTKMesh
	var winding: MTLWinding = MTLWinding.counterClockwise
	
	// TODO: delete shader argument.
	/// Create and condition mesh data to feed into a pipeline using the given vertex descriptor.
	public init?(shader: Shader) {
		guard let device = View.main.device else { return nil }
		do {
			mtkMesh = try Mesh.buildMesh(device: device, vertexDescriptor: shader.vertexDescriptor)
		} catch {
			print("Unable to build MetalKit Mesh. Error info: \(error)")
			return nil
		}
	}

	/// Create and condition mesh data to feed into a pipeline using the given vertex descriptor.
	class func buildMesh(device: MTLDevice, vertexDescriptor: MTLVertexDescriptor) throws -> MTKMesh {
		
		let metalAllocator = MTKMeshBufferAllocator(device: device)
		
		let mdlMesh = MDLMesh.newBox(withDimensions: float3(1, 1, 1), segments: uint3(1, 1, 1), geometryType: MDLGeometryType.triangles, inwardNormals: false, allocator: metalAllocator)
		
		let mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
		
		guard let attributes = mdlVertexDescriptor.attributes as? [MDLVertexAttribute] else {
			throw RendererError.badVertexDescriptor
		}
		attributes[VertexAttribute.position.rawValue].name = MDLVertexAttributePosition
		attributes[VertexAttribute.texcoord.rawValue].name = MDLVertexAttributeTextureCoordinate
		
		mdlMesh.vertexDescriptor = mdlVertexDescriptor
		
		return try MTKMesh(mesh: mdlMesh, device: device)
	}
}

extension Mesh: Encodable {
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder) {
		// Encode winding order of front-facing primitives.
		renderCommandEncoder.setFrontFacing(winding)
		// Encode a buffer for the vertex shader function.
		for (index, element) in mtkMesh.vertexDescriptor.layouts.enumerated() {
			guard let layout = element as? MDLVertexBufferLayout else { return }
			if layout.stride != 0 {
				let vertexBuffers = mtkMesh.vertexBuffers[index]
				renderCommandEncoder.setVertexBuffer(vertexBuffers.buffer, offset: vertexBuffers.offset, index: index)
			}
		}
		// Encode draw command.
		for submesh in mtkMesh.submeshes {
			renderCommandEncoder.drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
		}
	}
}

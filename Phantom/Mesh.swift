// Copyright © haijian. All rights reserved.

import MetalKit

class Mesh {
	var mtkMesh: MTKMesh
	
	init?(vertexDescriptor: MTLVertexDescriptor) {
		do {
			mtkMesh = try Mesh.buildMesh(device: Display.main.device!, vertexDescriptor: vertexDescriptor)
		} catch {
			print("Unable to build MetalKit Mesh. Error info: \(error)")
			return nil
		}
	}

	static func buildMesh(device: MTLDevice, vertexDescriptor: MTLVertexDescriptor) throws -> MTKMesh {
		// Create and condition mesh data to feed into a pipeline using the given vertex descriptor
		
		let metalAllocator = MTKMeshBufferAllocator(device: device)
		
		let mdlMesh = MDLMesh.newBox(withDimensions: float3(4, 4, 4), segments: uint3(2, 2, 2), geometryType: MDLGeometryType.triangles, inwardNormals: false, allocator: metalAllocator)
		
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

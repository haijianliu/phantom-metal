// Copyright © haijian. All rights reserved.

import MetalKit

class Mesh {
	var mtkMesh: MTKMesh
	let mtlVertexDescriptor: MTLVertexDescriptor
	
	init?() {
		mtlVertexDescriptor = Mesh.buildVertexDescriptor()
		do {
			mtkMesh = try Mesh.buildMesh(device: Display.main.device!, vertexDescriptor: mtlVertexDescriptor)
		} catch {
			print("Unable to build MetalKit Mesh. Error info: \(error)")
			return nil
		}
	}
	
	class func buildVertexDescriptor() -> MTLVertexDescriptor {
		// Creete a Metal vertex descriptor specifying how vertices will by laid out for input into our render
		// pipeline and how we'll layout our Model IO vertices
		
		let mtlVertexDescriptor = MTLVertexDescriptor()
		
		mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].format = MTLVertexFormat.float3
		mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].offset = 0
		mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue
		
		mtlVertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].format = MTLVertexFormat.float2
		mtlVertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].offset = 0
		mtlVertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].bufferIndex = BufferIndex.meshGenerics.rawValue
		
		mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stride = 12
		mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepRate = 1
		mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepFunction = MTLVertexStepFunction.perVertex
		
		mtlVertexDescriptor.layouts[BufferIndex.meshGenerics.rawValue].stride = 8
		mtlVertexDescriptor.layouts[BufferIndex.meshGenerics.rawValue].stepRate = 1
		mtlVertexDescriptor.layouts[BufferIndex.meshGenerics.rawValue].stepFunction = MTLVertexStepFunction.perVertex
		
		return mtlVertexDescriptor
	}

	class func buildMesh(device: MTLDevice, vertexDescriptor: MTLVertexDescriptor) throws -> MTKMesh {
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

// Copyright © haijian. All rights reserved.

import MetalKit

extension Mesh {
	func load(from vertexDescriptor: MTLVertexDescriptor) {
		guard let mdlMesh = self.mdlMesh else { return }
		// Create MDLVertexDescriptor.
		let mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
		guard let attributes = mdlVertexDescriptor.attributes as? [MDLVertexAttribute] else { return }
		attributes[VertexAttribute.position.rawValue].name = MDLVertexAttributePosition
		attributes[VertexAttribute.texcoord.rawValue].name = MDLVertexAttributeTextureCoordinate
		attributes[VertexAttribute.normal.rawValue].name = MDLVertexAttributeNormal
		mdlMesh.vertexDescriptor = mdlVertexDescriptor
		// Create MTKMesh.
		guard let device = Application.sharedInstance.device else { return }
		do {
			mtkMesh = try MTKMesh(mesh: mdlMesh, device: device)
		} catch {
			print("Unable to build MetalKit Mesh. Error info: \(error)")
			return
		}
		guard let mesh = mtkMesh else { return }
		// TODO: use library settings.
		vertexBufferIndices.reserveCapacity(0x20)
		for (index, element) in mesh.vertexDescriptor.layouts.enumerated() {
			guard let layout = element as? MDLVertexBufferLayout else { return }
			if layout.stride != 0 { vertexBufferIndices.append(index) }
		}
	}
}

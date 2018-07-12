// Copyright © haijian. All rights reserved.

import MetalKit

/// Types of geometric primitives for rendering a submesh, used by the geometryType property.
public typealias GeometryType = MDLGeometryType

// MARK: - Primitive extension for creating various primitive gameobjects by using the GameObject.create... functions.
extension GameObject {

	/// Creates a primitive gameobject in the shape of a rectangular box or cube.
	///
	/// - Parameters:
	///   - dimensions: A vector containing the width (x-component), height (y-component), and depth (z-component) of the box to generate. If all components are equal, this method generates a cube.
	///   - segments: The number of points to generate along each dimension. A larger number of points increases rendering fidelity but decreases rendering performance.
	///   - geometryType: The type of geometric primitive from which to construct the mesh; must be either kindTriangles, kindQuads, or lines.
	///   - inwardNormals: true to generate normal vectors pointing toward the inside of the box; false to generate normal vectors pointing outward.
	/// - Returns: A new GameObject with MeshRenderer component.
	public static func createBox(withDimensions dimensions: Vector3 = Vector3(1), segments: Uint3 = Uint3(1), geometryType: GeometryType = .triangles, inwardNormals: Bool = false) -> GameObject? {
		guard let device = View.main.device else { return nil }
		let mtkMeshBufferAllocator = MTKMeshBufferAllocator(device: device)
		let mdlMesh = MDLMesh.newBox(withDimensions: dimensions, segments: segments, geometryType: geometryType, inwardNormals: inwardNormals, allocator: mtkMeshBufferAllocator)
		return GameObject.createMeshGameObject(device, with: mdlMesh)
	}
	
	/// Creates a primitive gameobject in the shape of an ellipsoid or sphere.
	///
	/// - Parameters:
	///   - radius: A vector containing the width (x-component), height (y-component), and depth (z-component) of the bounding box of the ellipsoid to generate. If all components are equal, this method generates a sphere.
	///   - radialSegments: The number of points to generate around the horizontal circumference of the ellipsoid (that is, its cross-section in the xz-plane). A larger number of points increases rendering fidelity but decreases rendering performance.
	///   - verticalSegments: The number of points to generate along the height of the ellipsoid. A larger number of points increases rendering fidelity but decreases rendering performance.
	///   - geometryType: The type of geometric primitive from which to construct the mesh; must be either kindTriangles or kindQuads.
	///   - inwardNormals: true to generate normal vectors pointing toward the center of the ellipsoid; false to generate normal vectors pointing outward.
	///   - hemisphere: true to generate only the upper half of the ellipsoid or sphere (a dome); false to generate a complete ellipsoid or sphere.
	/// - Returns: A new GameObject with MeshRenderer component.
	public static func createEllipsoid(withRadii radius: Vector3 = Vector3(1), radialSegments: Int = 24, verticalSegments: Int = 18, geometryType: GeometryType = .triangles, inwardNormals: Bool = false, hemisphere: Bool = false) -> GameObject? {
		guard let device = View.main.device else { return nil }
		let mtkMeshBufferAllocator = MTKMeshBufferAllocator(device: device)
		let mdlMesh = MDLMesh.newEllipsoid(withRadii: radius, radialSegments: radialSegments, verticalSegments: verticalSegments, geometryType: geometryType, inwardNormals: inwardNormals, hemisphere: hemisphere, allocator: mtkMeshBufferAllocator)
		return GameObject.createMeshGameObject(device, with: mdlMesh)
	}

	/// Creates a primitive gameobject in the shape of a rectangular plane.
	///
	/// - Parameters:
	///   - dimensions: A vector containing the width (x-component) and depth (y-component) of the plane to generate.
	///   - segments: The number of points to generate along each dimension. A larger number of points increases rendering fidelity but decreases rendering performance.
	///   - geometryType: The type of geometric primitive from which to construct the mesh; must be either kindTriangles or
	/// - Returns: A new GameObject with MeshRenderer component.
	public static func createPlane(withDimensions dimensions: Vector2 = Vector2(10), segments: Uint2 = Uint2(10), geometryType: GeometryType = .triangles) -> GameObject? {
		guard let device = View.main.device else { return nil }
		let mtkMeshBufferAllocator = MTKMeshBufferAllocator(device: device)
		let mdlMesh = MDLMesh.newPlane(withDimensions: dimensions, segments: segments, geometryType: geometryType, allocator: mtkMeshBufferAllocator)
		return GameObject.createMeshGameObject(device, with: mdlMesh)
	}

	/// Create a basic gameobject with MDLMesh.
	///
	/// - Parameters:
	///   - device: MTLDevice
	///   - mdlMesh: MDLMesh
	/// - Returns: GameObject?
	private static func createMeshGameObject(_ device: MTLDevice, with mdlMesh: MDLMesh) -> GameObject? {
		// Create GameObject with MeshRenderer component.
		guard let gameObject = GameObject() else { return nil }
		guard let meshRenderer: MeshRenderer = gameObject.addComponent() else { return nil }
		// Attach material
		guard let shader = Shader(device) else { return nil }
		let material = Material(with: shader)
		meshRenderer.material = material
		// TODO: refactor.
		// Create MDLVertexDescriptor.
		let mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(shader.vertexDescriptor)
		guard let attributes = mdlVertexDescriptor.attributes as? [MDLVertexAttribute] else { return nil }
		attributes[VertexAttribute.position.rawValue].name = MDLVertexAttributePosition
		attributes[VertexAttribute.texcoord.rawValue].name = MDLVertexAttributeTextureCoordinate
		mdlMesh.vertexDescriptor = mdlVertexDescriptor
		// Create MTKMesh.
		let mtkMesh: MTKMesh
		do {
			mtkMesh = try MTKMesh(mesh: mdlMesh, device: device)
		} catch {
			print("Unable to build MetalKit Mesh. Error info: \(error)")
			return nil
		}
		meshRenderer.mesh = Mesh(with: mtkMesh)
		return gameObject
	}
}

// Copyright © haijian. All rights reserved.

import MetalKit

// MARK: - MTLDataType type mapping extension.
extension MTLDataType {
	
	/// Values that specify the organization of function vertex data.
	var format: MTLVertexFormat {
		switch self {
		case .float2:
			return MTLVertexFormat.float2
		case .float3:
			return MTLVertexFormat.float3
		default:
			return MTLVertexFormat.invalid
		}
	}
	
	/// The distance, in bytes, between the attribute data of two vertices in the buffer.
	var stride: Int {
		switch self {
		case .float2:
			return MemoryLayout<Float>.stride * 2
		case .float3:
			return MemoryLayout<Float>.stride * 3
		default:
			return 0
		}
	}
}

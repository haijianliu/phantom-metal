// Copyright © haijian. All rights reserved.

import MetalKit

public enum ShaderType {
	
	case standard
	case shadowMap
	case normalColor
	
	internal var label: String {
		return String(describing: self)
	}
	
	internal var vertex: String {
		switch self {
		case .standard, .shadowMap, .normalColor:
			return "standardVertex"
		}
	}
	
	internal var fragment: String {
		switch self {
		case .standard:
			return "standardFragment"
		case .shadowMap:
			return "normalColorFragment" // TODO: shadowmap shader
		case .normalColor:
			return "normalColorFragment"
		}
	}
	
	internal var colorAttachmentsPixelFormat: [MTLPixelFormat] {
		switch self {
		case .standard, .normalColor:
			let formats: [MTLPixelFormat] = [MTLPixelFormat.bgra8Unorm_srgb]
			return formats
		case .shadowMap:
			let formats: [MTLPixelFormat] = [MTLPixelFormat.bgra8Unorm_srgb]
			return formats
		}
	}
	
	internal var colorAttachmentsCount: Int {
		switch self {
		case .standard, .normalColor, .shadowMap:
			return 1
		}
	}
	
	internal var depthAttachmentPixelFormat: MTLPixelFormat {
		switch self {
		case .standard, .normalColor, .shadowMap:
			return MTLPixelFormat.depth32Float_stencil8
		}
	}
	
	internal var stencilAttachmentPixelFormat: MTLPixelFormat {
		switch self {
		case .standard, .normalColor, .shadowMap:
			return MTLPixelFormat.depth32Float_stencil8
		}
	}
	
	internal var sampleCount: Int {
		switch self {
		case .standard, .normalColor:
			return AntialiasingMode.none.rawValue
		case .shadowMap:
			return AntialiasingMode.none.rawValue
		}
	}
	
	private var functionConstants: ContiguousArray<Bool> {
		var functionContants = ContiguousArray<Bool>(repeating: false, count: FunctionConstant.count.rawValue)
		switch self {
		case .standard:
			functionContants[FunctionConstant.baseColorMapIndex.rawValue] = true
			functionContants[FunctionConstant.lightIndex.rawValue] = true
			functionContants[FunctionConstant.normalIndex.rawValue] = true
		case .shadowMap:
			functionContants[FunctionConstant.normalIndex.rawValue] = true
		//			break  TODO: shadowmap
		case .normalColor:
			functionContants[FunctionConstant.normalIndex.rawValue] = true
		}
		return functionContants
	}
	
	internal var functionConstantValues: MTLFunctionConstantValues {
		var functionConstants = self.functionConstants
		let functionConstantValues = MTLFunctionConstantValues()
		for index in 0 ..< FunctionConstant.count.rawValue {
			let mutablePointer = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
			mutablePointer.initialize(to: functionConstants[index])
			let rawPointer = UnsafeRawPointer(mutablePointer)
			functionConstantValues.setConstantValue(rawPointer, type: .bool, index: index)
		}
		// TODO: deallocate.
		return functionConstantValues
	}
}

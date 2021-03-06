// Copyright © haijian. All rights reserved.

import MetalKit

// TODO: refactor shader type values varys from different renderpasses.
public enum ShaderType {
	
	case standard
	case shadowMap
	case normalColor
	case postEffect
	
	internal var label: String {
		return String(describing: self)
	}
	
	internal var vertex: String? {
		switch self {
		case .standard, .shadowMap, .normalColor:
			return "standardVertex"
		case .postEffect:
			return "directVertex"
		}
	}
	
	internal var fragment: String? {
		switch self {
		case .standard:
			return "standardFragment"
		case .normalColor:
			return "normalColorFragment"
		case .shadowMap:
			return nil
		case .postEffect:
			return "postEffectFragment"
		}
	}
	
	internal var colorAttachmentsPixelFormat: [MTLPixelFormat] {
		switch self {
		case .standard, .normalColor, .postEffect:
			let formats: [MTLPixelFormat] = [MTLPixelFormat.bgra8Unorm_srgb]
			return formats
		case .shadowMap:
			let formats: [MTLPixelFormat] = [MTLPixelFormat.invalid]
			return formats
		}
	}
	
	internal var depthAttachmentPixelFormat: MTLPixelFormat {
		switch self {
		case .postEffect, .standard, .normalColor:
			return MTLPixelFormat.depth32Float_stencil8
		case .shadowMap:
			return MTLPixelFormat.depth32Float
		}
	}
	
	internal var stencilAttachmentPixelFormat: MTLPixelFormat {
		switch self {
		case .postEffect, .standard, .normalColor:
			return MTLPixelFormat.depth32Float_stencil8
		case .shadowMap:
			return MTLPixelFormat.invalid
		}
	}
	
	internal var sampleCount: Int {
		switch self {
		case .standard, .normalColor:
			return AntialiasingMode.none.rawValue
		case .shadowMap:
			return AntialiasingMode.none.rawValue
		case .postEffect:
			return AntialiasingMode.none.rawValue
		}
	}
	
	private var functionConstants: ContiguousArray<Bool> {
		var functionContants = ContiguousArray<Bool>(repeating: false, count: FunctionConstant.count.rawValue)
		switch self {
		case .standard:
			functionContants[FunctionConstant.hasBaseColorMap.rawValue] = true
			functionContants[FunctionConstant.hasLight.rawValue] = true
			functionContants[FunctionConstant.recieveShadow.rawValue] = true // TODO: if recieve shadows.
		case .shadowMap: break
		case .postEffect:
			functionContants[FunctionConstant.hasBaseColorMap.rawValue] = true
			functionContants[FunctionConstant.recieveShadow.rawValue] = true // TODO: if recieve shadows.
		case .normalColor:
			functionContants[FunctionConstant.hasNormal.rawValue] = true // for debug shadera.
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

// Copyright © haijian. All rights reserved.

import MetalKit

public enum ShaderType {
	
	case standard
	case normalColor
	
	internal var vertex: String {
		switch self {
		case .standard, .normalColor:
			return "standardVertex"
		}
	}
	
	internal var fragment: String {
		switch self {
		case .standard:
			return "standardFragment"
		case .normalColor:
			return "normalColorFragment"
		}
	}
	
	private var functionConstants: ContiguousArray<Bool> {
		var functionContants = ContiguousArray<Bool>(repeating: false, count: FunctionConstant.count.rawValue)
		switch self {
		case .standard:
			functionContants[FunctionConstant.baseColorMapIndex.rawValue] = true
		default: break
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

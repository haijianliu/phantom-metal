// Copyright © haijian. All rights reserved.

public enum ShaderType {
	
	case primitive
	case primitiveNormalColor
	
	var vertex: String {
		switch self {
		case .primitive:
			return "vertexShader"
		case .primitiveNormalColor:
			return "vertexShader"
		}
	}
	
	var fragment: String {
		switch self {
		case .primitive:
			return "fragmentShader"
		case .primitiveNormalColor:
			return "primitiveNormalColor"
		}
	}
}

// Copyright © haijian. All rights reserved.

public enum ShaderType {
	
	case standard
	case normalColor
	
	internal var vertex: String {
		switch self {
		case .standard:
			return "standardVertex"
		case .normalColor:
			return "standardNoTextureVertex"
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
}

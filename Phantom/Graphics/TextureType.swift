// Copyright © haijian. All rights reserved.

public enum TextureType {
	case color
	case shadow
	
	internal var textureIndex: Int {
		switch self {
		case .color:
			return TextureIndex.color.rawValue
		case .shadow:
			return TextureIndex.shadow.rawValue
		}
	}
}

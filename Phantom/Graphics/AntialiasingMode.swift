// Copyright © haijian. All rights reserved.

/// Modes for antialiased rendering of the view’s scene.
///
/// - none: Disables antialiased rendering.
/// - multisampling2X: Enables multisample antialiasing, with two samples per screen pixel.
/// - multisampling4X: Enables multisample antialiasing, with four samples per screen pixel.
/// - multisampling8X: Enables multisample antialiasing, with eight samples per screen pixel.
/// - multisampling16X: Enables multisample antialiasing, with sixteen samples per screen pixel.
enum AntialiasingMode: Int {
	case none = 1
	case multisampling2X = 2
	case multisampling4X = 4
	case multisampling8X = 8
	case multisampling16X = 16
}

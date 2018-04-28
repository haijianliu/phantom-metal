// Copyright © haijian. All rights reserved.

import MetalKit

/// Drawable Behaviour protocol to draw comformed objects on the screen.
///
/// Requires that class inherits from Renderer
@objc protocol Drawable: Behaviour where Self: Renderer {

	/// Draw objects on the screen.
	///
	/// Updated every frame by render thread (s).
	func draw(in view: MTKView)
}

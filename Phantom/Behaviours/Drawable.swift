// Copyright © haijian. All rights reserved.

/// General functionality for all renderers (drawable objects).
///
/// A drawable object is what makes an object appear on the screen. Use this class to access the renderer of any object, mesh or particle system. Drawable objects can be disabled to make objects invisible (Automatically adopt from Component class), and the materials can be accessed and modified through them (see Material).
@objc protocol Drawable: Behaviour {
	
	/// Draw object on the screen.
	///
	/// Updated every frame by render thread (s).
	func draw()
}

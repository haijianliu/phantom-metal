// Copyright © haijian. All rights reserved.

/// General functionality for all renderers, **defined by framework only**. And implemented by inherited and conforming Drawable protocol.
///
/// A renderer is what makes an object appear on the screen. Use this class to access the renderer of any object, mesh or particle system. Renderers can be disabled to make objects invisible (see enabled), and the materials can be accessed and modified through them (see material).
public class Renderer: Component {

	/// Is this renderer visible in any camera? (Read Only)
	///
	/// Note that the object is considered visible when it needs to be rendered in the scene. For example, it might not actually be visible by any camera but still need to be rendered for shadows. When running in the editor, the scene view cameras will also cause this value to be true.
	public var isVisible: Bool {
		return true // TODO: computed from draw list
	}

	/// Material assigned to the renderer.
	///
	/// TODO: If there is no material attached to the renderer, framework will draw a cube using outline mode, with a size of the transform scale.
	///
	/// Material is a value type, modifying material will change the material for this object only.
	/// Copy the material to any other renderers, this will make a clone this current material.
	public var material: Material? // TODO: multi materials.
}

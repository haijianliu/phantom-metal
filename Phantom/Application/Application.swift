// Copyright © haijian. All rights reserved.

import MetalKit

/// The single instance of application interface that manages game resources, event loop and status.
public class Application {
	// TODO: no singleton
	static let sharedInstance: Application = Application()
	// TODO: initialize capacity.
	private init() {
		// TODO: use library settings.
		updatableBehaviours.reserveCapacity(0xFF)
		renderableBehaviours.reserveCapacity(0xFF)
		lightableBehaviours.reserveCapacity(0xF)
	}
	
	weak var view: MTKView?
	weak var device: MTLDevice?
	/// TODO: use global default library and customize library option.
	var library: MTLLibrary?
	
	// TODO: remove
	/// MTKViewDelegat reference holder.
	var viewDelegate = ViewDelegate()
	
	/// The only game object references holder.
	var gameObjects = [GameObject]()
	
	// TODO: clean up nil reference.
	/// A [contiguous array](http://jordansmith.io/on-performant-arrays-in-swift/) to update behaviour weak reference list in real time, reserving a capacity of 256 elements.
	var updatableBehaviours = ContiguousArray<Weak<Updatable>>()
	var renderableBehaviours = ContiguousArray<Weak<Renderable>>()
	var lightableBehaviours = ContiguousArray<Weak<Lightable>>()
}

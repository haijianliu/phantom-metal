// Copyright © haijian. All rights reserved.

/// Updatable Behaviour protocol updates Behavour every frame.
///
/// Requires that class inherits from Behaviour
@objc public protocol Updatable where Self: Behaviour {
	/// Update is called every frame, if the Behaviour is enabled.
	///
	/// In order to get the elapsed time since last call to Update, use Time.deltaTime. This function is only called if the Behaviour is enabled. Override this function in order to provide your component's functionality.
	func update()
}

// TODO: Remove "redundant layout constraint" warning [SR-6265](https://bugs.swift.org/browse/SR-6265)
// public protocol Updatable: AnyObject where Self: Behaviour

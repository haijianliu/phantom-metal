// Copyright © haijian. All rights reserved.

/// A set of methods that delegates of Application objects can implement.
public protocol ApplicationDelegate: AnyObject {
	/// Invoked after the application has been launched and initialized but before it has received its first event.
	func start()
}

// Copyright © haijian. All rights reserved.

/// Generic wrapper of weak reference
class Weak<T: AnyObject> {
	weak var reference : T?
	init(reference: T) {
		self.reference = reference
	}
}

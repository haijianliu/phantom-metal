// Copyright © haijian. All rights reserved.

/// Behaviours are Components that can be enabled or disabled.
@objc public protocol Behaviour where Self: Component {

	/// Enabled Behaviours are updated, disabled Behaviours are not.
	///
	/// Automatically adopted and comformed by Component (Default: true).
	var enabled: Bool { get set }
}

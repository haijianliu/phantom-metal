// Copyright © haijian. All rights reserved.

/// Behaviours are Components that can be enabled or disabled.
open class Behaviour: Component {
	
	/// Enabled Behaviours are updated, disabled Behaviours are not.
	// TODO: setter getter to update behaviour-list
	public var enabled: Bool {
		return true
	}
}

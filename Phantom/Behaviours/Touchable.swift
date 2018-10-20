// Copyright © haijian. All rights reserved.

import UIKit

@objc public protocol Touchabe: Behaviour {
	/// Tells this object that one or more new touches occurred in a view or window.
	///
	/// - Parameters:
	///   - touches: A set of UITouch instances that represent the touches for the starting phase of the event, which is represented by event.
	///   - event: The event to which the touches belong.
	@objc optional func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
	
	/// Tells the responder when one or more touches associated with an event changed.
	///
	/// - Parameters:
	///   - touches: A set of UITouch instances that represent the touches for the starting phase of the event, which is represented by event.
	///   - event: The event to which the touches belong.
	@objc optional func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
	
	/// Tells the responder when one or more fingers are raised from a view or window.
	///
	/// - Parameters:
	///   - touches: A set of UITouch instances that represent the touches for the starting phase of the event, which is represented by event.
	///   - event: The event to which the touches belong.
	@objc optional func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
	
	/// Tells the responder when a system event (such as a system alert) cancels a touch sequence.
	///
	/// - Parameters:
	///   - touches: A set of UITouch instances that represent the touches for the starting phase of the event, which is represented by event.
	///   - event: The event to which the touches belong.
	@objc optional func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
}

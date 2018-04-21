// Copyright © haijian. All rights reserved.

import Cocoa
import PhantomKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
		let sampleApplication = SampleApplication()
		Application.launch(application: sampleApplication)
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}
}

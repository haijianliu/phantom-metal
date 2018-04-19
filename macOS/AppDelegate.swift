// Copyright © haijian. All rights reserved.

import Cocoa
import PhantomKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	var application = Application()

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
		application.launch()
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}
}

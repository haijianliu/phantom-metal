// Copyright © haijian. All rights reserved.

import MetalKit

/// The single instance of application interface that manages game resources, event loop and status.
public class Application {
	// TODO: no singleton
	static let sharedInstance: Application = Application()
	// TODO: initialize capacity.
	private init() { }
	
	weak var view: MTKView?
	weak var device: MTLDevice?
	/// TODO: use global default library and customize library option.
	var library: MTLLibrary?
	
	// TODO: multi scene?
	/// TODO: Run-time data structure for *.scene file.
	var scene: Scene?
	
	// TODO: remove
	/// MTKViewDelegat reference holder.
	var viewDelegate = ViewDelegate()
	
	static func addRenderPass<RenderPassType: RenderPass>() -> RenderPassType? {
		let typeName = String(describing: RenderPassType.self)
		guard let scene = Application.sharedInstance.scene else { return nil }
		if scene.renderPasses[typeName] == nil {
			guard let device = Application.sharedInstance.device else { return nil }
			guard let renderPass = RenderPassType(device: device) else { return nil }
			scene.renderPasses[typeName] = renderPass
			Application.sharedInstance.viewDelegate.addRenderPass(renderPass)
		}
		return scene.renderPasses[typeName] as? RenderPassType
	}
}

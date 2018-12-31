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

	static func currentViewTarget(targetType: RenderTargetType) -> MTLTexture? {
		switch targetType {
		case .depth:
			return Application.sharedInstance.view?.currentRenderPassDescriptor?.depthAttachment.texture
		default:
			return Application.sharedInstance.view?.currentRenderPassDescriptor?.colorAttachments[targetType.rawValue].texture
		}
	}
}

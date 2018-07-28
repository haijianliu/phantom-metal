// Copyright © haijian. All rights reserved.

import MetalKit

/// The drawable protocol to be used for committing command buffer to draw in the current frame. Comformed by render pass and executed in main view.
protocol Drawable {
	/// Commits this command buffer for execution as soon as possible.
	///
	/// Every time call this draw method, the command buffer will be committed in the main view synchronously and executed by the GPU. So only use this command buffer to create command encoder.
	///
	/// - Parameter view: [MTKView](apple-reference-documentation://hs_tBxHxll)
	/// - Parameter commandBuffer: [MTLCommandBuffer](apple-reference-documentation://hsHQan1YfR)
	func draw(in view: MTKView, by commandBuffer: MTLCommandBuffer)
}

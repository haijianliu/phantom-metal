// Copyright © haijian. All rights reserved.

import MetalKit

public struct ViewDescriptor {
	// View descriptors.
	
	/// The color pixel format for the current drawable's texture.
	///
	/// The pixel format for a MetalKit view must be bgra8Unorm, bgra8Unorm_srgb, rgba16Float, BGRA10_XR, or bgra10_XR_sRGB.
	///
	/// The default value is bgra8Unorm.
	public var colorPixelFormat: MTLPixelFormat = .bgra8Unorm
	
	/// The format used to generate the depthStencilTexture object.
	///
	/// The default value is invalid.
	public var depthStencilPixelFormat: MTLPixelFormat = .invalid
	
	// TODO: Max sampling test.
	/// The sample count used to generate the multisampleColorTexture object.
	///
	/// The default value is 1.
	///
	/// Support for different sample count values varies by device. Call the supportsTextureSampleCount(_:) method to determine if your desired sample count value is supported.
	public var sampleCount: Int = 1
	
	
	/// The color clear value used to generate the currentRenderPassDescriptor object.
	///
	/// The default value is (0.0, 0.0, 0.0, 1.0).
	public var clearColor: MTLClearColor = MTLClearColorMake(0, 0, 0, 1)
	
	/// The depth clear value used to generate the currentRenderPassDescriptor object.
	///
	/// The default value is 1.0.
	public var clearDepth: Double = 1
	
	
	/// The stencil clear value used to generate the currentRenderPassDescriptor object.
	///
	/// The default value is 0.
	public var clearStencil: UInt32 = 0
	
	// Renderpasses descriptors.
	
	/// If uses posteffects. The default value is false.
	public var usePostEffect: Bool = false
	
	public init() { }
}

// Copyright © haijian. All rights reserved.

import MetalKit

/// Renderable Behaviour protocol to encode draw commands.
/// These behaviours will be stored in render pass instance as weak references,
/// and update encoding during render pass executing draw function.
///
/// Requires that class inherits from Renderer
@objc protocol Renderable: Behaviour, RenderEncodable where Self: Renderer { }

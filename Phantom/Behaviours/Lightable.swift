// Copyright © haijian. All rights reserved.

/// Lightable behaviours encodes light buffer separately from renderables.
/// These behaviours will be stored in background render pass (TODO) (QoS: background) instance as weak references,
/// and update encoding light buffers per scene, during render pass executing draw function.
@objc protocol Lightable: Behaviour {
	/// Shared light data structrue shared by MetalKit and Metal (Read only).
	var lightData: LightData { get }
}

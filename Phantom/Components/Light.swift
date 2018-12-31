// Copyright © haijian. All rights reserved.

public class Light: Component, Lightable {
	/// The color of the light.
	public var color = Vector3(1)
	/// The Intensity of a light is multiplied with the Light color.
	public var intensity: Float = 1

	// TODO: use dirty.
	/// Shared light data structrue shared by MetalKit and Metal (Read only).
	var lightData: LightData {
		var lightData = LightData()
		lightData.color = color
		lightData.intensity = intensity
		lightData.position = transform.position
		return lightData
	}
}

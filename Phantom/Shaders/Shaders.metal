// Copyright © haijian. All rights reserved.

// File for Metal kernel and shader functions
#include <metal_stdlib>
using namespace metal;

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "Phantom/BridgingHeaders/Uniform.h"
#import "Attributes.metal"
#import "Inouts.metal"

vertex ColorInOut vertexShader(Vertex in [[stage_in]], constant Transformations & transformations [[ buffer(BufferIndexTransformations) ]])
{
	ColorInOut out;

	float4 position = float4(in.position, 1.0);
	out.position = transformations.projectionMatrix * transformations.modelViewMatrix * position;
	out.texcoord = in.texcoord;

	return out;
}

fragment float4 fragmentShader(ColorInOut in [[stage_in]], texture2d<half> colorMap [[ texture(TextureIndexColor) ]])
{
	constexpr sampler colorSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);

	half4 colorSample   = colorMap.sample(colorSampler, in.texcoord.xy);
	float3 color = mix(float3(0, 1, 0), float3(colorSample.xyz), float(colorSample.a));

	return float4(color, 1);
}

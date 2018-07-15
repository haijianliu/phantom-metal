// Copyright © haijian. All rights reserved.

// File for Metal kernel and shader functions
#include <metal_stdlib>
using namespace metal;

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "Phantom/BridgingHeaders/Uniform.h"
#import "Attributes.metal"
#import "Inouts.metal"
#import "Functions.metal"

vertex ColorInOut vertexShader(Vertex in [[stage_in]], constant NodeBuffer & nodebuffer [[ buffer(BufferIndexNodeBuffer) ]])
{
	ColorInOut out;
	
	out.projectionPosition = nodebuffer.projectionMatrix * nodebuffer.viewMatrix * nodebuffer.modelMatrix * float4(in.position, 1.0);
	out.modelPosition = in.position;
	out.worldPosition = (nodebuffer.modelMatrix * float4(in.position, 1.0)).xyz;
	out.texcoord = float2(in.texcoord.x, in.texcoord.y);
	out.normal = in.normal;
	out.worldNormal = normalize((nodebuffer.modelMatrix * float4(in.normal, 1.0)).xyz);
	
	return out;
}

fragment float4 fragmentShader(ColorInOut in [[stage_in]], texture2d<half> colorMap [[ texture(TextureIndexColor) ]])
{
	constexpr sampler colorSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);

	half4 colorSample = colorMap.sample(colorSampler, in.texcoord.xy);
	float3 color = mix(float3(0, 1, 0), float3(colorSample.xyz), float(colorSample.a));
//	float3 color = normalTangentToWorld(in.worldNormal, in.worldPosition, in.texcoord);
//	float3 color = in.normal;
//	color = float3(dot(color, float3(0, -1, 0)));
//	float3 color = float3(in.texcoord, 0);

	return float4(color, 1);
}

fragment float4 primitiveNormalColor(ColorInOut in [[stage_in]])
{
	return float4(in.normal, 1);
}

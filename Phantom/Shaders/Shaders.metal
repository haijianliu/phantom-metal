// Copyright © haijian. All rights reserved.

// File for Metal kernel and shader functions
#include <metal_stdlib>
using namespace metal;

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "Phantom/BridgingHeaders/Uniform.h"

// Fuction constants.
constant bool has_base_color_map [[function_constant(FunctionConstantBaseColorMapIndex)]];
constant bool has_normal_map [[function_constant(FunctionConstantNormalMapIndex)]];
constant bool has_metallic_map [[function_constant(FunctionConstantMetallicMapIndex)]];
constant bool has_roughness_map [[function_constant(FunctionConstantRoughnessMapIndex)]];
constant bool has_ambient_occlusion_map [[function_constant(FunctionConstantAmbientOcclusionMapIndex)]];
constant bool has_irradiance_map [[function_constant(FunctionConstantIrradianceMapIndex)]];
constant bool has_any_map = (has_base_color_map || has_normal_map || has_metallic_map || has_roughness_map || has_ambient_occlusion_map || has_irradiance_map);
constant bool has_light [[function_constant(FunctionConstantLightIndex)]];
constant bool use_normal [[function_constant(FunctionConstantNormalIndex)]];
constant bool use_light = (has_light && use_normal);
constant bool recieve_shadow [[function_constant(FunctionConstantShadowMapIndex)]];

/// Vertex attributes.
typedef struct
{
	float3 position [[attribute(VertexAttributePosition)]];
	float2 texcoord [[attribute(VertexAttributeTexcoord), function_constant(has_any_map)]];
	float3 normal [[attribute(VertexAttributeNormal), function_constant(use_normal)]];
} Vertex;

/// Inout parameters.
typedef struct
{
	float4 projectionPosition [[position]];
	float3 worldPosition;
	float2 texcoord [[function_constant(has_any_map)]];
	float3 worldNormal [[function_constant(use_normal)]];
} ColorInOut;

/// Standard vertex shader parameters.
typedef struct
{
	constant NodeBuffer& nodebuffer [[buffer(BufferIndexNodeBuffer)]];
	constant CameraBuffer& camerabuffer [[buffer(BufferIndexCameraBuffer)]];
} StandardVertexParameter;

/// Standard fragmetn shader parameters.
typedef struct
{
	texture2d<half> colorMap [[texture(TextureIndexColor), function_constant(has_base_color_map)]];
	depth2d<float> shadowMap [[texture(TextureIndexShadow), function_constant(recieve_shadow)]];
	constant CameraBuffer& shadowbuffer [[buffer(BufferIndexShadowMapBuffer), function_constant(recieve_shadow)]];
	constant LightBuffer& lightbuffer [[buffer(BufferIndexLightBuffer), function_constant(use_light)]];
} StandardFragmentParameter;

/// Standard vertex shader using texcoord and normal.
vertex ColorInOut standardVertex(Vertex in [[stage_in]], StandardVertexParameter parameter)
{
	ColorInOut out;
	
	out.projectionPosition = parameter.camerabuffer.viewProjectionMatrix * parameter.nodebuffer.modelMatrix * float4(in.position, 1.0);
	
	out.worldPosition = (parameter.nodebuffer.modelMatrix * float4(in.position, 1.0)).xyz;
	
	if (has_any_map) {
		out.texcoord = float2(in.texcoord.x, in.texcoord.y);
	}
	
	if (use_normal) {
		out.worldNormal = normalize((parameter.nodebuffer.inverseTransposeModelMatrix * float4(in.normal, 0)).xyz);
	}
	
	return out;
}

/// Standard fragment shader using color texture and normal.
fragment float4 standardFragment(ColorInOut in [[stage_in]], StandardFragmentParameter parameter)
{
	float3 color = float3(0, 0, 1);
	
	if (has_base_color_map) {
		constexpr sampler colorSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);
		half4 colorSample = parameter.colorMap.sample(colorSampler, in.texcoord.xy);
		color = float3(colorSample.xyz);
	}
	
	// TODO: Use scene node for lighting.
	if (use_light) {
		float3 lightColor = float3(0, 0, 0);
		for (int i = 0; i < parameter.lightbuffer.count; i++) {
			float3 lightVector = normalize(parameter.lightbuffer.light[i].position - in.worldPosition);
			float lightFactor = fmax(dot(lightVector, in.worldNormal), 0);
			lightColor += lightFactor * parameter.lightbuffer.light[i].intensity * parameter.lightbuffer.light[i].color;
		}
		color *= lightColor;
		// TODO: tonemapping.
	}
	
	if (recieve_shadow) {
		constexpr sampler shadowSampler(coord::normalized, filter::linear, address::clamp_to_border, compare_func::less);
		float4 lightSpacePosition = parameter.shadowbuffer.viewProjectionMatrix * float4(in.worldPosition, 1);
		float2 lightSpaceUV = lightSpacePosition.xy / lightSpacePosition.w;
		lightSpaceUV = lightSpaceUV * 0.5 + 0.5;
		lightSpaceUV.y = 1 - lightSpaceUV.y;
		float closestDepth = parameter.shadowMap.sample(shadowSampler, lightSpaceUV);
		float currentDepth = lightSpacePosition.z / lightSpacePosition.w;
		float shadowFactor = currentDepth - 0.0001 > closestDepth ? 0.2 : 1;
		if (closestDepth < 0.001) shadowFactor = 1;
		color *= shadowFactor;
	}
	
	// test.
//	color = float3(in.projectionPosition.z / in.projectionPosition.w / 200.0);
	
	return float4(color, 1);
}

/// Normal color test shader using only normal.
fragment float4 normalColorFragment(ColorInOut in [[stage_in]])
{
	return float4(in.worldNormal, 1);
}

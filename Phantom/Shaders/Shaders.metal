// Copyright © haijian. All rights reserved.

// File for Metal kernel and shader functions
#include <metal_stdlib>
using namespace metal;

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "Phantom/BridgingHeaders/Uniform.h"

// Fuction constants.
constant bool has_base_color_map [[function_constant(FunctionConstantHasBaseColorMap)]];
constant bool has_normal_map [[function_constant(FunctionConstantHasNormalMap)]];
constant bool has_metallic_map [[function_constant(FunctionConstantHasMetallicMap)]];
constant bool has_roughness_map [[function_constant(FunctionConstantHasRoughnessMap)]];
constant bool has_ambient_occlusion_map [[function_constant(FunctionConstantHasAmbientOcclusionMap)]];
constant bool has_irradiance_map [[function_constant(FunctionConstantHasIrradianceMap)]];
constant bool has_any_map = (has_base_color_map || has_normal_map || has_metallic_map || has_roughness_map || has_ambient_occlusion_map || has_irradiance_map);
constant bool has_light [[function_constant(FunctionConstantHasLight)]];
constant bool has_normal [[function_constant(FunctionConstantHasNormal)]]; // for debug shader.
constant bool recieve_shadow [[function_constant(FunctionConstantRecieveShadow)]];
constant bool use_normal = (recieve_shadow || has_light || has_normal);

/// Linear sampled gaussian blur. (http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/)
constant float gaussianLinearSamplingOffset[3] = { 0.0,          1.3846153846, 3.2307692308 };
constant float gaussianLinearSamplingWeight[3] = { 0.2270270270, 0.3162162162, 0.0702702703 };

/// Vertex attributes.
typedef struct
{
	float3 position [[attribute(VertexAttributePosition)]];
	float2 texcoord [[attribute(VertexAttributeTexcoord), function_constant(has_any_map)]];
	float3 normal [[attribute(VertexAttributeNormal), function_constant(use_normal)]];
} Vertex;

// TODO: check if uses world positions.
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
	constant LightBuffer& lightbuffer [[buffer(BufferIndexLightBuffer), function_constant(has_light)]];
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
	if (has_light) {
		float3 lightColor = float3(0, 0, 0);
		for (int i = 0; i < parameter.lightbuffer.count; i++) {
			float3 lightVector = normalize(parameter.lightbuffer.light[i].position - in.worldPosition);
			float lightFactor = fmax(dot(lightVector, in.worldNormal), 0.04);
			lightColor += lightFactor * parameter.lightbuffer.light[i].intensity * parameter.lightbuffer.light[i].color;
		}
		color *= lightColor;
		// TODO: tonemapping.
	}
	
	// Recieve shadows.
	if (recieve_shadow) {
		// Shadow sampler.
		// TODO: pass platform constants.
//		constexpr sampler shadowSampler(coord::normalized, filter::linear, address::clamp_to_border, compare_func::less);
		constexpr sampler shadowSampler(coord::normalized, filter::linear, compare_func::less);
		// Fragment positions in light (shadowmap camera) space.
		float4 lightSpacePosition = parameter.shadowbuffer.viewProjectionMatrix * float4(in.worldPosition, 1);
		// Fragment texcoord in light (shadowmap camera) space.
		float2 lightSpaceTexcoord = lightSpacePosition.xy / lightSpacePosition.w;
		lightSpaceTexcoord = lightSpaceTexcoord * 0.5 + 0.5;
		lightSpaceTexcoord.y = 1 - lightSpaceTexcoord.y;
		// Closest and current depth values from light's perspective.
		float closestDepth = parameter.shadowMap.sample(shadowSampler, lightSpaceTexcoord);
		float currentDepth = lightSpacePosition.z / lightSpacePosition.w;
		// TODO: shadowmap setting.
		// Calculate shadow bias (based on depth map resolution and slope).
		float3 lightDirection = normalize(parameter.shadowbuffer.position - in.worldPosition);
		float shadowBias = max(0.005 * (1.0 - dot(in.worldNormal, lightDirection)), 0.001);
		// check whether current frag pos is in shadow
		// TODO: shadow sample mode function constants, if use PCF.
		float shadowFactor = 0.0;
		if (true) {
			float texelSize = 1.0 / parameter.shadowMap.get_width();
			for(int i = -2; i <= 2; i++) {
				float pcfDepth = parameter.shadowMap.sample(shadowSampler, lightSpaceTexcoord + float2(sign(float(i)) * gaussianLinearSamplingOffset[abs(i)], 0) * texelSize);
				shadowFactor += (currentDepth - shadowBias > pcfDepth ? gaussianLinearSamplingWeight[abs(i)] : 1);
			}
			shadowFactor /= 5.0;
		} else {
			shadowFactor = currentDepth - shadowBias > closestDepth ? 0 : 1;
		}
		// Keep the shadow off when outside the far_plane region of the light's frustum, since iOS is no support for border colors.
		if (closestDepth < 0.001) shadowFactor = 1;
		color *= shadowFactor;
	}
	
	return float4(color, 1);
}

/// Normal color test shader using only normal.
fragment float4 normalColorFragment(ColorInOut in [[stage_in]])
{
	return float4(in.worldNormal, 1);
}

/// Direct vertex shader using position and texcoord and without camera projections for directly screen rendering.
vertex ColorInOut directVertex(Vertex in [[stage_in]])
{
	ColorInOut out;
	
	out.projectionPosition = float4(-in.position.x, in.position.z, 0.5, 1);
	
	if (has_any_map) {
		out.texcoord = float2(1 - in.texcoord.x, 1 - in.texcoord.y);
	}
	
	return out;
}

fragment float4 postEffectFragment(ColorInOut in [[stage_in]], StandardFragmentParameter parameter)
{
	float3 color = float3(0, 0, 0);
	
	if (has_base_color_map && recieve_shadow) {
		constexpr sampler colorSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);
		// TODO: pass platform constants.
//		constexpr sampler depthSampler(coord::normalized, mip_filter::linear, mag_filter::linear, min_filter::linear, address::clamp_to_border, compare_func::less);
		constexpr sampler depthSampler(coord::normalized, mip_filter::linear, mag_filter::linear, min_filter::linear, compare_func::less);
		float closestDepth = parameter.shadowMap.sample(colorSampler, in.texcoord, level(0));
		closestDepth = closestDepth * 100 - 99;
		half3 colorSample = half3(0);
		float texelSize = 1.0 / parameter.colorMap.get_width();
		for (int i = -2; i <= 2; i++) {
//			for (int l = 0; l < 5; l++) {
//				colorSample += parameter.colorMap.sample(colorSampler, in.texcoord + float2(sign(float(i)) * gaussianLinearSamplingOffset[abs(i)], 0) * texelSize, level(l)).xyz * gaussianLinearSamplingWeight[abs(i)];
//			}
			colorSample += parameter.colorMap.sample(colorSampler, in.texcoord + float2(sign(float(i)) * gaussianLinearSamplingOffset[abs(i)], 0) * texelSize, level(4*closestDepth)).xyz * gaussianLinearSamplingWeight[abs(i)];
		}
//		colorSample /= 5;
		color = float3(colorSample);
//		color = color / (color + 1);
	}
	
//	if (has_base_color_map) {
//		constexpr sampler colorSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);
//		constexpr sampler depthSampler(coord::normalized, mip_filter::linear, mag_filter::linear, min_filter::linear, address::clamp_to_border, compare_func::less);
//
//		float closestDepth = parameter.shadowMap.sample(colorSampler, in.texcoord, level(0));
//		closestDepth = pow(closestDepth * 100 - 99.1, 2.2);
//		half4 colorSample = parameter.colorMap.sample(colorSampler, in.texcoord, level(2*closestDepth));
//		color = float3(colorSample.xyz);
//	}
	
	return float4(color, 1);
}

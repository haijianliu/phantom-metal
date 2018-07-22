// Copyright © haijian. All rights reserved.

// File for Metal kernel and shader functions
#include <metal_stdlib>
using namespace metal;

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands

float3 normalTangentToWorld(float3 worldNormal, float3 worldPosition, float2 texcoord)
{
	float3 tangentNormal = worldNormal * 2.0 - 1.0;
	
	float3 q1 = dfdx(worldPosition);
	float3 q2 = dfdy(worldPosition);
	float2 st1 = dfdx(texcoord);
	float2 st2 = dfdy(texcoord);
	
	float3 n = normalize(worldNormal);
	float3 t = normalize(q1 * st2.y - q2 * st1.y);
	float3 b = -normalize(cross(n, t));
	float3x3 tbn = float3x3(t, b, n);
	
	return normalize(tbn * tangentNormal);
}

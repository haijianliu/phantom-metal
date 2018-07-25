// Copyright © haijian. All rights reserved.

#ifndef Uniform_h
#define Uniform_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>

// https://developer.apple.com/documentation/scenekit/scnprogram
// https://forum.unity.com/threads/world-space-normal.58810/

typedef NS_ENUM(NSInteger, FunctionConstant)
{
	FunctionConstantBaseColorMapIndex,
	FunctionConstantNormalMapIndex,
	FunctionConstantMetallicMapIndex,
	FunctionConstantRoughnessMapIndex,
	FunctionConstantAmbientOcclusionMapIndex,
	FunctionConstantIrradianceMapIndex,
	FunctionConstantCount
};

/// An enum that describes how vertex data is organized and mapped to a vertex function. And used by MTLVertexDescriptor and MDLVertexDescriptor to configure how vertex data stored in memory is mapped to attributes in a vertex shader.
typedef NS_ENUM(NSInteger, VertexAttribute)
{
	VertexAttributePosition = 0,
	VertexAttributeTexcoord,
	VertexAttributeNormal,
	VertexAttributeCount
};

/// An enum that describes how buffer data is organized and mapped to shader functions. Raw values continue to vertex attribute indices which is invalid for buffer objects.
typedef NS_ENUM(NSInteger, BufferIndex)
{
	BufferIndexNodeBuffer = VertexAttributeCount,
};

// TODO: Add format and stride information.

typedef NS_ENUM(NSInteger, TextureIndex)
{
	TextureIndexColor,
};

// TODO: Add Scene buffer.

/// To use information that varies for each object being rendered with a shader—such as model and normal matrices—declare a parameter to your shader function with an attribute qualifier.
typedef struct
{
	matrix_float4x4 projectionMatrix;
	matrix_float4x4 viewMatrix;
	matrix_float4x4 modelMatrix;
	matrix_float4x4 inverseTransposeModelMatrix;
} StandardNodeBuffer;

// TODO: Add no normal node buffer. Maybe instance particle type?

#endif /* Uniform_h */

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

typedef NS_ENUM(NSInteger, BufferIndex)
{
	BufferIndexMeshPositions,
	BufferIndexMeshTexcoords,
	BufferIndexMeshNormals,
	BufferIndexNodeBuffer,
};

typedef NS_ENUM(NSInteger, VertexAttribute)
{
	VertexAttributePosition,
	VertexAttributeTexcoord,
	VertexAttributeNormal,
};

// TODO: Add format and stride information.

typedef NS_ENUM(NSInteger, TextureIndex)
{
	TextureIndexColor,
};

// TODO: Add Scene buffer.

/**
 To use information that varies for each object being rendered with a shader—such as model and normal matrices—declare a parameter to your shader function with an attribute qualifier.
 */
typedef struct
{
	matrix_float4x4 projectionMatrix;
	matrix_float4x4 viewMatrix;
	matrix_float4x4 modelMatrix;
} NodeBuffer;

#endif /* Uniform_h */

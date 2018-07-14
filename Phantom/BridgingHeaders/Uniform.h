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

typedef NS_ENUM(NSInteger, BufferIndex)
{
	BufferIndexMeshPositions,
	BufferIndexMeshTexcoords,
	BufferIndexMeshNormals,
	BufferIndexTransformations,
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

/**
 Transformations
 All these matrices are float4x4 type.
 */
typedef struct
{
	matrix_float4x4 projectionMatrix;
	matrix_float4x4 modelViewMatrix;
} Transformations;

#endif /* Uniform_h */

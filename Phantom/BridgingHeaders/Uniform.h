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
	BufferIndexMeshPositions = 0,
	BufferIndexMeshTexcoords = 1,
	BufferIndexTransformations = 2
};

typedef NS_ENUM(NSInteger, VertexAttribute)
{
	VertexAttributePosition = 0,
	VertexAttributeTexcoord = 1,
};

// TODO: Add format and stride information.

typedef NS_ENUM(NSInteger, TextureIndex)
{
	TextureIndexColor = 0,
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

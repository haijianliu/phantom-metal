// Copyright © haijian. All rights reserved.

import MetalKit

class Texture {
	
	var mtlTexture: MTLTexture?
	
	init?(name: String) {
		do {
			mtlTexture = try Texture.load(textureName: name)
		} catch {
			print("Unable to load texture. Error info: \(error)")
			return nil
		}
	}
	
	static func load(textureName: String) throws -> MTLTexture {
		// Load texture data with optimal parameters for sampling
		
		guard let device = Display.main.device else {
			throw RendererError.badVertexDescriptor // TODO: new error
		}
		
		let textureLoader = MTKTextureLoader(device: device)
		
		let textureLoaderOptions = [
			MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
			MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.private.rawValue)
		]
		
		return try textureLoader.newTexture(name: textureName, scaleFactor: 1.0, bundle: nil, options: textureLoaderOptions)
	}
}


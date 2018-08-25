// Copyright © haijian. All rights reserved.

import MetalKit

public class Texture {
	var mtlTexture: MTLTexture?
	var type: TextureType?
	
	// TODO: load defer.
	public init?(name: String, type: TextureType? = nil) {
		do {
			mtlTexture = try Texture.load(textureName: name)
		} catch {
			print("Unable to load texture. Error info: \(error)")
			return nil
		}
		self.type = type
	}
	
	static func load(textureName: String) throws -> MTLTexture {
		// Load texture data with optimal parameters for sampling
		
		guard let device = Application.sharedInstance.device else {
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

extension Texture: RenderEncodable {
	func encode(to renderCommandEncoder: MTLRenderCommandEncoder) {
		// TODO: varies from library?
		if let index = type?.textureIndex {
			renderCommandEncoder.setFragmentTexture(mtlTexture, index: index)
		}
	}
}

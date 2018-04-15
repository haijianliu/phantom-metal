// Copyright © haijian. All rights reserved.

import MetalKit

class MeshRenderer: Component {
	
	var pipelineState: MTLRenderPipelineState?
	
	var mesh: Mesh? {
		didSet {
			// pipeline state
			do {
				pipelineState = try Renderer.buildRenderPipelineWithDevice(device: Display.main.device!, metalKitView: Display.main, mtlVertexDescriptor: (mesh?.mtlVertexDescriptor)!)
			} catch {
				print("Unable to compile render pipeline state.  Error info: \(error)")
				mesh = nil
			}
		}
	}
	
	var texture: Texture?
}

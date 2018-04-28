// Copyright © haijian. All rights reserved.

import MetalKit

public class MeshRenderer: Renderer, Drawable {
	
	var pipelineState: MTLRenderPipelineState?
	
	public var mesh: Mesh? {
		didSet {
			// pipeline state
			do {
				pipelineState = try ViewDelegate.buildRenderPipelineWithDevice(device: View.main.device!, metalKitView: View.main, mtlVertexDescriptor: (mesh?.mtlVertexDescriptor)!)
			} catch {
				print("Unable to compile render pipeline state.  Error info: \(error)")
				mesh = nil
			}
		}
	}
	
	public var texture: Texture? // TODO: Material
	
	func draw() {
	}
}

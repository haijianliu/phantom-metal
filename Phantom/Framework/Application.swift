// Copyright © haijian. All rights reserved.

// TODO: public?
public class Application {
	
	// TODO: no singleton
	static let sharedInstance: Application = Application()
	private init() {}
	
	// Delegate
	weak var delegate: ApplicationDelegate?
	
	var renderer: View?
	var gameObjects = [GameObject]()
	// TODO: array slice
	var updateBehaviours = [Weak<Updatable>]()
	var drawBehaviours = [Weak<Drawable>]()

	public static func launch(application: ApplicationDelegate) {
		Application.sharedInstance.delegate = application
		Application.sharedInstance.delegate?.start()
		Application.sharedInstance.createRenderer()
	}
	
	// TODO: in Scene
	public static func addGameObject(_ gameObjcet: GameObject) {
		Application.sharedInstance.gameObjects.append(gameObjcet)
		for component in gameObjcet.components {
			if let updateBehaviour = component.value as? Updatable {
				Application.sharedInstance.updateBehaviours.append(Weak(reference: updateBehaviour))
			}
		}
	}

	private func createRenderer() {
		// Create Renderer
		guard let newRenderer = View(mtkView: Display.main) else {
			print("Renderer cannot be initialized")
			return
		}
		renderer = newRenderer
		
		// TODO: This will be a Display process
		// Set MTKViewDelegate to current Renderer instance
		Display.main.delegate = renderer
		
		// Only for the first time, should initiate the view manually
		renderer?.mtkView(Display.main, drawableSizeWillChange: Display.main.drawableSize)
	}
}

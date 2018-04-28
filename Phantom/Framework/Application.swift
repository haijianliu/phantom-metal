// Copyright © haijian. All rights reserved.

// TODO: public?
public class Application {
	
	// TODO: no singleton
	static let sharedInstance: Application = Application()
	private init() {}
	
	// Delegate
	weak var delegate: ApplicationDelegate?
	
	var viewDelegate: ViewDelegate?
	
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
			if let drawBehaviour = component.value as? Drawable {
				Application.sharedInstance.drawBehaviours.append(Weak(reference: drawBehaviour))
			}
		}
	}

	private func createRenderer() {
		// Create Renderer
		viewDelegate = ViewDelegate()
		
		// TODO: This will be a Display process
		// Set MTKViewDelegate to current Renderer instance
		View.main.delegate = viewDelegate
		
		// Only for the first time, should initiate the view manually
		viewDelegate?.mtkView(View.main, drawableSizeWillChange: View.main.drawableSize)
	}
}

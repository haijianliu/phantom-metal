// Copyright © haijian. All rights reserved.

// TODO: public?
public class Application {

	// TODO: no singleton
	static let sharedInstance: Application = Application()
	// TODO: initialize capacity.
	private init() {
		updateBehaviours.reserveCapacity(0xFF)
		renderBehaviours.reserveCapacity(0xFF)
	}

	// Delegate
	weak var delegate: ApplicationDelegate?

	var viewDelegate: ViewDelegate?

	/// The only game object references holder.
	private var gameObjects = [GameObject]()

	// TODO: clean up nil reference.
	/// A [contiguous array](http://jordansmith.io/on-performant-arrays-in-swift/) to update behaviour weak reference list in real time, reserving a capacity of 256 elements.
	var updateBehaviours = ContiguousArray<Weak<Updatable>>()
	/// A [contiguous array](http://jordansmith.io/on-performant-arrays-in-swift/) to update behaviours weak reference list in real time, reserving a capacity of 256 elements.
	var renderBehaviours = ContiguousArray<Weak<Renderable>>()

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
			if let renderBehaviour = component.value as? Renderable {
				Application.sharedInstance.renderBehaviours.append(Weak(reference: renderBehaviour))
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

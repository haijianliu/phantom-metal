// Copyright © haijian. All rights reserved.

/// A tag can be used to identify a game object.
/// A GameObject can only have one Tag assigned to it.
///
/// - untagged: default setting of a game object.
/// - mainCamera: main camera in the scene. The last GameObject set to mainCamera will set static Camera.main property, Others will active as untagged.
enum GameObjectTag {
	case untagged
	case mainCamera
}

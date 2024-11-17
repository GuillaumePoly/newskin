extends Node

var camera : RotatableCamera:
	get:
		if camera != null:
			return camera
		else:
			var cam = get_tree().get_first_node_in_group("rotatable_camera")
			if cam == null:
				printerr("no player found")
				return null
			camera = cam
			return camera

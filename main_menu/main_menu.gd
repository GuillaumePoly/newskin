extends Node3D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		LevelSwitcher.next_level(6.0, Vector3(0.0, 0.2, 0.0))

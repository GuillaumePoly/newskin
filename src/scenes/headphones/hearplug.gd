extends RigidBody3D
class_name Hearplug

var is_grabbed: bool = false:
	set(new_value):
		freeze = new_value
		is_grabbed = new_value

var initial_position_z: float

func _ready() -> void:
	initial_position_z = position.z

func _physics_process(delta: float) -> void:
	position.z = initial_position_z

func deactivate():
	freeze = true
	remove_from_group("grabbable")

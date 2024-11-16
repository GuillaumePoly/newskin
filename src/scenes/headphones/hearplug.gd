extends RigidBody3D
class_name Hearplug

var is_grabbed: bool = false

var initial_position_z: float

func _ready() -> void:
	initial_position_z = position.z

func _physics_process(delta: float) -> void:
	position.z = initial_position_z

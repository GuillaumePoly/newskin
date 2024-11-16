extends RigidBody3D


var initial_position_x: float

func _ready() -> void:
	initial_position_x = position.x

func _physics_process(delta: float) -> void:
	position.x = initial_position_x

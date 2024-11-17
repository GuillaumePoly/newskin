extends AnimatableBody3D
var followPath : PathFollow3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("fy")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = followPath.global_position.lerp(global_position, exp(1 * delta)) 
	#global_rotation_degrees = followPath.global_rotation_degrees.lerp(global_rotation_degrees, exp(1 * delta)) 

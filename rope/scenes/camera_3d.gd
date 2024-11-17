extends Camera3D
var cameraSwitch: bool
@export var EndCameraPosition : Vector3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if cameraSwitch :
		global_position = EndCameraPosition.lerp(global_position, exp(-.75 * delta))

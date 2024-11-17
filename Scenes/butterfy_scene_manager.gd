extends Node3D

class_name butterfy_scene_manager
static var counter: int
static var endpos: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

static func removeButt():
	if counter > 1:
		counter -=1
	else:	
		LevelSwitcher.next_level(5.0,endpos)
		

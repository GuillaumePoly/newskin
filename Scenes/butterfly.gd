extends AnimatableBody3D
var followPath : PathFollow3D
var canClick : bool
var speed : Vector3
var ray_length = 1000

@onready var animation_player: AnimationPlayer = $AnimationPlayer
const CLICK_VFX = preload("res://Scenes/click_vfx.tscn")
const GITTER_VFX = preload("res://Scenes/gitter_vfx.tscn")
@export var counter: int = 3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("Fy")
	animation_player.speed_scale = randf_range(0.9, 1.1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = followPath.global_position.lerp(global_position, exp(-1 * delta)) 
	global_rotation_degrees = followPath.global_rotation_degrees.lerp(global_rotation_degrees, exp(-1 * delta))
	
func _on_mouse_entered() -> void:
	canClick = true
	
func _on_mouse_exited() -> void:
	canClick = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		# Perform the raycast
		var camera = get_viewport().get_camera_3d()
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * ray_length
		var space = get_world_3d().direct_space_state
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = from
		ray_query.to = to
		var raycast_result = space.intersect_ray(ray_query)
		
		if !raycast_result.is_empty():
			# Spawn the VFX at the hit position
		
			
			if canClick:
				if counter > 0:
					counter -=1
					var vfx = CLICK_VFX.instantiate()
					get_tree().current_scene.add_child(vfx)
					vfx.global_position = raycast_result.position
				else:
					releaseButterfly()


func releaseButterfly() -> void:
	butterfy_scene_manager.endpos = global_position
	var pos = global_position
	var vfx = GITTER_VFX.instantiate()
	vfx.position = pos
	get_tree().current_scene.add_child(vfx)
	butterfy_scene_manager.removeButt()
	queue_free()

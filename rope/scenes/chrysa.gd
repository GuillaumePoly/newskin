extends RigidBody3D

var speed: Vector2
var canClick: bool
var pos: Vector3
var CLICK_VFX = load("res://rope/scenes/click_vfx.tscn")
var BUTTERFLY 
@onready var camera_3d: Camera3D = $"../Camera3D"
@onready var butterfly_sound: AudioStreamPlayer = $"../ButterflySound"

var ray_length = 1000

@export var counter: int = 3
@export var pathFollowArray : Array[PathFollow3D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CLICK_VFX = load("res://rope/scenes/click_vfx.tscn")
	BUTTERFLY = load("res://rope/scenes/butterfly.tscn")
	butterfy_scene_manager.counter = pathFollowArray.size()


func _on_mouse_entered() -> void:
	self.linear_velocity = Vector3(-speed.x * 0.001, 0, 0)
	canClick = true


func _on_mouse_exited() -> void:
	canClick = false


func _input(event):
	if event is InputEventMouseMotion:
		speed = Input.get_last_mouse_velocity()
		
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
			var vfx = CLICK_VFX.instantiate()
			self.add_child(vfx)
			vfx.global_position = raycast_result.position
			
			if canClick:
				$"../ChrysalideTapSound".play()
				if counter > 0:
					counter -=1
				else:
					releaseButterfly()
			

func releaseButterfly():
	camera_3d.cameraSwitch = true;
	for i in pathFollowArray.size() :
			var butter = BUTTERFLY.instantiate()
			butter.followPath = pathFollowArray[i]
			butter.position = self.global_position
			butter.butterflysound = butterfly_sound
			$"../ChrysaOpenPlayer".play()
			get_tree().current_scene.add_child(butter)
			queue_free()

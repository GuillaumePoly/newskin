extends RigidBody3D

var speed: Vector2
var canClick: bool
var pos: Vector3
const CLICK_VFX = preload("res://Scenes/click_vfx.tscn")
const BUTTERFLY = preload("res://Scenes/butterfly.tscn")
var ray_length = 1000

@export var counter: int = 3
@export var pathFollowArray : Array[PathFollow3D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_mouse_entered() -> void:
	self.linear_velocity = Vector3(-speed.x * 0.01, 0, 0)
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
			if canClick && counter >0:
				counter -=1
				self.add_child(vfx)
				vfx.global_position = raycast_result.position
			else:
				for i in 3 :
					var butter = BUTTERFLY.instantiate()
					butter.followPath = pathFollowArray[i]
					get_tree().current_scene.add_child(butter)
					butter.position = self.global_position
					queue_free()
				self.add_child(vfx)
				vfx.global_position = raycast_result.position
				
			
		
		

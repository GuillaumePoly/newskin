extends Node3D

@export var grab_distance: float = 20
var grabbed_object = null
var mouse = Vector2()
const DIST = 1000 #Ray Max distance



func _process(delta: float) -> void:
	if grabbed_object:
		var grab_pos_tmp = get_grab_position()
		grabbed_object.position = Vector3(grab_pos_tmp.x, grab_pos_tmp.y, grabbed_object.position.z)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse = event.position
	if event is InputEventMouseButton:
		if event.pressed == true and event.button_index == MOUSE_BUTTON_LEFT:
			get_mouse_world_pos(mouse)
			if is_instance_valid(grabbed_object):
				grabbed_object.is_grabbed = true
		elif event.pressed == false and event.button_index == MOUSE_BUTTON_LEFT:
			if is_instance_valid(grabbed_object):
				grabbed_object.is_grabbed = false
			grabbed_object = null

func get_mouse_world_pos(mouse:Vector2):
	#The physics state of the world
	var space = get_world_3d().direct_space_state
	#start and end world positions for the ray
	var start = get_viewport().get_camera_3d().project_ray_origin(mouse)
	var end = get_viewport().get_camera_3d().project_position(mouse,DIST)
	#Params for 3D raycast
	#Alt var params = PhysicsRayQueryParameters3D.create(start,end)
	var params = PhysicsRayQueryParameters3D.new()
	params.from = start
	params.to = end
	#cast the ray using the space and return the results as a Dictionary
	var result = space.intersect_ray(params)
	if result.is_empty() == false:
		if result.collider is Hearplug:
			grabbed_object = result.collider

#Get the position in the world you want to object to follow
func get_grab_position():
	return get_viewport().get_camera_3d().project_position(mouse,grab_distance)

extends Node3D


@onready var hearplug_left: Hearplug = $HearplugLeft
@onready var hearplug_right: Hearplug = $HearplugRight

@export var fade_duration: float = 5.0


@export var grab_distance: float = 20
var grabbed_object = null
var mouse = Vector2()
const DIST = 1000 #Ray Max distance

var _initial_x_position_hearplug: float
var _initial_y_position_hearplug: float

var current_pan: float = 0.0
var current_db: float = -20.0
var number_of_hearplugs_arrived: int = 0

func _ready() -> void:
	LevelSwitcher.tween_fade_out(fade_duration)
	init_scale_objects(fade_duration-2.0)
	hearplug_left.hearplug_on_zone.connect(_on_hearplug_on_zone.bind(hearplug_left))
	hearplug_right.hearplug_on_zone.connect(_on_hearplug_on_zone.bind(hearplug_right))
	hearplug_left.hearplug_lost.connect(_on_hearplug_lost)
	hearplug_right.hearplug_lost.connect(_on_hearplug_lost)
	
	_initial_x_position_hearplug = hearplug_right.position.x
	_initial_y_position_hearplug = hearplug_right.position.y

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
		var tmp_collider = result.collider
		if tmp_collider is Hearplug and tmp_collider.is_in_group("grabbable"):
			grabbed_object = result.collider
		if tmp_collider.is_in_group("button3d"):
			tmp_collider.owner.press()
		print(tmp_collider)

#Get the position in the world you want to object to follow
func get_grab_position():
	return get_viewport().get_camera_3d().project_position(mouse,grab_distance)


func _on_hearplug_on_zone(hearplug: Hearplug):
	number_of_hearplugs_arrived += 1
	if hearplug.name.contains("Left"):
		current_pan = - 1.0
	elif hearplug.name.contains("Right"):
		current_pan = 1.0
	
	if number_of_hearplugs_arrived == 2:
		HeadphonesStreamPlayer.tween_pan_property(0.0, 3.0)
		HeadphonesStreamPlayer.activate_high_filter(false)
		await get_tree().create_timer(3.0).timeout
		LevelSwitcher.next_level(5.0)
	elif number_of_hearplugs_arrived == 1:
		current_db += 3.0
		HeadphonesStreamPlayer.tween_db_property(current_db, 3.0)


func _on_hearplug_lost():
	get_tree().get_nodes_in_group("button3d")[0].owner.appear()

func init_scale_objects(wait_time: float):
	var scale_objects = get_tree().get_nodes_in_group("scale_objects")
	for scale_object: Node3D in scale_objects:
		scale_object.scale = Vector3(0.0, 0.0, 0.0)
	await get_tree().create_timer(wait_time).timeout
	
	for scale_object: Node3D in scale_objects:
		var tween: Tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(scale_object, "scale", Vector3.ONE, 0.7)
		await get_tree().create_timer(0.1).timeout

extends Node3D

var camera_sensitivity: float = 0.01
var camera_target: Vector3 = Vector3.ZERO
var mouse_button_pressed_at_previous_frame: bool = false
var previous_mouse_position := Vector2.ZERO

var camera_radius: float = 5.0
var longitude: float = 0.0  # Initial longitude in radians
var latitude: float = PI / 3  # Initial latitude in radians

var min_latitude: float = PI / 8  # Minimum latitude
var max_latitude: float = 1.5 / 2  # Maximum latitude (~80 degrees)


func _ready() -> void:
	rotate_camera(longitude, latitude)


func _process(_delta: float):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var current_mouse_position: Vector2 = get_viewport().get_mouse_position()
		if not mouse_button_pressed_at_previous_frame:
			mouse_button_pressed_at_previous_frame = true
			previous_mouse_position = current_mouse_position
		else:
			var camera_displacement: Vector2 = current_mouse_position - previous_mouse_position
			longitude += camera_displacement.x * camera_sensitivity
			latitude = clamp(latitude - camera_displacement.y * camera_sensitivity, min_latitude, max_latitude)
			rotate_camera(longitude, latitude)
			previous_mouse_position = current_mouse_position
	else:
		mouse_button_pressed_at_previous_frame = false


func rotate_camera(new_longitude: float, new_latitude):
	var x = camera_radius * cos(latitude) * cos(longitude)
	var y = camera_radius * sin(latitude)
	var z = - camera_radius * cos(latitude) * sin(longitude)
	
	global_position = Vector3(x, y, z)
	look_at(camera_target)

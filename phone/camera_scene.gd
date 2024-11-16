extends Camera3D
class_name RotatableCamera

@export var camera_radius: float = 10.0
@export var camera_target: Vector3 = Vector3.ZERO

var enable_rotation := true

var camera_sensitivity: float = 0.1
var camera_start_fov: float = 30.0
var mouse_button_pressed_at_previous_frame: bool = false
var previous_mouse_position: Vector2

var longitude: float = 0.0  # Initial longitude in radians
var latitude: float = PI / 3  # Initial latitude in radians

## Boundaries to camera rotation
var min_latitude: float = PI / 8
var max_latitude: float = (PI / 2) - 0.01
var min_longitude: float = - PI / 3
var max_longitude: float = PI / 3


func _ready() -> void:
	camera_start_fov = fov


func _process(delta: float):
	if !enable_rotation:
		return
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var current_mouse_position: Vector2 = get_viewport().get_mouse_position()
		if not mouse_button_pressed_at_previous_frame:
			mouse_button_pressed_at_previous_frame = true
			previous_mouse_position = current_mouse_position
		else:
			var camera_displacement: Vector2 = (current_mouse_position - previous_mouse_position) * delta
			longitude = clamp(longitude + camera_displacement.x * camera_sensitivity, min_longitude, max_longitude)
			latitude = clamp(latitude - camera_displacement.y * camera_sensitivity, min_latitude, max_latitude)
			previous_mouse_position = current_mouse_position
	else:
		mouse_button_pressed_at_previous_frame = false
	
	rotate_camera(delta)


func rotate_camera(delta : float):
	var x: float = camera_radius * cos(latitude) * cos(longitude)
	var y: float = camera_radius * sin(latitude)
	var z: float = - camera_radius * cos(latitude) * sin(longitude)
	
	global_position = Vector3(x, y, z).lerp(global_position, exp(-5.0 * delta))
	look_at(camera_target)

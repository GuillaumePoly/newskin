extends Node

@export var levels : Array[PackedScene]

var current_level : PackedScene
var changing_scene := false

@onready var fade_effect: ShaderMaterial = $FadeEffect.material

signal scene_finished_loading


func _ready() -> void:
	for level in levels:
		if level.resource_path == get_tree().current_scene.scene_file_path:
			current_level = level
			await get_tree().process_frame
			scene_finished_loading.emit()
			break

## focus point is a point in world space that the circle will focus for the transistion
func next_level(transition_duration : float = 2.0, focus_point : Vector3 = Vector3.ZERO):
	if changing_scene:
		return
	
	var next_scene_index := levels.find(current_level) + 1
	if levels.size() <= next_scene_index:
		printerr("no next scene")
		return
	else:
		changing_scene = true
	
	var screen_point := get_viewport().get_camera_3d().unproject_position(focus_point)
	print(Vector2(screen_point)/Vector2(get_viewport().size))
	fade_effect.set_shader_parameter("focus_coord", Vector2(screen_point)/Vector2(get_viewport().size))
	
	var tween_in := create_tween()
	tween_in.tween_method(_tween_fade, 1.0, 0.0, transition_duration/2.0)
	await tween_in.finished
	current_level = levels[next_scene_index]
	get_tree().change_scene_to_packed(current_level)
	
	tween_fade_out(transition_duration/2.0)


func _tween_fade(progress : float):
	fade_effect.set_shader_parameter("fade", progress)

func tween_fade_out(duration: float):
	var tween_out := create_tween()
	tween_out.tween_method(_tween_fade, 0.0, 1.0, duration)
	tween_out.tween_callback(func(): scene_finished_loading.emit())

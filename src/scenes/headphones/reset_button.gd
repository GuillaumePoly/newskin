extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_pressed: bool = false
var is_appeared: bool = false

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)

func press():
	if is_pressed == false and is_appeared == true:
		is_pressed = true
		animation_player.play("press")


func appear():
	if is_appeared == false:
		is_appeared = true
		animation_player.play("appear")

func _on_animation_finished(anim_name: String):
	if anim_name == "press":
		is_pressed = false
		get_tree().reload_current_scene()

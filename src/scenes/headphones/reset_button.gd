extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_pressed: bool = false

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)

func press():
	if is_pressed == false:
		is_pressed = true
		animation_player.play("press")
		print("presssss")

func _on_animation_finished(anim_name: String):
	if anim_name == "press":
		is_pressed = false
		get_tree().reload_current_scene()

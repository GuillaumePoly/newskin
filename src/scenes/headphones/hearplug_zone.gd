extends Node3D
class_name HearplugZone

@onready var inner_area: Area3D = $InnerArea
@onready var outer_area: Area3D = $OuterArea

@export var headphones_stream_player: HeadphonesStreamPlayer

var is_zone_active: bool = true

func _ready() -> void:
	inner_area.body_entered.connect(_on_hearplug_body_entered.bind(inner_area))
	inner_area.body_exited.connect(_on_hearplug_body_exited.bind(inner_area))
	outer_area.body_entered.connect(_on_hearplug_body_entered.bind(outer_area))
	outer_area.body_exited.connect(_on_hearplug_body_exited.bind(outer_area))

func _on_hearplug_body_entered(body: Node3D, area: Area3D):
	if is_zone_active == true:
		if body is Hearplug:
			if area.name.begins_with("Inner"):
				body.inner_area = self
			if area.name.begins_with("Outer"):
				print("Body entered in outer zone")
				update_audio(true)

func _on_hearplug_body_exited(body: Node3D, area: Area3D):
	if is_zone_active == true:
		if body is Hearplug:
			if area.name.begins_with("Inner"):
				print("Body exited from Inner zone")
				body.inner_area = null
			if area.name.begins_with("Outer"):
				print("Body exited from outer zone")
				update_audio(false)

func update_audio(in_outer_zone: bool):
	if in_outer_zone:
		headphones_stream_player.tween_db_property(0.0, 1.0)
		if name.contains("Left"):
			headphones_stream_player.tween_pan_property(-1.0, 1.0)
		elif name.contains("Right"):
			headphones_stream_player.tween_pan_property(1.0, 1.0)
	else:
		headphones_stream_player.tween_db_property(-10.0, 1.0)
		headphones_stream_player.tween_pan_property(0.0, 1.0)
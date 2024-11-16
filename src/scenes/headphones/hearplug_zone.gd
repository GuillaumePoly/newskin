extends Node3D
class_name HearplugZone

signal hearplug_on_zone

@onready var inner_area: Area3D = $InnerArea
@onready var outer_area: Area3D = $OuterArea

var is_zone_active: bool = true

func _ready() -> void:
	inner_area.body_entered.connect(_on_hearplug_body_entered.bind(inner_area.name))
	inner_area.body_exited.connect(_on_hearplug_body_exited.bind(inner_area.name))
	outer_area.body_entered.connect(_on_hearplug_body_entered.bind(outer_area.name))
	outer_area.body_exited.connect(_on_hearplug_body_exited.bind(outer_area.name))

func _on_hearplug_body_entered(body: Node3D, area_name: String):
	if is_zone_active == true:
		if body is Hearplug:
			if area_name.begins_with("Inner") and body.is_grabbed == false:
				print("Body dropped in Inner zone")
				body.deactivate()
				is_zone_active = false
				tween_position(body, 0.5)
			elif area_name.begins_with("Outer"):
				print("Body entered in outer zone")

func _on_hearplug_body_exited(body: Node3D, area_name: String):
	if is_zone_active == true:
		if body is Hearplug:
			if area_name.begins_with("Inner"):
				print("Body exited from Inner zone")
			elif area_name.begins_with("Outer"):
				print("Body exited from outer zone")


func tween_position(object: Node3D, duration: float):
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(object, "global_position", global_position, duration)
	tween.tween_callback(func(): hearplug_on_zone.emit())

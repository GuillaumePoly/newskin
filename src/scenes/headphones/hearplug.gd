extends RigidBody3D
class_name Hearplug

signal hearplug_on_zone
signal hearplug_lost

var is_grabbed: bool = false:
	set(new_value):
		gravity_scale = 0.0 if new_value else 1.0
		if new_value == false and new_value != is_grabbed:
			if is_on_area_inner:
				print("Body dropped in Inner zone")
				tween_position(self, 0.5)
				var _rotation_plugged: Vector3
				if name.contains("Left"):
					tween_rotation_property(self, 3.0, Vector3(0.0, 180, 0.0))
				else:
					tween_rotation_property(self, 3.0, Vector3(0.0, -200, 0.0))
		if new_value:
			tween_rotation_property(self, 0.75)
		is_grabbed = new_value

var is_on_area_inner: bool = false:
	set(new_value):
		is_on_area_inner = new_value

var inner_area: HearplugZone = null:
	set(new_value):
		if new_value != null:
			is_on_area_inner = true
		else:
			is_on_area_inner = false
		inner_area = new_value

var initial_position_z: float

var is_plugged: bool = false
var check_position_y: bool = true
var tween_rotation: Tween

func _ready() -> void:
	initial_position_z = position.z


func _physics_process(delta: float) -> void:
	position.z = initial_position_z
	if check_position_y and position.y < -10.0:
		check_position_y = false
		hearplug_lost.emit()


func deactivate():
	freeze = true
	remove_from_group("grabbable")



func tween_position(object: Node3D, duration: float):
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(object, "global_position", inner_area.global_position, duration)
	tween.tween_callback(func(): hearplug_on_zone.emit())
	tween.tween_callback(func(): deactivate())
	

	inner_area.is_zone_active = false
	is_plugged = true

func tween_rotation_property(object: Node3D, duration: float, _rotation: Vector3 = Vector3(0.0, 0.0, 0.0)):
	if tween_rotation != null:
		tween_rotation.kill()
	tween_rotation = null
	tween_rotation = create_tween()
	
	tween_rotation.set_ease(Tween.EASE_OUT)
	tween_rotation.set_trans(Tween.TRANS_CUBIC)
	tween_rotation.tween_property(object, "rotation", _rotation, duration)

extends AudioStreamPlayer
class_name HeadphonesStreamPlayer

@export var duration_trans_time: float = 0.5

var tween_pan: Tween
var tween_db: Tween

var panner_effect: AudioEffectPanner

func _ready() -> void:
	panner_effect =	get_panner_bus("Headphones")
	assert(panner_effect != null)
	print(panner_effect)
	print(panner_effect.pan)
	tween_pan = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_db = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func tween_pan_property(to: float, duration: float = duration_trans_time):
	if tween_pan.is_running(): tween_pan.kill()
	tween_pan.tween_property(panner_effect, "pan", to, duration)

func tween_db_property(to: float, duration: float = duration_trans_time):
	if tween_db.is_running(): tween_db.kill()
	tween_db.tween_property(self, "volume_db", to, duration)


func get_panner_bus(bus_name: String = "Headphones"):
	var bus_idx = AudioServer.get_bus_index(bus_name)
	for effect_idx in AudioServer.get_bus_effect_count(bus_idx):
		var effect = AudioServer.get_bus_effect(bus_idx, effect_idx)
		if effect is AudioEffectPanner:
			return effect
		else:
			return null
	return null

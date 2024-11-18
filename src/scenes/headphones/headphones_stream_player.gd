extends AudioStreamPlayer

@export var duration_trans_time: float = 0.5

var tween_pan: Tween
var tween_db: Tween
var tween_cuthz: Tween

var panner_effect: AudioEffectPanner
var high_pass_effect: AudioEffectFilter

func _ready() -> void:
	panner_effect =	get_panner_bus("Headphones")
	high_pass_effect = get_high_pass_bus("Headphones")
	assert(panner_effect != null and high_pass_effect != null)




func tween_pan_property(to: float, duration: float = duration_trans_time):
	if tween_pan != null:
		tween_pan.kill()
	tween_pan = null
	tween_pan = create_tween()

	tween_pan.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_pan.tween_property(panner_effect, "pan", to, duration)

func tween_db_property(to: float, duration: float = duration_trans_time):
	if tween_db != null:
		tween_db.kill()
	tween_db = null
	tween_db = create_tween()

	tween_db.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_db.tween_property(self, "volume_db", to, duration)

func tween_cutoffhz_property(to: float, duration: float = duration_trans_time):
	if tween_cuthz != null:
		tween_cuthz.kill()
	tween_cuthz = null
	tween_cuthz = create_tween()

	tween_cuthz.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_cuthz.tween_property(high_pass_effect, "cutoff_hz", to, duration)
	tween_cuthz.tween_callback(func(): AudioServer.set_bus_effect_enabled(1, 1, false))

func get_panner_bus(bus_name: String = "Headphones"):
	var bus_idx = AudioServer.get_bus_index(bus_name)
	for effect_idx in AudioServer.get_bus_effect_count(bus_idx):
		var effect = AudioServer.get_bus_effect(bus_idx, effect_idx)
		if effect is AudioEffectPanner:
			return effect
	return null

func get_high_pass_bus(bus_name: String = "Headphones"):
	var bus_idx = AudioServer.get_bus_index(bus_name)
	for effect_idx in AudioServer.get_bus_effect_count(bus_idx):
		var effect = AudioServer.get_bus_effect(bus_idx, effect_idx)
		if effect is AudioEffectHighPassFilter:
			return effect
	return null

func activate_high_filter(activate: bool):
	if activate == false:
		tween_cutoffhz_property(0.0, 5.0)
		tween_db_property(-30.0, 5.0)


func _play_sound_eff_random(_stream: AudioStream):
	var new_player: AudioStreamPlayer = AudioStreamPlayer.new()
	var random_player: AudioStreamRandomizer = AudioStreamRandomizer.new()
	random_player.add_stream(0, _stream)
	random_player.random_pitch = 1.2
	
	new_player.stream = random_player
	
	new_player.finished.connect(_on_pop_player_finished.bind(new_player))
	new_player.bus = "VFX"
	new_player.volume_db = -10.0
	get_tree().current_scene.add_child(new_player)
	new_player.play()

func _on_pop_player_finished(player: AudioStreamPlayer):
	player.queue_free()

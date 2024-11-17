extends Node3D
class_name Flower

class Petal:
	var rigidbody : RigidBody3D
	var material : ShaderMaterial
	
	func _init(_rigidbody : RigidBody3D, _material : ShaderMaterial) -> void:
		rigidbody = _rigidbody
		material = _material

var petal_amount := 0

var last_petal_selected : Petal
var grabbed_petal : Petal
var petals_fallen : Array[Petal]

var deform := Vector2.ZERO

signal petal_fallen


func _ready() -> void:
	#await LevelSwitcher.scene_finished_loading
	
	initialize()


func initialize() -> void:
	visible = true
	
	for child in get_children():
		if child is MeshInstance3D:
			if !child.name.contains("petals"):
				continue
			child.global_scale(Vector3.ZERO)
	
	global_scale(Vector3.ZERO)
	var tween_flower_scale := create_tween()
	tween_flower_scale.set_trans(Tween.TRANS_BACK)
	tween_flower_scale.tween_property(self, "scale", Vector3.ONE, 1.0)
	await tween_flower_scale.finished
	
	for child in get_children():
		if child is MeshInstance3D:
			if !child.name.contains("petals"):
				continue
			
			var tween := create_tween()
			tween.set_trans(Tween.TRANS_BACK)
			tween.tween_property(child, "scale", Vector3.ONE, 0.4)
			await get_tree().create_timer(0.1).timeout
			
			petal_amount += 1
			(child as MeshInstance3D).set_surface_override_material(0, child.get_active_material(0).duplicate())
			
			var petal_rb := RigidBody3D.new()
			add_child(petal_rb)
			petal_rb.global_position = child.global_position
			petal_rb.set_collision_layer_value(1, true)
			petal_rb.set_collision_layer_value(2, false)
			petal_rb.set_collision_mask_value(1, false)
			petal_rb.set_collision_mask_value(2, true)
			petal_rb.freeze = true
			petal_rb.mass = 0.005
			petal_rb.gravity_scale = 0.75
			petal_rb.continuous_cd = true
			petal_rb.angular_damp = 10.0
			child.reparent(petal_rb)
			
			var col_shape := CollisionShape3D.new()

			(child as MeshInstance3D).create_convex_collision(false)
			col_shape.shape = (child.get_child(0).get_child(0) as CollisionShape3D).shape.duplicate()
			child.get_child(0).queue_free()
			
			petal_rb.add_child(col_shape)
			col_shape.global_position = petal_rb.global_position
			
			var petal := Petal.new(petal_rb, (child as MeshInstance3D).get_surface_override_material(0))
			
			petal_rb.mouse_entered.connect(_on_petal_mouse_entered.bind(petal))
			petal_rb.mouse_exited.connect(_on_petal_mouse_exited.bind(petal))


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("click"):
		if last_petal_selected != null:
			GameManager.camera.enable_rotation = false
			grabbed_petal = last_petal_selected
			grabbed_petal.material.set_shader_parameter("grab_mouse_position", Vector2(get_viewport().get_mouse_position()) / Vector2(get_viewport().size))
	if Input.is_action_just_released("click"):
		GameManager.camera.enable_rotation = true
		
		if grabbed_petal != null:
			var tween := create_tween()
			tween.set_trans(Tween.TRANS_BACK)
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_method(
				_update_camera_anticipation,
				 GameManager.camera.camera_start_fov - GameManager.camera.fov,
				 0.0,
				 0.5
				)
			tween.parallel()
			tween.set_trans(Tween.TRANS_ELASTIC)
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_method(_tween_deform_parameter.bind(grabbed_petal), deform, Vector2.ZERO, 0.75)
			deform = Vector2.ZERO
			grabbed_petal.material.set_shader_parameter("emission", Color.BLACK)
			grabbed_petal = null
	
	if event is InputEventMouseMotion && last_petal_selected != null && grabbed_petal == null:
		last_petal_selected.material.set_shader_parameter("grab_mouse_position", Vector2(event.position) / Vector2(get_viewport().size))
	
	if event is InputEventMouseMotion && grabbed_petal != null:
		deform += Vector2(event.relative.x, -event.relative.y) / Vector2(get_viewport().size) * 0.1
		grabbed_petal.material.set_shader_parameter("deform", deform)
		_update_camera_anticipation(deform.length() * 50.0)
		
		if deform.length() > 0.03:
			var tween := create_tween()
			tween.set_trans(Tween.TRANS_ELASTIC)
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_method(
				_update_camera_anticipation,
				 GameManager.camera.camera_start_fov - GameManager.camera.fov,
				 0.0,
				 0.5
				)
			tween.parallel()
			tween.set_trans(Tween.TRANS_BOUNCE)
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_method(_tween_deform_parameter.bind(grabbed_petal), deform, Vector2.ZERO, 0.75)
			deform = Vector2.ZERO
			grabbed_petal.rigidbody.freeze = false
			
			var camera = get_viewport().get_camera_3d()
			var origin = camera.project_ray_origin(event.position);
			var direction = camera.project_ray_normal(event.position);
			var plane = Plane(0.0, 1.0, 0.0, grabbed_petal.rigidbody.global_position.y);
			var point = plane.intersects_ray(origin, direction);
			var delta : Vector3 = (grabbed_petal.rigidbody.global_position - Vector3.UP * 0.1) - point
			
			grabbed_petal.rigidbody.apply_central_impulse( -delta * Vector3(1.0, 5.0, 1.0) * 0.01 )
			if petals_fallen.find(grabbed_petal) == -1:
				petals_fallen.append(grabbed_petal)
			petal_fallen.emit()
			grabbed_petal.material.set_shader_parameter("emission", Color.BLACK)
			grabbed_petal = null


func _update_camera_anticipation(value : float):
	GameManager.camera.fov = GameManager.camera.camera_start_fov - value


func _tween_deform_parameter(progress : Vector2, petal : Petal):
	petal.material.set_shader_parameter("deform", progress)


func _on_petal_mouse_entered(petal : Petal):
	last_petal_selected = petal
	if grabbed_petal == null:
		petal.material.set_shader_parameter("emission", Color("#7F3636"))


func _on_petal_mouse_exited(petal : Petal):
	last_petal_selected = null
	if grabbed_petal == null:
		petal.material.set_shader_parameter("emission", Color.BLACK)

extends Node3D

class Petal:
	var rigidbody : RigidBody3D
	var material : ShaderMaterial
	
	func _init(_rigidbody : RigidBody3D, _material : ShaderMaterial) -> void:
		rigidbody = _rigidbody
		material = _material

var last_petal_selected : Petal
var grabbed_petal : Petal
var petals_fallen : Array[Petal]

var deform := Vector2.ZERO

func _ready() -> void:
	for child in get_children():
		if child is MeshInstance3D && child.name.contains("petals"):
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
			tween.set_trans(Tween.TRANS_ELASTIC)
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_method(_tween_deform_parameter.bind(grabbed_petal), deform, Vector2.ZERO, 0.75)
			deform = Vector2.ZERO
			grabbed_petal = null
	
	if event is InputEventMouseMotion && last_petal_selected != null && grabbed_petal == null:
		last_petal_selected.material.set_shader_parameter("grab_mouse_position", Vector2(event.position) / Vector2(get_viewport().size))
	
	if event is InputEventMouseMotion && grabbed_petal != null:
		deform += Vector2(event.relative.x, -event.relative.y) / Vector2(get_viewport().size) * 0.1
		grabbed_petal.material.set_shader_parameter("deform", deform)
		
		if deform.length() > 0.03:
			var tween := create_tween()
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
			petals_fallen.append(grabbed_petal)
			grabbed_petal = null


func _tween_deform_parameter(progress : Vector2, petal : Petal):
	petal.material.set_shader_parameter("deform", progress)


func _on_petal_mouse_entered(petal : Petal):
	last_petal_selected = petal
	petal.material.set_shader_parameter("emission", Color("#7F3636"))


func _on_petal_mouse_exited(petal : Petal):
	last_petal_selected = null
	petal.material.set_shader_parameter("emission", Color.BLACK)

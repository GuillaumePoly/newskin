extends Node3D

class Petal:
	var area : Area3D
	var material : ShaderMaterial
	var linear_velocity := Vector3.ZERO
	var angular_velocity := Vector3.ZERO
	
	func _init(_area : Area3D, _material : ShaderMaterial) -> void:
		area = _area
		material = _material

var last_petal_selected : Petal
var grabbed_petal : Petal
var petals_fallen : Array[Petal]

var deform := Vector2.ZERO

func _ready() -> void:
	for child in get_children():
		if child is MeshInstance3D && child.name.contains("petals"):
			(child as MeshInstance3D).set_surface_override_material(0, child.get_active_material(0).duplicate())
			
			var petal_area := Area3D.new()
			add_child(petal_area)
			petal_area.global_position = child.global_position
			#petal_area.set_collision_layer_value(1, false)
			petal_area.set_collision_mask_value(1, false)
			child.reparent(petal_area)
			
			var col_shape := CollisionShape3D.new()
			col_shape.shape = ConcavePolygonShape3D.new()
			col_shape.shape.set_faces(child.mesh.get_faces())
			
			petal_area.add_child(col_shape)
			col_shape.global_position = petal_area.global_position
			
			var petal := Petal.new(petal_area, (child as MeshInstance3D).get_surface_override_material(0))
			
			petal_area.mouse_entered.connect(_on_petal_mouse_entered.bind(petal))
			petal_area.mouse_exited.connect(_on_petal_mouse_exited.bind(petal))


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("click"):
		if last_petal_selected != null:
			grabbed_petal = last_petal_selected
			grabbed_petal.material.set_shader_parameter("grab_mouse_position", Vector2(get_viewport().get_mouse_position()) / Vector2(get_viewport().size))
	if Input.is_action_just_released("click") && grabbed_petal != null:
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_ELASTIC)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_method(_tween_deform_parameter.bind(grabbed_petal), deform, Vector2.ZERO, 0.5)
		deform = Vector2.ZERO
		grabbed_petal = null
	
	if event is InputEventMouseMotion && grabbed_petal != null:
		deform += Vector2(event.relative.x, -event.relative.y) / Vector2(get_viewport().size) * 0.1
		grabbed_petal.material.set_shader_parameter("deform", deform)
		
		if deform.length() > 0.03:
			var tween := create_tween()
			tween.set_trans(Tween.TRANS_ELASTIC)
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_method(_tween_deform_parameter.bind(grabbed_petal), deform, Vector2.ZERO, 0.5)
			deform = Vector2.ZERO
			grabbed_petal.linear_velocity = (grabbed_petal.area.global_position - global_position) * Vector3(20.0, 10.0, 20.0)
			grabbed_petal.angular_velocity = Vector3(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0, randf() * 2.0 - 1.0)
			petals_fallen.append(grabbed_petal)
			grabbed_petal = null


func _tween_deform_parameter(progress : Vector2, petal : Petal):
	petal.material.set_shader_parameter("deform", progress)


func _physics_process(delta: float) -> void:
	for petal in petals_fallen:
		petal.linear_velocity += Vector3.DOWN * delta * 9.81
		petal.area.global_position += petal.linear_velocity * delta * 0.1
		
		petal.area.global_rotation += petal.angular_velocity * delta


func _on_petal_mouse_entered(petal : Petal):
	last_petal_selected = petal
	petal.material.set_shader_parameter("emission", Color.DARK_SLATE_GRAY)


func _on_petal_mouse_exited(petal : Petal):
	last_petal_selected = null
	petal.material.set_shader_parameter("emission", Color.BLACK)

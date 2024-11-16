extends Node3D

var last_petal_selected : Node3D
var petal_fallen : Array[Node3D]

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
			
			petal_area.mouse_entered.connect(_on_petal_mouse_entered.bind(petal_area))
			petal_area.mouse_exited.connect(_on_petal_mouse_exited.bind(petal_area))


func _input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		print(last_petal_selected)
		if last_petal_selected != null:
			petal_fallen.append(last_petal_selected)


func _physics_process(delta: float) -> void:
	for petal in petal_fallen:
		petal.global_position += delta * Vector3.DOWN


func _on_petal_mouse_entered(petal : Node3D):
	last_petal_selected = petal
	((petal.get_child(0) as MeshInstance3D).get_surface_override_material(0) as StandardMaterial3D).emission = Color.GRAY


func _on_petal_mouse_exited(petal : Node3D):
	last_petal_selected = null
	((petal.get_child(0) as MeshInstance3D).get_surface_override_material(0) as StandardMaterial3D).emission = Color.BLACK
	

extends MeshInstance3D

const HAIR = preload("res://Scenes/hair.tscn")
func _ready() -> void:
	var mdt = MeshDataTool.new()
	var mesh_instance = self
	var mesh = mesh_instance.mesh

	if mesh.get_surface_count() > 0:
		mdt.create_from_surface(mesh, 0)
		for vtx in mdt.get_vertex_count():
			if(vtx%3==0):
					print(mdt.get_vertex_color(vtx))
					var vert = mdt.get_vertex(vtx)
					var vertNorma: Vector3 = mdt.get_vertex_normal(vtx)
					var vertexPos = mesh_instance.global_transform * vert
					var h = HAIR.instantiate()
					self.add_child(h)
					
					h.global_position = vertexPos
					h.global_scale(Vector3.ONE *10)
		mdt.clear()
	else:
		print("No surfaces found in the mesh.")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

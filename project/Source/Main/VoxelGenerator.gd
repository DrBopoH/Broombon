class_name VoxelGenerator, "res://Source/Assets/Textures/Blocks/stone.png"
extends Reference

static func create_textured_cube(size: Vector3, texture: Texture, pixelize: bool = false) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var material = SpatialMaterial.new()
	if texture:
		material.albedo_texture = texture
		material.params_use_alpha_scissor = pixelize 
	
	st.set_material(material)
	
	var h = size / 2.0 
	
	#(Z+)
	_add_quad(st, Vector3(-h.x, -h.y, h.z), Vector3(h.x, -h.y, h.z), Vector3(h.x, h.y, h.z), Vector3(-h.x, h.y, h.z), Vector3(0, 0, 1))
	#(Z-)
	_add_quad(st, Vector3(h.x, -h.y, -h.z), Vector3(-h.x, -h.y, -h.z), Vector3(-h.x, h.y, -h.z), Vector3(h.x, h.y, -h.z), Vector3(0, 0, -1))
	#(X-)
	_add_quad(st, Vector3(-h.x, -h.y, -h.z), Vector3(-h.x, -h.y, h.z), Vector3(-h.x, h.y, h.z), Vector3(-h.x, h.y, -h.z), Vector3(-1, 0, 0))
	#(X+)
	_add_quad(st, Vector3(h.x, -h.y, h.z), Vector3(h.x, -h.y, -h.z), Vector3(h.x, h.y, -h.z), Vector3(h.x, h.y, h.z), Vector3(1, 0, 0))
	#(Y+)
	_add_quad(st, Vector3(-h.x, h.y, h.z), Vector3(h.x, h.y, h.z), Vector3(h.x, h.y, -h.z), Vector3(-h.x, h.y, -h.z), Vector3(0, 1, 0))
	#(Y-)
	_add_quad(st, Vector3(-h.x, -h.y, -h.z), Vector3(h.x, -h.y, -h.z), Vector3(h.x, -h.y, h.z), Vector3(-h.x, -h.y, h.z), Vector3(0, -1, 0))
	
	st.generate_tangents()
	return st.commit()


static func _add_quad(st: SurfaceTool, p1: Vector3, p2: Vector3, p3: Vector3, p4: Vector3, normal: Vector3):
	st.add_normal(normal); st.add_uv(Vector2(0, 1)); st.add_vertex(p4)
	st.add_normal(normal); st.add_uv(Vector2(1, 1)); st.add_vertex(p3)
	st.add_normal(normal); st.add_uv(Vector2(0, 0)); st.add_vertex(p1)
	
	st.add_normal(normal); st.add_uv(Vector2(1, 1)); st.add_vertex(p3)
	st.add_normal(normal); st.add_uv(Vector2(1, 0)); st.add_vertex(p2)
	st.add_normal(normal); st.add_uv(Vector2(0, 0)); st.add_vertex(p1)

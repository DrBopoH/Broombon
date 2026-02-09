class_name Chunk
extends StaticBody

const CHUNK_SIZE: int = 16
var data: Dictionary

var material_instance: ShaderMaterial
var texture_paths: Array = [
	"res://Source/Assets/Textures/Blocks/dirt.png",
	"res://Source/Assets/Textures/Blocks/grass_carried.png",
	"res://Source/Assets/Textures/Blocks/grass_side_carried.png",
	"res://Source/Assets/Textures/Blocks/stone.png",
	"res://Source/Assets/Textures/Blocks/gravel.png"
]

func _ready():
	material_instance = ShaderMaterial.new()
	material_instance.shader = load("res://Source/Assets/Data/VoxelShader.shader") # Укажи путь к шейдеру выше!
	
	var tex_arr = _create_texture_array(texture_paths)
	material_instance.set_shader_param("texture_array", tex_arr)
	
	_generate_random_data()
	_build_mesh()

# Эта функция читает файлы и делает из них массив для видеокарты
func _create_texture_array(paths: Array) -> TextureArray:
	if paths.empty(): return null
	
	var first_img = load(paths[0]).get_data()
	var width = first_img.get_width()
	var height = first_img.get_height()
	
	var tex_arr = TextureArray.new()
	tex_arr.create(width, height, paths.size(), first_img.get_format(), Texture.FLAG_MIPMAPS)
	
	for i in range(paths.size()):
		var tex = load(paths[i])
		if tex:
			var img = tex.get_data()
			# Важно: если текстуры разных размеров, игра упадет. Тут нужна проверка в реальном проекте.
			if img.get_width() != width or img.get_height() != height:
				push_error("Texture size mismatch: " + paths[i])
				img.resize(width, height) # Аварийный ресайз
			
			tex_arr.set_layer_data(img, i)
	
	return tex_arr

func _generate_random_data():
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.period = 10
	
	for x in range(CHUNK_SIZE):
		for z in range(CHUNK_SIZE):
			var height = int((noise.get_noise_2d(x, z) + 1.0) * 4.0)
			for y in range(height + 1):
				# Логика блоков (ID теперь просто индекс в массиве путей)
				# Допустим: 0 - земля, 1 - трава_верх, 2 - трава_бок, 3 - камень
				if y == height:
					data[Vector3(x, y, z)] = 1 # Трава (верх) - пока упрощенно
				elif y > height - 3:
					data[Vector3(x, y, z)] = 0 # Земля
				else:
					data[Vector3(x, y, z)] = 3 # Камень

func _build_mesh():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(material_instance) # Ставим наш шейдерный материал
	
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			for z in range(CHUNK_SIZE):
				var pos = Vector3(x, y, z)
				if not data.has(pos) or data[pos] == -1: 
					continue # -1 = воздух
				
				var base_id = data[pos]
				
				if _is_transparent(x, y + 1, z): 
					# Логика: Если это блок Травы(1), и мы рисуем ВЕРХ, берем текстуру 1.
					# Если это блок Травы, и мы рисуем БОК, берем текстуру 2.
					var texture_id = _get_texture_id_for_face(base_id, Vector3.UP)
					_add_face(st, pos, Vector3.UP, texture_id)
					
				if _is_transparent(x, y - 1, z): 
					var texture_id = _get_texture_id_for_face(base_id, Vector3.DOWN)
					_add_face(st, pos, Vector3.DOWN, texture_id)
					
				if _is_transparent(x - 1, y, z): 
					var texture_id = _get_texture_id_for_face(base_id, Vector3.LEFT)
					_add_face(st, pos, Vector3.LEFT, texture_id)
					
				if _is_transparent(x + 1, y, z): 
					var texture_id = _get_texture_id_for_face(base_id, Vector3.RIGHT)
					_add_face(st, pos, Vector3.RIGHT, texture_id)
					
				if _is_transparent(x, y, z + 1): 
					var texture_id = _get_texture_id_for_face(base_id, Vector3.FORWARD)
					_add_face(st, pos, Vector3.FORWARD, texture_id)
					
				if _is_transparent(x, y, z - 1): 
					var texture_id = _get_texture_id_for_face(base_id, Vector3.BACK)
					_add_face(st, pos, Vector3.BACK, texture_id)
	
	var mesh = st.commit()
	var mesh_inst = MeshInstance.new()
	mesh_inst.mesh = mesh
	add_child(mesh_inst)
	
	# Коллизия
	var shape = mesh.create_trimesh_shape()
	var col = CollisionShape.new()
	col.shape = shape
	add_child(col)

func _is_transparent(x, y, z) -> bool:
	# ... (код тот же)
	return not data.has(Vector3(x, y, z)) # Упростил для примера

# Эта функция решает, какую картинку натянуть на конкретную сторону
func _get_texture_id_for_face(block_id: int, face: Vector3) -> int:
	if block_id == 1: 
		if face == Vector3.UP: return 1   # grass_top.png
		if face == Vector3.DOWN: return 0 # dirt.png
		return 2                          # grass_side.png
	
	return block_id

func _add_face(st: SurfaceTool, pos: Vector3, dir: Vector3, texture_id: int):
	var encoded_id = float(texture_id) / 255.0
	st.add_color(Color(encoded_id, 0, 0, 1))
	
	st.add_normal(dir)
	
	var verts: Array
	match dir:
		Vector3.FORWARD: # +Z
			verts = [Vector3(0, 0, 1), Vector3(0, 1, 1), Vector3(1, 1, 1), Vector3(1, 0, 1)]
		Vector3.BACK: # -Z
			verts = [Vector3(1, 0, 0), Vector3(1, 1, 0), Vector3(0, 1, 0), Vector3(0, 0, 0)]
		Vector3.RIGHT: # +X
			verts = [Vector3(1, 0, 1), Vector3(1, 1, 1), Vector3(1, 1, 0), Vector3(1, 0, 0)]
		Vector3.LEFT: # -X
			verts = [Vector3(0, 0, 0), Vector3(0, 1, 0), Vector3(0, 1, 1), Vector3(0, 0, 1)]
		Vector3.UP: # +Y
			verts = [Vector3(0, 1, 0), Vector3(1, 1, 0), Vector3(1, 1, 1), Vector3(0, 1, 1)]
		Vector3.DOWN: # -Y
			verts = [Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 0, 0), Vector3(0, 0, 0)]
	
	var uvs: Array
	match dir:
		Vector3.LEFT, Vector3.RIGHT: # X-грани: вертикаль = Y
			uvs = [Vector2(1, 1), Vector2(1, 0), Vector2(0, 0), Vector2(0, 1)]
		Vector3.FORWARD, Vector3.BACK: # Z-грани: вертикаль = Y
			uvs = [Vector2(0, 1), Vector2(0, 0), Vector2(1, 0), Vector2(1, 1)]
		Vector3.UP, Vector3.DOWN: # горизонтальные — обычная раскладка
			uvs = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]
	
	var indices = [0, 1, 2, 0, 2, 3]
	
	for i in indices:
		st.add_uv(uvs[i])
		st.add_vertex(pos + verts[i])

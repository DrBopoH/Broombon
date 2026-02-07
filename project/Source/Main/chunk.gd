class_name chunk
extends StaticBody

const CHUNK_SIZE = 16

var data = {}

var texture_atlas: Texture

func _ready():
	_generate_random_data()
	_build_mesh()

func _generate_random_data():
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.period = 10
	
	for x in range(CHUNK_SIZE):
		for z in range(CHUNK_SIZE):
			var height = int((noise.get_noise_2d(x, z) + 1.0) * 4.0)
			for y in range(height + 1):
				data[Vector3(x, y, z)] = 1 if y < height else 2

func _build_mesh():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Материал (можно загрузить свой)
	var mat = SpatialMaterial.new()
	# mat.albedo_texture = texture_atlas # Если есть атлас
	mat.vertex_color_use_as_albedo = true # Будем красить вершины разным цветом для теста
	st.set_material(mat)
	
	# Проходим по всем возможным позициям в чанке
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			for z in range(CHUNK_SIZE):
				var pos = Vector3(x, y, z)
				
				# Если тут пусто (0 или нет в словаре) - пропускаем
				if not data.has(pos) or data[pos] == 0:
					continue
				
				var block_id = data[pos]
				
				# === МАГИЯ ОТСЕЧЕНИЯ ===
				# Проверяем 6 соседей. Рисуем грань, только если соседа НЕТ.
				
				# Верх (Y+)
				if _is_transparent(x, y + 1, z):
					_add_face(st, pos, Vector3.UP, block_id)
				# Низ (Y-)
				if _is_transparent(x, y - 1, z):
					_add_face(st, pos, Vector3.DOWN, block_id)
				# Лево (X-)
				if _is_transparent(x - 1, y, z):
					_add_face(st, pos, Vector3.LEFT, block_id)
				# Право (X+)
				if _is_transparent(x + 1, y, z):
					_add_face(st, pos, Vector3.RIGHT, block_id)
				# Перед (Z+)
				if _is_transparent(x, y, z + 1):
					_add_face(st, pos, Vector3.FORWARD, block_id)
				# Зад (Z-)
				if _is_transparent(x, y, z - 1):
					_add_face(st, pos, Vector3.BACK, block_id)

	# Генерируем нормали и создаем меш
	st.generate_normals()
	var mesh = st.commit()
	
	# Создаем MeshInstance внутри этого StaticBody
	var mesh_inst = MeshInstance.new()
	mesh_inst.mesh = mesh
	add_child(mesh_inst)
	
	# === ГЕНЕРАЦИЯ КОЛЛИЗИИ ===
	# Самый простой способ для вокселей - создать trimesh shape из готового меша
	var shape = mesh.create_trimesh_shape()
	var collision_owner = CollisionShape.new()
	collision_owner.shape = shape
	add_child(collision_owner)

# Проверка: является ли блок прозрачным/воздухом?
func _is_transparent(x, y, z) -> bool:
	var neighbor_pos = Vector3(x, y, z)
	
	# Если координаты выходят за пределы чанка - считаем, что там воздух (пока что)
	if x < 0 or x >= CHUNK_SIZE or y < 0 or y >= CHUNK_SIZE or z < 0 or z >= CHUNK_SIZE:
		return true
		
	# Если в данных нет записи или там 0 - значит прозрачно
	if not data.has(neighbor_pos) or data[neighbor_pos] == 0:
		return true
		
	return false # Там твердый блок

# Функция добавления квадрата (упрощенная версия из прошлых ответов)
func _add_face(st: SurfaceTool, pos: Vector3, dir: Vector3, id: int):
	# Определяем цвет
	var color = Color.brown if id == 1 else Color.gray
	st.add_color(color)
	
	# Получаем смещения вершин для конкретной стороны света
	# Порядок вершин СТРОГО: Низ-Лево -> Низ-Право -> Верх-Право -> Верх-Лево
	# (Относительно взгляда на эту грань снаружи)
	var verts = []
	
	# Используем match для выбора стороны. Это быстрее и надежнее математики.
	match dir:
		Vector3.FORWARD: # Z+ (Перед)
			verts = [Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 1, 1), Vector3(0, 1, 1)]
		Vector3.BACK:    # Z- (Зад) - порядок X инвертирован, чтобы сохранить "лицо"
			verts = [Vector3(1, 0, 0), Vector3(0, 0, 0), Vector3(0, 1, 0), Vector3(1, 1, 0)]
		Vector3.RIGHT:   # X+ (Право)
			verts = [Vector3(1, 0, 1), Vector3(1, 0, 0), Vector3(1, 1, 0), Vector3(1, 1, 1)]
		Vector3.LEFT:    # X- (Лево)
			verts = [Vector3(0, 0, 0), Vector3(0, 0, 1), Vector3(0, 1, 1), Vector3(0, 1, 0)]
		Vector3.UP:      # Y+ (Верх)
			verts = [Vector3(0, 1, 1), Vector3(1, 1, 1), Vector3(1, 1, 0), Vector3(0, 1, 0)]
		Vector3.DOWN:    # Y- (Низ)
			verts = [Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(1, 0, 1), Vector3(0, 0, 1)]

	# Добавляем позицию блока к смещениям
	var p1 = pos + verts[0] # Низ-Лево
	var p2 = pos + verts[1] # Низ-Право
	var p3 = pos + verts[2] # Верх-Право
	var p4 = pos + verts[3] # Верх-Лево
	
	# Явно указываем нормаль (SurfaceTool иногда ошибается при генерации)
	st.add_normal(dir)
	
	# Строим два треугольника (порядок: Против Часовой Стрелки)
	# 1-й треугольник
	st.add_vertex(p1)
	st.add_vertex(p3)
	st.add_vertex(p2)
	
	# 2-й треугольник
	st.add_vertex(p1)
	st.add_vertex(p4)
	st.add_vertex(p3)

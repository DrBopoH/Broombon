extends KinematicBody
class_name PlayerController

# --- Параметры (Константы Minecraft-style) ---
# Стандартная скорость ходьбы в MC ~4.3 м/с. Бег ~5.6 м/с.
# Но мы сделаем по твоему ТЗ: база и х2.
export(float) var walk_speed := 5.0 
export(float) var jump_force := 12.0
export(float) var gravity := 30.0 # Гравитация в воксельных играх обычно выше реалистичной (9.8 слишком "лунная")

# --- Состояние ---
var velocity := Vector3.ZERO
var snap_vector := Vector3.DOWN

# --- Компоненты ---
# Ссылка на узел, где висит твой CameraMouseControl
onready var head = $Head 

func _physics_process(delta: float):
	# 1. Сброс горизонтальной скорости каждый кадр (Snappy movement)
	velocity.x = 0
	velocity.z = 0
	
	# 2. Получаем вектор ввода
	var input_dir := Vector3.ZERO
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_dir = input_dir.normalized()
	
	# 3. Ориентация относительно взгляда
	var direction := Vector3.ZERO
	if head:
		# Берем базис головы (камеры)
		var head_basis = head.global_transform.basis
		# Проецируем на плоскость (игнорируем наклон камеры вверх/вниз для движения)
		direction = (head_basis.x * input_dir.x + head_basis.z * input_dir.z)
		direction.y = 0 # Гарантируем, что не летим вверх/вниз при взгляде
		direction = direction.normalized()
	
	# 4. Расчет скорости (Статика: Walk vs Sprint)
	var current_speed = walk_speed
	if Input.is_key_pressed(KEY_CONTROL):
		current_speed *= 2.0
		
	# Применяем скорость мгновенно
	if direction != Vector3.ZERO:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	
	# 5. Вертикальная физика (Гравитация)
	if not is_on_floor():
		velocity.y -= gravity * delta
		snap_vector = Vector3.ZERO # В воздухе не липнем
	else:
		snap_vector = Vector3.DOWN # На земле липнем к поверхностям
		# Маленькая прижимная сила, чтобы is_on_floor() не мерцал на спусках
		velocity.y = -1.0 
		
		# 6. Прыжок (Только если на полу)
		if Input.is_action_just_pressed("ui_select"): # Space
			velocity.y = jump_force
			snap_vector = Vector3.ZERO
	
	# 7. Финальное перемещение
	# Используем move_and_slide_with_snap для корректной ходьбы по ступеням/склонам
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true)

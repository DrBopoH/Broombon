extends Spatial
class_name world

var entity: KinematicBody
var camera: Camera
var velocity: Vector3

var block: MeshInstance

var texture: Texture = load("res://Source/Assets/Textures/Blocks/stone.png")

func _ready():
	entity = KinematicBody.new()
	add_child(entity)
	
	camera = Camera.new()
	camera.current = true
	camera.far = 1000
	entity.add_child(camera)
	
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	block = MeshInstance.new()
	block.mesh = MeshGen.create_textured_cube(Vector3(1, 1, 1), texture, true)
	add_child(block)
	
	velocity = Vector3.ZERO

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		entity.rotate_y(deg2rad(-event.relative.x))
		
		camera.rotate_x(deg2rad(-event.relative.y))
		
		var cam_rotation = camera.rotation_degrees
		cam_rotation.x = clamp(cam_rotation.x, -90, 90)
		camera.rotation_degrees = cam_rotation
	
	if event is InputEventKey and event.scancode == KEY_ALT:
		if event.is_pressed():
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	var direction = Vector3.ZERO
	var camera_basis = camera.global_transform.basis
	
	if Input.is_action_pressed("front"):
		direction -= camera_basis.z
	if Input.is_action_pressed("back"):
		direction += camera_basis.z
	if Input.is_action_pressed("left"):
		direction -= camera_basis.x
	if Input.is_action_pressed("right"):
		direction += camera_basis.x
	
	if Input.is_action_pressed("up"):
		direction.y += 1.0
	if Input.is_action_pressed("down"):
		direction.y -= 1.0
	
	direction = direction.normalized()
	
	entity.move_and_slide(direction, Vector3.UP) 

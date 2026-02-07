class_name CameraMouseControl
extends Position3D

var camera := Camera.new() 

func _ready():
	add_child(camera)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func get_global_direction(local_direction: Vector3) -> Vector3:
	return camera.global_transform.basis * local_direction

func get_global_direction2d(local_direction: Vector3) -> Vector3:
	return camera.global_transform.basis.x * local_direction.x + camera.global_transform.basis.z * local_direction.z

func camera_rotate(relative: Vector2):
	self.rotate_y(deg2rad(-relative.x))
	camera.rotate_x(deg2rad(-relative.y))

func clamp_camera_x_rotation():
	var cam_rotation = camera.rotation_degrees
	cam_rotation.x = clamp(cam_rotation.x, -90, 90)
	camera.rotation_degrees = cam_rotation

func camera_shapemove_rotate(relative: Vector2):
	camera_rotate(relative)
	clamp_camera_x_rotation()

func mouse_toggle_capture():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera_shapemove_rotate(event.relative)
	
	if event is InputEventKey and event.scancode == KEY_ALT:
		if event.is_pressed(): 
			mouse_toggle_capture()

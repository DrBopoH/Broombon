class_name CameraControl
extends Reference

static func get_global_direction(local_direction: Vector3, camera: Camera) -> Vector3:
	return camera.global_transform.basis * local_direction

static func get_xz_global_direction(local_direction: Vector3, camera: Camera) -> Vector3:
	return camera.global_transform.basis.x*local_direction.x + camera.global_transform.basis.z*local_direction.z + Vector3.UP*local_direction.y

static func rotate(relative: Vector2, head: HeadCamera):
	head.rotate_y(deg2rad(-relative.x))
	head.camera.rotate_x(deg2rad(-relative.y))

static func clamp_x_rotation(camera: Camera):
	var cam_rotation = camera.rotation_degrees
	cam_rotation.x = clamp(cam_rotation.x, -90, 90)
	camera.rotation_degrees = cam_rotation

static func shapemove_rotate(relative: Vector2, head: HeadCamera):
	rotate(relative, head)
	clamp_x_rotation(head.camera)

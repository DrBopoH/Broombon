class_name InputListener
extends Reference

static func handled_input(event, head: HeadCamera) -> Dictionary:
	var mouse := false
	var direction := Vector3.ZERO
	
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			CameraControl.shapemove_rotate(event.relative, head)
			mouse = true
	
	if event is InputEventKey:
		if event.is_pressed() and event.scancode == KEY_ALT: 
			MouseControl.toggle_capture()
		
		if event.scancode in [KEY_W, KEY_S, KEY_A, KEY_D, KEY_SPACE, KEY_SHIFT, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]:
			direction = Vector3(
				Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
				Input.get_action_strength("ui_select") - Input.get_action_strength("ui_focus"),
				Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
			) 
	
	return {"mouse": mouse, "direction": direction}

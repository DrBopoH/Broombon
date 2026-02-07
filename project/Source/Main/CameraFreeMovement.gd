extends KinematicBody
class_name CameraFreeMovement

export(float, 0.01, 100.0) var speed := 1.0

var camuscon: CameraMouseControl = CameraMouseControl.new()
var direction: Vector3
var velocity: Vector3

func _ready():
	add_child(camuscon)

func get_input_direction(pXkey: String, nXkey: String, pYkey: String, nYkey: String, pZkey: String, nZkey: String) -> Vector3:
	return Vector3(
		Input.get_action_strength(pXkey) - Input.get_action_strength(nXkey),
		Input.get_action_strength(pYkey) - Input.get_action_strength(nYkey),
		Input.get_action_strength(pZkey) - Input.get_action_strength(nZkey)
	)

func _physics_process(delta):
	direction = get_input_direction("ui_right", "ui_left", "ui_select", "ui_focus", "ui_down", "ui_up")
	
	velocity = camuscon.get_global_direction2d(direction)
	velocity += Vector3.UP*direction.y
	velocity.normalized()
	
	move_and_slide(velocity*speed, Vector3.UP)

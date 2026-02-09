class_name Entity
extends KinematicBody

export(float) var max_hp = 20.0
export(float, 0.0, 100.0) var current_hp = max_hp

export(float, 0.0, 100.0) var speed = 3.0

var collision := CollisionShape.new()

var velocity := Vector3.ZERO
var direction := Vector3.ZERO

master func set_direction(input_direction: Vector3):
	#direction = input_direction
	#input_direction = input_direction.normalized()
	direction = input_direction.normalized()
	input_direction.y = 0
	velocity = input_direction

func _ready():
	collision.shape = BoxShape.new()
	collision.scale = Vector3(0.4, 0.9, 0.4)
	add_child(collision)

func _physics_process(delta):
	if is_on_floor():
		if direction.y > 0: velocity.y += 0
	else:
		velocity.y -= 0.5
	
	if Vector2(velocity.x, velocity.z).length_squared() > 0.01:
		var target_rotation = atan2(velocity.x, velocity.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, delta * 15.0)
	
	move_and_slide(velocity*speed, Vector3.UP)
	
	
	

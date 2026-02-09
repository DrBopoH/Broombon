class_name ClientServer
extends Node

var chunk := Chunk.new()
var head := HeadCamera.new()


const CHANGE_THRESHOLD := 0.01

var direction: Vector3
var global_direction: Vector3
var follow_entity: Entity

func set_follow_entity(entity: Entity):
	follow_entity = entity

func _ready():
	add_child(head)
	head.camera.current = true
	
	MouseControl.toggle_capture()
	
	add_child(chunk)

func _input(event): 
	var input_data = InputListener.handled_input(event, head)
	
	if input_data["mouse"]:
		var new_global_direction = CameraControl.get_xz_global_direction(direction, head.camera)
		
		if global_direction.distance_squared_to(new_global_direction) > CHANGE_THRESHOLD:
			follow_entity.rpc_id(1, "set_direction", global_direction)
			global_direction = new_global_direction
			print(global_direction)
	else:
		if input_data["direction"] != direction:
			direction = input_data["direction"]
			global_direction = CameraControl.get_xz_global_direction(direction, head.camera)
			follow_entity.rpc_id(1, "set_direction", global_direction)

func _physics_process(delta):
	head.translation = follow_entity.translation + Vector3(0, 0.8, 0)

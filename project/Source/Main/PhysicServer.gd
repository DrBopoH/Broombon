class_name PhysicServer
extends Node

var players: Array
var entitys: Array

func _ready():
	for i in range(1): 
		var entity = Entity.new()
		entity.translation = Vector3(8,16,8)
		entitys.append(entity)
		add_child(entity)

func _physics_process(delta):
	pass

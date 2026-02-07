extends Node

var world0: world

func _ready():
	world0 = world.new()
	add_child(world0)

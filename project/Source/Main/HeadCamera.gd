class_name HeadCamera
extends MeshInstance

var camera := Camera.new() 

func _ready(): add_child(camera)

extends Spatial
class_name Terrain

var chunks: Array

func _ready():
	chunks[0] = Chunk.new()
	for chunk in chunks: add_child(chunk)

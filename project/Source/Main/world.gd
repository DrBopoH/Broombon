extends Spatial
class_name world

var entity: PlayerController

#var block: MeshInstance
var chunks: chunk

#var texture: Texture = load("res://Source/Assets/Textures/Blocks/stone.png")

func _ready():
	#block = MeshInstance.new()
	#block.mesh = VoxelGenerator.create_textured_cube(Vector3(1, 1, 1), texture, true)
	
	#add_child(block)
	
	chunks = chunk.new()
	
	add_child(chunks)
	
	entity = PlayerController.new()
	
	add_child(entity)
	entity.translation = Vector3(8,16,8)
	entity.camuscon.camera.current = true
	

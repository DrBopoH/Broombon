extends Spatial
class_name world

var entity: CameraFreeMovement

var block: MeshInstance

var texture: Texture = load("res://Source/Assets/Textures/Blocks/stone.png")

func _ready():
	block = MeshInstance.new()
	block.mesh = MeshGen.create_textured_cube(Vector3(1, 1, 1), texture, true)
	
	add_child(block)
	
	entity = CameraFreeMovement.new()
	entity.camuscon.camera.current = true
	
	add_child(entity)

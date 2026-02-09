extends Node

var Server: PhysicServer
var Client: ClientServer

func _ready():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(7777, 32)
	get_tree().network_peer = peer
	
	Server = PhysicServer.new()
	Server.name = "PhysicServer"
	add_child(Server)
	
	Client = ClientServer.new()
	Client.name = "ClientServer"
	add_child(Client)
	
	Client.set_follow_entity(Server.entitys[0])

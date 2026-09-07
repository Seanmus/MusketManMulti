extends Node3D

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene
@onready var cam = $Camera2D
@onready var UI = $Ui

func _on_host_pressed() -> void:
	peer.create_server(25565)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player()
	cam.enabled = false
	UI.visible = false

func _on_join_pressed() -> void:
	peer.create_client("127.0.0.1", 25565)
	#peer.create_client("50.71.200.48", 25565)
	multiplayer.multiplayer_peer = peer
	cam.enabled = false
	UI.visible = false

func add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
	
func _exit_game(id):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)

func del_player(id):
	rpc("_del_player", id)
	
@rpc("any_peer", "call_local") func _del_player(id):
	get_node(str(id)).queue_free()

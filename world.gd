extends Node3D


#############
# Multiplayer

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene
@export var host_ip : String = "127.0.0.1"
@export var host_port : int = 1027
@onready var input_host_ip: TextEdit = %InputHostIP
@onready var input_host_port: TextEdit = %InputHostPort

func _ready() -> void:
	input_host_ip.text = host_ip
	input_host_port.text = str(host_port)

func _on_host_pressed() -> void:
	print("_on_host_pressed")
	peer.create_server(host_port)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player()
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED # Focus the mouse on the application
	$CanvasLayer.hide() # Hides the buttons

func _on_join_pressed() -> void:
	peer.create_client(host_ip,host_port)
	multiplayer.multiplayer_peer = peer
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED # Focus the mouse on the application
	print(multiplayer.multiplayer_peer)
	$CanvasLayer.hide() # Hides the buttons


func add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child",player)

func exit_game(id):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)

func del_player(id):
	rpc("_del_player",id)

@rpc("any_peer","call_local")
func _del_player(id):
	get_node(str(id)).queue_free()

func _on_text_edit_text_changed() -> void:
	host_ip = input_host_ip.text


func _on_input_host_port_text_changed() -> void:
	host_port = int(input_host_port.text)

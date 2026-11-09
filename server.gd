extends Node

var PORT := int(OS.get_environment("PORT")) if OS.has_environment("PORT") else 7000
const MAX_CLIENTS := 10


var clients : Array[int] = [];
var peer := WebSocketMultiplayerPeer.new()

func _ready() -> void:
	var args := OS.get_cmdline_user_args()

	if "--server" in args:
		start_dedicated_server()
		return

func start_dedicated_server() -> void:

	var error := peer.create_server(PORT, "0.0.0.0")

	if error != OK:
		print("Server failed: ", error)
		return

	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	print("==============================")
	print("DEDICATED SERVER ONLINE!")
	print("Listening on UDP: ", PORT)
	print("Maximum clients: ", MAX_CLIENTS)
	print("==============================")

func _on_peer_connected(id: int) -> void:
	clients.append(id)
	update_player_list.rpc(clients)
	print("Client connected: ", id)
	print("Clients : ", clients)


func _on_peer_disconnected(id: int) -> void:
	clients.erase(id)
	update_player_list.rpc(clients)
	print("Client disconnected: ", id)
	print("Clients : ", clients)
	
	
@rpc("any_peer", "call_remote", "reliable")
func send_message(message: String , receiver : int ) -> void:
	var sender_id := multiplayer.get_remote_sender_id()

	print("Client ", sender_id, " says: ", message , " to: ", receiver)

	receive_message.rpc_id(
		receiver,
		"Server received: " + message
	)


@rpc("authority", "call_remote", "reliable")
func receive_message(message: String) -> void:
	pass

@rpc("authority", "call_remote", "reliable")
func update_player_list(player_ids: Array) -> void:
	pass

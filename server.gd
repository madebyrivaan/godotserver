extends Node

var PORT := int(OS.get_environment("PORT")) if OS.has_environment("PORT") else 7000
const MAX_CLIENTS := 10


var peer := WebSocketMultiplayerPeer.new()

var users : Dictionary = {}
var players_data : Dictionary = {}

func _ready() -> void:
	var players = await DataBase.request_data()
	players_data = players;
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
	print("Listening on TCP: ", PORT)
	print("Maximum clients: ", MAX_CLIENTS)
	print("==============================")

func _on_peer_connected(id: int) -> void:
	update_player_list.rpc(players_data)
	print("Client connected: ", id)
	print("Clients : ", players_data)


func _on_peer_disconnected(id: int) -> void:
	update_player_list.rpc(players_data)
	print("Client disconnected: ", id)
	print("Clients : ", players_data)
	
	
@rpc("any_peer", "call_remote", "reliable")
func send_message(message: String , username : String ) -> void:
	var clientid : int = players_data[username]["peerid"];
	if clientid == 0:
		return
	print("clientid",clientid , "user-peer-id",multiplayer.get_unique_id())
	receive_message.rpc_id(
		clientid,
		"msg" + message
	)


@rpc("authority", "call_remote", "reliable")
func receive_message(message: String) -> void:
	pass

@rpc("authority", "call_remote", "reliable")
func update_player_list(player_ids: Dictionary) -> void:
	pass

@rpc("any_peer", "call_remote", "reliable")
func login(username_: String, peer_id: int):
	print("User connected: ", username_)

	var sender_id = multiplayer.get_remote_sender_id()

	if not players_data.has(username_):
		peer.disconnect_peer(sender_id)
		return

	players_data[username_]["peerid"] = sender_id

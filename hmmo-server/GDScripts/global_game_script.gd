extends Node

var ws_peer: WebSocketMultiplayerPeer

#Сразу после запуска запустить сервер
func _ready() -> void:
	create_server()

# создать peer как сервер
func create_server(port: int = 1337) -> void:
	ws_peer = WebSocketMultiplayerPeer.new()
	ws_peer.connect("peer_connected", Callable(self, "_on_peer_connected"))
	ws_peer.connect("peer_disconnected", Callable(self, "_on_peer_disconnected"))
	var err: Error = ws_peer.create_server(port)
	if err != OK:
		printerr(error_string(err))
		ws_peer = null
		return
	multiplayer.multiplayer_peer = ws_peer
	print("Server created and set as multiplayer_peer on port ", port)

# функция при подключении пира
func _on_peer_connected(id: int) -> void:
	await  get_tree().create_timer(1).timeout
	print(multiplayer.get_peers())
	for ids in multiplayer.get_peers():
		add_newly_connected_player_character.rpc_id(ids, id)
	print("peer_connected: ", id)

# функция при отключении пира
func _on_peer_disconnected(id: int) -> void:
	print("peer_disconnected: ", id)

@rpc("call_remote", "reliable")
@warning_ignore("unused_parameter")
func add_newly_connected_player_character(new_peer_id:int) -> void:pass

# Тестовый RPC вызов
@rpc("any_peer")
func test() -> void:
	print(multiplayer.get_unique_id()," TESTED!")

func rpc_test() -> void:
	print(multiplayer.get_unique_id(), " " ,rpc("test"))
	pass # Replace with function body.

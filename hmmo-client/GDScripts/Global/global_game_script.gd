extends Node

var ws_peer: WebSocketMultiplayerPeer

# создать peer как клиент
func create_client(url: String = "ws://localhost:1337") -> void:
	
	ws_peer = WebSocketMultiplayerPeer.new()
	ws_peer.connect("peer_connected", Callable(self, "_on_peer_connected"))
	ws_peer.connect("peer_disconnected", Callable(self, "_on_peer_disconnected"))
	var err: Error = ws_peer.create_client(url)
	if err != OK:
		printerr(error_string(err))
		ws_peer = null
		return
	multiplayer.multiplayer_peer = ws_peer
	print("Client created and set as multiplayer_peer, connecting to ", url)

# функция при подключении пира
func _on_peer_connected(id: int) -> void:
	print("peer_connected: ", id)

# функция при отключении пира
func _on_peer_disconnected(id: int) -> void:
	print("peer_disconnected: ", id)

# Тестовый RPC вызов
@rpc("any_peer")
func test() -> void:
	print(multiplayer.get_unique_id()," TESTED!")

func rpc_test() -> void:
	print(multiplayer.get_unique_id(), " " ,rpc("test"))
	pass # Replace with function body.

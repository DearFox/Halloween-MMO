extends Node

var ws_peer: WebSocketMultiplayerPeer
var ws_peer_conect: bool = false

# создать peer как клиент
func create_client(url: String = "ws://localhost:1337") -> void:
	
	ws_peer = WebSocketMultiplayerPeer.new()
	ws_peer.connect("peer_connected", Callable(self, "_on_peer_connected"))
	ws_peer.connect("peer_disconnected", Callable(self, "_on_peer_disconnected"))
	multiplayer.connect("connection_failed", Callable(self, "_on_connection_failed"))
	# Сколько секунд должно пройти после потери соединения, прежде чем соединение будет разорвано со стороны клиента
	ws_peer.set_handshake_timeout(1.0)
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

# функция при ошибки подключения
func _on_connection_failed() -> void:
	print("connection_failed: Ошибка подключения!!!")

# Тестовый RPC вызов
@rpc("any_peer")
func test() -> void:
	print(multiplayer.get_unique_id()," TESTED!")

func rpc_test() -> void:
	print(multiplayer.get_unique_id(), " " ,rpc("test"))
	pass # Replace with function body.

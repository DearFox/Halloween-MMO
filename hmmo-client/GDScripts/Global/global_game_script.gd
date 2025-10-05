extends Node

var ws_peer: WebSocketMultiplayerPeer
var ws_peer_conect: bool = false
const TEMP_WORLD = preload("uid://voviw1y84nnq")

# создать peer как клиент
func create_client(url: String = "ws://localhost:1337") -> void:
	
	ws_peer = WebSocketMultiplayerPeer.new()
	ws_peer.connect("peer_connected", Callable(self, "_on_peer_connected"))
	ws_peer.connect("peer_disconnected", Callable(self, "_on_peer_disconnected"))
	if !multiplayer.is_connected("connection_failed", Callable(self, "_on_connection_failed")):
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
	get_tree().root.add_child(TEMP_WORLD.instantiate())
	get_node("/root/MineMenu").visible = false
	

# функция при отключении пира
func _on_peer_disconnected(id: int) -> void:
	print("peer_disconnected: ", id)
	get_node("/root/TEMP_World").queue_free()
	get_node("/root/MineMenu").visible = true
	

# функция при ошибки подключения
func _on_connection_failed() -> void:
	print("connection_failed: Ошибка подключения!!!")

# Возвращает статус подключения к серверу. 
# ● CONNECTION_DISCONNECTED = 0
# MultiplayerPeer отключен.
# ● CONNECTION_CONNECTING = 1
# В данный момент MultiplayerPeer подключается к серверу.
# ● CONNECTION_CONNECTED = 2
# Этот MultiplayerPeer подключен.
func server_status() -> int:
	return ws_peer.get_connection_status()

# Возвращает true если клиент подключен к севреру. В иных случаях вернет false.
func srv_ok() -> bool:
	if ws_peer != null and ws_peer.get_connection_status() == 2:
		return true
	return false

# Тестовый RPC вызов
@rpc("any_peer")
func test() -> void:
	print(multiplayer.get_unique_id()," TESTED!")

func rpc_test() -> void:
	# Проверим подключение к севреру
	if GGS.srv_ok():
		print(multiplayer.get_unique_id(), " " ,rpc("test"))
	pass # Replace with function body.

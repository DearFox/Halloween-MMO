extends Node

var ws_peer: WebSocketMultiplayerPeer
var ws_peer_conect: bool = false
const TEMP_WORLD = preload("uid://voviw1y84nnq")
const PLAYER = preload("uid://bx6mh138molva")

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
	await  get_tree().create_timer(1).timeout
	register_client_on_server.rpc_id(1,pdb.PlayerName)
	#add_player_character(id)
	

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

func add_player_character(peer_id:int, player_name:String) -> void:
	if peer_id == multiplayer.get_unique_id():
		# Если создаётся клиентский игрок
		print("Подключение этого клиента: ", peer_id)
		var player_character:CharacterBody3D = PLAYER.instantiate()
		player_character.set_multiplayer_authority(peer_id)
		player_character.player_current = true
		player_character.player_name = player_name
		get_node("/root/TEMP_World").add_child(player_character)
		get_node("/root/TEMP_World/PhantomCamera3D").follow_target = get_node("/root/TEMP_World/"+str(peer_id))
		player_character.position = Vector3(0,2,0)
	else:
		# если создается удаленный экземпляр игрока
		print("Подключение игрока ",peer_id)
		var player_character:CharacterBody3D = PLAYER.instantiate()
		player_character.set_multiplayer_authority(peer_id)
		player_character.player_current = false
		player_character.player_name = player_name
		player_character.player_color = Color(1.0, 0.0, 0.0, 1.0)
		get_node("/root/TEMP_World").call_deferred("add_child",player_character)
		player_character.position = Vector3(1,2,0)

func normalize(value: float, max_value: float) -> float:
	if max_value == 0.0:
		return 0.0
	return clamp(value / max_value, 0.0, 1.0)

func concat_ints(a: int, b: int) -> int:
	return int(str(a) + str(b))


@rpc("reliable")
@warning_ignore("unused_parameter")
func add_newly_connected_player_character(new_peer_id: int) -> void:pass # Легаси код, получается.
#	add_player_character(new_peer_id)

@rpc("reliable")
func add_player_on_clients(new_peer_id:int, player_name:String) -> void:
	add_player_character(new_peer_id, player_name)

@rpc("reliable")
func remove_player_on_clients(peer_id:int) -> void:
	get_node("/root/TEMP_World/"+str(peer_id)).queue_free()

@rpc("call_remote", "reliable")
@warning_ignore("unused_parameter")
func register_client_on_server(PlayerName: String = pdb.PlayerName) -> void: pass

@rpc("call_remote", "reliable")
@warning_ignore("unused_parameter")
func send_my_chat_message_on_server(ChatMsg: String) -> void: pass # Если вы не поняли из название - это rpc отправляет клиентсткое чат сообщение на сервер

@rpc("reliable")
@warning_ignore("unused_parameter")
func chat_message_on_client(ChatMsg: String) -> void:
	get_node("/root/TEMP_World/GameChat").add_message(ChatMsg)

# Тестовый RPC вызов
@rpc("any_peer")
func test() -> void:
	print(multiplayer.get_unique_id()," TESTED!")

func rpc_test() -> void:
	# Проверим подключение к севреру
	if GGS.srv_ok():
		print(multiplayer.get_unique_id(), " " ,rpc("test"))
	pass # Replace with function body.

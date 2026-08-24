extends Node

var ws_peer: WebSocketMultiplayerPeer
var ws_peer_conect: bool = false
const TEMP_WORLD = preload("uid://voviw1y84nnq")
const PLAYER = preload("uid://bx6mh138molva")
var LAST_SERVER_TIME = 0
var SERVER_TIME = 0
var CURRENT_TIME = 0
var LEADERBOARD_COUNTER:int = 0

var peers: PackedInt32Array = []

func _ready() -> void:
	await _broadcast_time_sync()

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
	get_tree().root.add_child.call_deferred(TEMP_WORLD.instantiate())
	print("Start Server created and set as multiplayer_peer on port ", port)
	_on_peer_connected(1)
	

# создать peer как клиент
func create_client(url: String = "ws://localhost:1337") -> void:
	
	ws_peer = WebSocketMultiplayerPeer.new()
	ws_peer.connect("peer_connected", Callable(self, "_on_peer_connected"))
	ws_peer.connect("peer_disconnected", Callable(self, "_on_peer_disconnected"))
	if !multiplayer.is_connected("connection_failed", Callable(self, "_on_connection_failed")):
		multiplayer.connect("connection_failed", Callable(self, "_on_connection_failed"))
	# Сколько секунд должно пройти после потери соединения, прежде чем соединение будет разорвано со стороны клиента
	ws_peer.set_handshake_timeout(10.0)
	var err: Error = ws_peer.create_client(url)
	if err != OK:
		printerr(error_string(err))
		ws_peer = null
		return
	multiplayer.multiplayer_peer = ws_peer

	print("Client created and set as multiplayer_peer, connecting to ", url)

# функция при подключении пира
func _on_peer_connected(id: int) -> void:
	print("peer_connected: ", id, " ws_peer.get_unique_id() ", ws_peer.get_unique_id())
	#if id == ws_peer.get_unique_id():
	if !multiplayer.is_server():	get_tree().root.add_child(TEMP_WORLD.instantiate())
	get_node("/root/MineMenu").visible = false
	await  get_tree().create_timer(1).timeout
	register_client_on_server.rpc_id(1,pdb.PlayerName)
	#add_player_character(id)
	

# функция при отключении пира
func _on_peer_disconnected(id: int) -> void:
	print("peer_disconnected: ", id)
	if multiplayer.is_server():
		if !sdb.players.erase(id):
			printerr("Игрок с id:" , id , " не имел записи в Server db в переменной игроков.")
			return
		get_node("/root/TEMP_World/"+str(id)).queue_free()
		for ids in sdb.players.keys():
			remove_player_on_clients.rpc_id(ids, id)
		return
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
	
	if ws_peer != null:
		#print(ws_peer.get_connection_status())
		if ws_peer.get_connection_status() == 2:
			return true
	return false

func add_player_character(peer_id:int, player_name:String) -> void:
	if multiplayer.is_server():	if peers.has(peer_id):	return # На случай дублирования...
	peers.append(peer_id)
	GGS.chat_message_on_client(player_name+" Join server")
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
		player_character.player_color = Color(1.0, 0.56, 0.56, 1.0)
		get_node("/root/TEMP_World").call_deferred("add_child",player_character)
		player_character.position = Vector3(1,2,0)

func normalize(value: float, max_value: float) -> float:
	if max_value == 0.0:
		return 0.0
	return clamp(value / max_value, 0.0, 1.0)

func concat_ints(a: int, b: int) -> int:
	return int(str(a) + str(b))


@rpc("call_local", "reliable", )
@warning_ignore("unused_parameter")
func add_newly_connected_player_character(new_peer_id: int) -> void:pass # Легаси код, получается.
#	add_player_character(new_peer_id)

@rpc("call_local", "reliable")
func add_player_on_clients(new_peer_id:int, player_name:String) -> void:
	#if multiplayer.is_server():	return
	add_player_character(new_peer_id, player_name)
	#send_my_chat_message_on_server.rpc_id(1,"Hello " + player_name + " !\nI'm a bot, and I welcome you to the game!\nPlease behave yourself, and have a nice game!")
	#send_my_chat_message_on_server.rpc_id(1,"Привет " + player_name + " !\nЯ бот, и я приветствую тебя в игре!\nПожалуйста ведите себя хорошо, и приятной вам игры!")

@rpc("call_local", "reliable")
func remove_player_on_clients(peer_id:int) -> void:
	#if multiplayer.is_server():	return
	var remove_node:Node = get_node("/root/TEMP_World/"+str(peer_id))
	GGS.chat_message_on_client(remove_node.player_name + " Leave server")
	get_node("/root/TEMP_World/"+str(peer_id)).queue_free()

@rpc("call_local", "reliable")
@warning_ignore("unused_parameter")
func time_sinc(current_time:int) -> void:
	#if multiplayer.is_server():	return
	LAST_SERVER_TIME = current_time
	#print(LAST_SERVER_TIME)

@rpc("any_peer", "reliable", "call_local")
@warning_ignore("unused_parameter")
func sent_candy_count(candy_count:int) -> void: 
	if multiplayer.is_server():	
		var sender_id:int = multiplayer.get_remote_sender_id()
		#print("Received candy count from player ", sender_id, ": ", candy_count)
		if candy_count > 15:
			print(sender_id, " судя по всему читер")
		if sender_id in sdb.players:
			var PlayerName:String = sdb.players[sender_id]["name"]
			if sdb.candy_leaderboard.get(PlayerName):
				sdb.candy_leaderboard[PlayerName] += candy_count
			else : sdb.candy_leaderboard[PlayerName] = candy_count
			#sdb.players[sender_id]["candy"] = candy_count
			#print("Player ", sender_id, " sent ", candy_count, " candies.")

@rpc("any_peer", "reliable", "call_local")
@warning_ignore("unused_parameter")
func request_leaderboard() -> void:
	if multiplayer.is_server():
		var sender_id:int = multiplayer.get_remote_sender_id()
		var leaderboard:Array = _build_leaderboard()
		leaderboard_on_client.rpc_id(sender_id, leaderboard)

func _build_leaderboard() -> Array:
	if !sdb.candy_leaderboard:
		return []
	var leaderboard:Array = []
	for players in sdb.candy_leaderboard.keys():
		leaderboard.append([players,int(sdb.candy_leaderboard[players])])
	leaderboard.sort_custom(func(a, b): return a[1] > b[1])
	return leaderboard.slice(0, min(5, leaderboard.size()))

@rpc("any_peer","reliable", "call_local")
@warning_ignore("unused_parameter")
func register_client_on_server(PlayerName: String) -> void:
	if multiplayer.is_server():
		var sender_id:int = multiplayer.get_remote_sender_id()
		print(ws_peer.get_peer_address(multiplayer.get_remote_sender_id()) , " " ,sender_id," is: ",PlayerName)
		sdb.players[sender_id] = {"name": PlayerName,"candy": 0} #TODO Добавить серверную проверку на "корректность" имени пользователя
		#sdb.candy_leaderboard[PlayerName] = 0
		
		add_player_character(sender_id, PlayerName)
		for ids in sdb.players.keys():
			if !ids == sender_id:
				add_player_on_clients.rpc_id(ids,sender_id,sdb.players[sender_id]["name"])
			add_player_on_clients.rpc_id(sender_id,ids,sdb.players[ids]["name"])

@rpc("any_peer", "reliable", "call_local")
@warning_ignore("unused_parameter")
func send_my_chat_message_on_server(ChatMsg: String) -> void:
	if multiplayer.is_server():
		var sender_id:int = multiplayer.get_remote_sender_id()
		var author:String = sdb.players[sender_id]["name"]
		var format_message:String = "<"+author+"> : [color=gray]"+ChatMsg+"[/color]"
		print(sender_id , format_message)
		for ids in sdb.players.keys():
			chat_message_on_client.rpc_id(ids,format_message)

@rpc("reliable", "call_local")
@warning_ignore("unused_parameter")
func chat_message_on_client(ChatMsg: String) -> void:
	#if multiplayer.is_server():	return
	get_node("/root/TEMP_World/GameChatCanvasLayer/GameChat").add_message(ChatMsg)

@rpc("reliable", "call_local")
@warning_ignore("unused_parameter")
func leaderboard_on_client(leaderboard:Array) -> void:
	#if multiplayer.is_server():	return
	pdb.PlayerLeaderboard = leaderboard.duplicate(true)
	print("Leaderboard updated: ", leaderboard)

# Тестовый RPC вызов
@rpc("any_peer", "call_local")
func test(peer_id := -1) -> void:
	print(multiplayer.get_unique_id(), " TESTED! sender:", peer_id)

func rpc_test() -> void:
	# Проверим подключение к севреру
	if GGS.srv_ok():
		test.rpc()
		print(multiplayer.get_unique_id(), " RPC test sent")
	pass # Replace with function body.

func fetch_leaderboard() -> void:
	if GGS.srv_ok():
		request_leaderboard.rpc_id(1)
	else:
		push_warning("Cannot request leaderboard: not connected to server")



func _physics_process(delta: float) -> void:
	if LAST_SERVER_TIME != SERVER_TIME:

		SERVER_TIME = LAST_SERVER_TIME
		if LAST_SERVER_TIME-CURRENT_TIME > 200 or LAST_SERVER_TIME-CURRENT_TIME < -600:
			CURRENT_TIME = SERVER_TIME
		
		if LEADERBOARD_COUNTER >= 10:
			fetch_leaderboard()
			LEADERBOARD_COUNTER = 0
		else:
			LEADERBOARD_COUNTER += 1
	CURRENT_TIME += delta*1000 


func _broadcast_time_sync() -> void:
	while true:
		if multiplayer.is_server():
			var current_time = Time.get_ticks_msec()
			time_sinc.rpc(current_time)
			#print(current_time)
		await get_tree().create_timer(1.0).timeout
		#for ids in sdb.players.keys():
		#	print("Player connected: ", sdb.players[ids])

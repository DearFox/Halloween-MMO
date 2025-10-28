extends Node

var ws_peer: WebSocketMultiplayerPeer

const PLAYER = preload("uid://dbskhjcxeeoni")
const TEMP_WORLD = preload("uid://bauf4vug7xfn8")

#Сразу после запуска запустить сервер
func _ready() -> void:
	create_server()
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
	print("Server created and set as multiplayer_peer on port ", port)

# функция при подключении пира
func _on_peer_connected(id: int) -> void:
	await  get_tree().create_timer(1).timeout
	print(multiplayer.get_peers())
	#for ids in multiplayer.get_peers():
	#	add_newly_connected_player_character.rpc_id(ids, id)
	print(ws_peer.get_peer_address(id) ," peer_connected: ", id)

# функция при отключении пира
func _on_peer_disconnected(id: int) -> void:
	print(" peer_disconnected: ", id)
	if !sdb.players.erase(id):
		printerr("Игрок с id:" , id , " не имел записи в Server db в переменной игроков.")
		return
	get_node("/root/TEMP_World/"+str(id)).queue_free()
	for ids in sdb.players.keys():
		remove_player_on_clients.rpc_id(ids, id)

func add_player_character(peer_id) -> void:
	var player_character:Node2D = PLAYER.instantiate()
	player_character.set_multiplayer_authority(peer_id)
	get_node("/root/TEMP_World").add_child(player_character)


@rpc("call_remote", "reliable")
@warning_ignore("unused_parameter")
func add_newly_connected_player_character(new_peer_id:int) -> void:pass

@rpc("call_remote", "reliable")
@warning_ignore("unused_parameter")
func add_player_on_clients(new_peer_id:int, player_name:String) -> void:pass

@rpc("call_remote", "reliable")
@warning_ignore("unused_parameter")
func remove_player_on_clients(peer_id:int) -> void:pass

@rpc("call_remote", "reliable")
@warning_ignore("unused_parameter")
func time_sinc(current_time:int) -> void:pass

@rpc("any_peer","reliable")
func register_client_on_server(PlayerName: String) -> void:
	var sender_id:int = multiplayer.get_remote_sender_id()
	print(ws_peer.get_peer_address(multiplayer.get_remote_sender_id()) , " " ,sender_id," is: ",PlayerName)
	sdb.players[sender_id] = {"name": PlayerName} #TODO Добавить серверную проверку на "корректность" имени пользователя
	add_player_character(sender_id)
	for ids in sdb.players.keys():
		if !ids == sender_id:
			add_player_on_clients.rpc_id(ids,sender_id,sdb.players[sender_id]["name"])
		add_player_on_clients.rpc_id(sender_id,ids,sdb.players[ids]["name"])

@rpc("any_peer", "reliable")
@warning_ignore("unused_parameter")
func send_my_chat_message_on_server(ChatMsg: String) -> void: 
	var sender_id:int = multiplayer.get_remote_sender_id()
	var author:String = sdb.players[sender_id]["name"]
	var format_message:String = "<"+author+"> : [color=gray]"+ChatMsg+"[/color]"
	print(ws_peer.get_peer_address(sender_id) , format_message)
	for ids in sdb.players.keys():
		chat_message_on_client.rpc_id(ids,format_message)
	

@rpc("call_remote", "reliable")
@warning_ignore("unused_parameter")
func chat_message_on_client(ChatMsg: String) -> void: pass

# Тестовый RPC вызов
@rpc("any_peer")
func test() -> void:
	print(multiplayer.get_unique_id()," TESTED!")

func rpc_test() -> void:
	print(multiplayer.get_unique_id(), " " ,rpc("test"))
	pass # Replace with function body.

func _broadcast_time_sync() -> void:
	while true:
		var current_time = Time.get_ticks_msec()
		time_sinc.rpc(current_time)
		print(current_time)
		await get_tree().create_timer(1.0).timeout

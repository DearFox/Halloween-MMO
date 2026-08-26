extends Control

@onready var connection_status: Label = $VBoxMenu/ConnectionStatus
@onready var quit_timer: Timer = $quit_timer

var ws_peer:WebSocketMultiplayerPeer

var lan_server_list: PackedStringArray = []

func _ready() -> void:
	#print(IP.get_local_interfaces())
	$VBoxMenu/HBoxPlayerName/PlayerName.text = pdb.PlayerName
	ServiceDiscovery.port = 4040
	ServiceDiscovery.scanned_server.connect(_on_scan_server)
	ServiceDiscovery.scanned.connect(_on_scan_scanned)
	$VBoxMenu/HBoxServer/OptionButton.grab_focus()

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	# Выход из игры
	if Input.is_action_pressed("Quit"):
		if quit_timer.is_stopped():
			quit_timer.start()
		$quit_timer/AudioStreamPlayer.pitch_scale = (1 - quit_timer.time_left + 0.125) * 8
		$quit_timer/AudioStreamPlayer.play()
	else :
		quit_timer.stop()

func _on_scan_server(data):
	#add_server_button(data)
	lan_server_list.append(data.server_ip)

func add_server_button(data):
	
	print(data)
	$VBoxMenu/HBoxServer/OptionButton.set_item_text(2, "ws://"+str(data.server_ip)+":1337")
	#$VBoxMenu/HBoxServer/IP.text = "ws://"+str(data.server_ip)+":1337"

func _on_scan_scanned():
	print("_on_scan_scanned")
	Server_List_OptionButton_update()
	$VBoxMenu/HBoxServer/Join.disabled = false
	$VBoxMenu/HBoxServer/LAN.disabled = false
	

func _on_join_pressed() -> void: 
	#print($VBoxMenu/HBoxServer/OptionButton.get_item_text($VBoxMenu/HBoxServer/OptionButton.selected))
	if $VBoxMenu/HBoxPlayerName/PlayerName.text: #TODO Не позволять игрокам использовать "пустые" ники лучше.
		pdb.PlayerName = $VBoxMenu/HBoxPlayerName/PlayerName.text
	if $VBoxMenu/HBoxServer/OptionButton.selected == 0:
		GGS.create_client($VBoxMenu/HBoxServer/IP.text)
	else :
		GGS.create_client($VBoxMenu/HBoxServer/OptionButton.get_item_text($VBoxMenu/HBoxServer/OptionButton.selected))
	ws_peer = GGS.ws_peer
	$ConnectionStatusCheck.start()

func _tested():
	if ws_peer == null:
		connection_status.text = "Статус соединения: Не определено"
		connection_status.modulate = Color(1.0, 1.0, 1.0, 1.0)
		return
	match ws_peer.get_connection_status():
		0: 
			connection_status.text = "Статус соединения: Отключен"
			connection_status.modulate = Color(1.0, 0.0, 0.0, 1.0)
			$ConnectionStatusCheck.stop()
		1: 
			connection_status.text = "Статус соединения: Подключение..."
			connection_status.modulate = Color(0.0, 1.0, 1.0, 1.0)
		2: 
			connection_status.text = "Статус соединения: Подключено!"
			connection_status.modulate = Color(0.0, 1.0, 0.0, 1.0)


@warning_ignore("unused_parameter")
func _on_player_name_text_submitted(new_text: String) -> void:
	_on_join_pressed()



func _on_sfx_volume_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		$SFXDemo.pitch_scale = randf_range(0.8,2.0)
		$SFXDemo.play()
	pass # Replace with function body.


func _on_create_server_pressed() -> void:
	ServiceDiscovery.server_data = {'Name':'HMMO Server'}
	ServiceDiscovery.set_server()
	#GGS.create_server()
	if $VBoxMenu/HBoxPlayerName/PlayerName.text: #TODO Не позволять игрокам использовать "пустые" ники лучше.
		pdb.PlayerName = $VBoxMenu/HBoxPlayerName/PlayerName.text
	if $VBoxMenu/HBoxServer/OptionButton.selected == 0:
		GGS.create_server()
	else :
		GGS.create_server()
	ws_peer = GGS.ws_peer
	$ConnectionStatusCheck.start()


func _on_lan_scan_timeout() -> void:
	if ws_peer == null:
		print("ws_peer == null")
		pass
	else:
		match ws_peer.get_connection_status():
			0: 
				print("ws_peer.get_connection_status() 0")
			1: 
				print("ws_peer.get_connection_status() 1")
			2: 
				print("ws_peer.get_connection_status() 2")
				return
	ServiceDiscovery.scan_lan_servers()

func _on_quit_timer_timeout() -> void:
	get_tree().quit()


func _on_lan_pressed() -> void:
	lan_server_list.clear()
	$VBoxMenu/HBoxServer/OptionButton.clear()
	$VBoxMenu/HBoxServer/OptionButton.add_item("Scanning...", 0)
	$VBoxMenu/HBoxServer/Join.disabled = true
	$VBoxMenu/HBoxServer/LAN.disabled = true
	ServiceDiscovery.scan_lan_servers()

func Server_List_OptionButton_update() -> void:
	$VBoxMenu/HBoxServer/OptionButton.clear()
	$VBoxMenu/HBoxServer/OptionButton.add_item("<------ Custom server", 0)
	$VBoxMenu/HBoxServer/OptionButton.add_item("ws://localhost:1337", 1)
	
	var _index_g:int = 10
	for _ip in GGS.Global_Server_List:
		$VBoxMenu/HBoxServer/OptionButton.add_item("ws://"+str(_ip)+":1337", _index_g)
		_index_g += 1
	
	var _index:int = 100
	for _ip in lan_server_list:
		$VBoxMenu/HBoxServer/OptionButton.add_item("ws://"+str(_ip)+":1337", _index)
		_index += 1
	$VBoxMenu/HBoxServer/OptionButton.select($VBoxMenu/HBoxServer/OptionButton.get_item_index(100))
	pass


func _on_random_username_pressed() -> void:
	$VBoxMenu/HBoxPlayerName/PlayerName.text = GGS.generate_nickname()

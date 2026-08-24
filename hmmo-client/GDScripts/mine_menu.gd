extends Control

@onready var connection_status: Label = $VBoxMenu/ConnectionStatus

var ws_peer:WebSocketMultiplayerPeer

func _ready() -> void:
	$VBoxMenu/HBoxPlayerName/PlayerName.text = pdb.PlayerName
	ServiceDiscovery.port = 4040
	ServiceDiscovery.scanned_server.connect(_on_scan_server)
	ServiceDiscovery.scanned.connect(_on_scan_scanned)
	$VBoxMenu/HBoxServer/OptionButton.grab_focus()

func _on_scan_server(data):
	add_server_button(data)

func add_server_button(data):
	$VBoxMenu/HBoxServer/OptionButton.set_item_text(2, "ws://"+str(data.server_ip)+":1337")
	$VBoxMenu/HBoxServer/IP.text = "ws://"+str(data.server_ip)+":1337"

func _on_scan_scanned():	pass

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
	ServiceDiscovery.scan_lan_servers()

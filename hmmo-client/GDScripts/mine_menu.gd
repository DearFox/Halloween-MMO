extends Control

@onready var connection_status: Label = $VBoxMenu/ConnectionStatus

var ws_peer:WebSocketMultiplayerPeer

func _on_join_pressed() -> void: 
	if $VBoxMenu/HBoxPlayerName/PlayerName.text: #TODO Не позволять игрокам использовать "пустые" ники лучше.
		pdb.PlayerName = $VBoxMenu/HBoxPlayerName/PlayerName.text
	GGS.create_client($VBoxMenu/HBoxServer/IP.text)
	ws_peer = GGS.ws_peer
	$ConnectionStatusCheck.start()
	


func _on_button_pressed() -> void:
	GGS.rpc_test()

func _tested():
	if ws_peer == null:
		connection_status.text = "Статус соединения: Не определено"
		return
	match ws_peer.get_connection_status():
		0: 
			connection_status.text = "Статус соединения: Отключен"
			$ConnectionStatusCheck.stop()
		1: connection_status.text = "Статус соединения: Подключение..."
		2: connection_status.text = "Статус соединения: Подключено!"

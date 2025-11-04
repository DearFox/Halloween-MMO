extends Node

var PlayerName: String = "Player " + str(randi_range(0,999))
#var PlayerSkin:int = 0
#var PlayerMoney:int = 0
#var PlayerSuit1:bool = false
#var PlayerSuit2:bool = false
#var PlayerSuit3:bool = false
var suit_unlock: Array = [true, false, false, false]
var PlayerCandy:int = 0
#Список лидеров приходит с сервера, не сохраняем между сессиями
var PlayerLeaderboard:Array = []
#Переменные необходимые во время игры. Не должны сохраняться. Они тут что-бы не загружать еще сильнее глобальный игровой скрипт.
var me_chatting:bool = false

func _ready() -> void:
	loading_player_db()

func loading_player_db() -> void:
	print("Загрузка данных игрока и натсроек...")
	if FileAccess.file_exists("user://gamesave.dat"):
		var _file = FileAccess.open("user://gamesave.dat", FileAccess.READ)
		var content = _file.get_as_text()
		var dict = JSON.parse_string(content)
		print(dict)
		#candy_leaderboard = dict
		print("База данных загружена!")
		if dict != null: 
			if dict["PlayerName"] != null:
				PlayerName = dict["PlayerName"]
			else : print("PlayerName", "Не найден!")
			if dict["suit_unlock"] != null:
				suit_unlock = dict["suit_unlock"]
			else : print("suit_unlock", "Не найден!")
			if dict["PlayerCandy"] != null:
				PlayerCandy = dict["PlayerCandy"]
			else : print("PlayerCandy", "Не найден!")
			if dict["MasterVolume"] != null:
				AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),dict["MasterVolume"])
			else : print("MasterVolume", "Не найден!")
			if dict["SFXVolume"] != null:
				AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),dict["SFXVolume"])
			else : print("SFXVolume", "Не найден!")
			if dict["MusicVolume"] != null:
				AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),dict["MusicVolume"])
			else : print("MusicVolume", "Не найден!")
		else: print("Но она оказалась путой...")
	else:
		print("База данных не найдена")

func save_player_db() -> bool:
	var temp_dict:Dictionary = {
		"PlayerName": PlayerName,
		"suit_unlock": suit_unlock,
		"PlayerCandy": PlayerCandy,
		"MasterVolume": AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")),
		"SFXVolume": AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")),
		"MusicVolume": AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	}
	var file = FileAccess.open("user://gamesave.dat", FileAccess.WRITE)
	if file and file.store_string(JSON.stringify(temp_dict.duplicate(true))):
		print("Игровые настройки и прогресс сохранён")
		return true
	else :
		printerr("При сохранении настроек и прогресса произошла ошибка!")
		return false

func update_candy() -> void:
	var temp_node:Node = get_node("/root/TEMP_World/GameChatCanvasLayer/GameChat")
	if temp_node:
		temp_node.update_candy()

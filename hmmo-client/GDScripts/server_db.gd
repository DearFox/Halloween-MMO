extends Node

var players: Dictionary

#var candy_leaderboard: Dictionary[String, int]
var candy_leaderboard: Dictionary

#нужна для сохранения, что-бы изменения во время сохранения не сломали чегонить.
var temp_candy_leaderboard: Dictionary

var db_file_name_candy_leaderboard:String = "candy_leaderboard_database"

var db_file_path:String = "user://"
var db_file_format:String = ".dat"

func _ready() -> void:
	db_load_candy_leaderboard()
	await _autosave_db_candy_leaderboard()
	#db_save_candy_leaderboard()
	

func db_save_candy_leaderboard(backup:bool):
	temp_candy_leaderboard = candy_leaderboard.duplicate(true)
	var file
	if backup:
		var current_date = Time.get_datetime_dict_from_unix_time(int(Time.get_unix_time_from_system()))
		#year, month, day, hour, minute
		var backup_db_name:String = db_file_name_candy_leaderboard+"_"+str(current_date.year)+"_"+str(current_date.month)+"_"+str(current_date.day)+"_"+str(current_date.hour)+"_"+str(current_date.minute)+"_"+str(current_date.second)
		var err:Error = DirAccess.make_dir_absolute(db_file_path+"backup/")
		print(err)
		if err == OK:
			print("Папка для бекапов создана")
		elif err == ERR_ALREADY_EXISTS:
			pass
		else : printerr("При попытке создать папку для бекапов произошла ошибка: "+str(err))
		file = FileAccess.open(db_file_path+"backup/"+backup_db_name+db_file_format, FileAccess.WRITE)
	else :
		file = FileAccess.open(db_file_path+db_file_name_candy_leaderboard+db_file_format, FileAccess.WRITE)
	if file and file.store_string(JSON.stringify(temp_candy_leaderboard)):
		print("База данных сохранена")
	else :
		printerr("При сохранении базы данных произошла ошибка!")

func db_load_candy_leaderboard():
	print("Загрузка базы данных лидерборда...")
	if FileAccess.file_exists(db_file_path+db_file_name_candy_leaderboard+db_file_format):
		var file = FileAccess.open(db_file_path+db_file_name_candy_leaderboard+db_file_format, FileAccess.READ)
		var content = file.get_as_text()
		var dict = JSON.parse_string(content)
		print(dict)
		candy_leaderboard = dict
		print("База данных загружена!")
		if dict == null: 
			print("Но она оказалась путой...")
	else:
		print("База данных не найдена")

func _autosave_db_candy_leaderboard() -> void:
	while true:
		await get_tree().create_timer(300.0).timeout
		db_save_candy_leaderboard(false)
		#db_save_candy_leaderboard(true)

# candy_leaderboard структура данных:
# {
# 	"Player 123": 12345 #Количество конфет собранных за всё время
# }

# players структура данных:
# {
# 	1234567890: #peer id клиента \ игрока
# 	{
# 		"name": "Имя игрока или его юзернейм",
# 		"candy": 0, #Количество конфет у игрока
# 		"skin": 0, #TODO Номер скина игрока | Не используется
# 		"suit": 0, #TODO Номер костюма на игроке | Не используется
# 		#TODO Другие данные при необходимости
# 	},
# }

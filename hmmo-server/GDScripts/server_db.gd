extends Node

var players: Dictionary

var candy_leaderboard: Dictionary[String, int]

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

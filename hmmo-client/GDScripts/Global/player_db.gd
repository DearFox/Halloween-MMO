extends Node

var PlayerName: String = "Player " + str(randi_range(0,999))
var PlayerSkin:int = 0
var PlayerMoney:int = 0
var PlayerSuit1:bool = false
var PlayerSuit2:bool = false
var PlayerSuit3:bool = false

func loading_player_db() -> void: pass #TODO
func save_player_db() -> void: pass #TODO

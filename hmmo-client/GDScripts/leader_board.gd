extends Node3D

var candy_visual:Array = ["🍬","🍭","🍫"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_leaderboard(pdb.PlayerLeaderboard)

func update_leaderboard(data:Array) -> void:
	var text_temp:String = "Leaderboard"
	if data != []:
		for i in data:
			text_temp = text_temp + "\n" + i[0] + ": " + str(i[1]) + " " + candy_visual[randi_range(0,2)]
		$Label3D.text = text_temp
	else :
		$Label3D.text = text_temp + "\nLoading..."


func _on_timer_timeout() -> void:
	update_leaderboard(pdb.PlayerLeaderboard)

extends Node3D

var text:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = $Label.text

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	$Node3D.rotate_y(delta*2.5)
	text = "."+text+"."
	$Label.text = text + "\n" + str($Timer.time_left) + ""

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/mine_menu.tscn")

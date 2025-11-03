extends Node3D

var StreemPlayersAll:Array # Steps tupe -1, содержит все звуки шагов
var StreemPlayersLeaves:Array # Steps tupe 1
var StreemPlayersStone:Array # Steps tupe 0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	StreemPlayersAll = [$Leaves01, $Leaves02, $Stone01, $metal_steps_01, $metal_steps_02, $metal_steps_03, $metal_steps_04, $metal_steps_05, $metal_steps_06, $metal_steps_07, $metal_steps_08, $metal_steps_09, $metal_steps_10, $metal_steps_11, $metal_steps_12, $metal_steps_13, $metal_steps_14, $metal_steps_15, $metal_steps_16, $metal_steps_17, $metal_steps_18, $metal_steps_19, $metal_steps_20, $metal_steps_21, $metal_steps_22, $metal_steps_23, $metal_steps_24, $metal_steps_25]
	StreemPlayersLeaves = [$Leaves01, $Leaves02]
	StreemPlayersStone = [$Stone01, $metal_steps_01, $metal_steps_02, $metal_steps_03, $metal_steps_04, $metal_steps_05, $metal_steps_06, $metal_steps_07, $metal_steps_08, $metal_steps_09, $metal_steps_10, $metal_steps_11, $metal_steps_12, $metal_steps_13, $metal_steps_14, $metal_steps_15, $metal_steps_16, $metal_steps_17, $metal_steps_18, $metal_steps_19, $metal_steps_20, $metal_steps_21, $metal_steps_22, $metal_steps_23, $metal_steps_24, $metal_steps_25]

func StreemPlayersPlaying()->bool:
	for i in StreemPlayersAll:
		if i.playing:
			return true
	return false

func PlayStep(step_tupe:int)->void:
	if !StreemPlayersPlaying() and $Timer.is_stopped() and StreemPlayersAll:
		var steps_player_list:Array = StreemPlayersStone
		match step_tupe:
			1:
				steps_player_list = StreemPlayersLeaves
			-1:
				steps_player_list = StreemPlayersAll
		var random_sound:int = randi_range(0,steps_player_list.size()-1)
		var random_pitch:float = randf_range(1.0,1.3)
		steps_player_list[random_sound].pitch_scale = random_pitch
		$Timer.start()
		steps_player_list[random_sound].play()

extends Label

const SCALE_MIN:float = 0.7
const SCALE_MAX:float = 1.5
const PERIOD:float = 2.0

var _time:float = 0

var splashes:Array = ["Online game!","Made on Godot!","Furry Games and Dev Jam #4","Hi!"]

func _ready() -> void:
	set_splash()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_time += delta
	if _time >= PERIOD:
		_time -= PERIOD
	var t:float = _time / PERIOD
	var s:float = (sin(t * TAU) * 0.5) + 0.5
	var current_scale:float = lerp(SCALE_MIN, SCALE_MAX, s)
	scale = Vector2.ONE * current_scale

func set_splash():
	var now = Time.get_datetime_dict_from_system()
	var day_and_month:int = GGS.concat_ints(now.day,now.month)
	match day_and_month:
		1110:
			text = "Bday Slava!"
			return
		11:
			text = "Happy New Year!"
			return
		108:
			text = "Bday Kiyafoo!"
			return
		_:
			text = splashes[randi_range(0,splashes.size()-1)]
			return

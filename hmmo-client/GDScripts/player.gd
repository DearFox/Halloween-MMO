extends CharacterBody3D


const SPEED: float = 5.0
const JUMP_VELOCITY: float = 6.5

const SUIT_JUMP: int = 15
const SUIT_SPEED: int = 250

var suit: int = 1 #Костюм. 0 - никакой, 1 - высокий прыжок, 2 - рывок, 3 - прохождение через особые стены

var player_current: bool = false
var player_color:Color = Color(0.0, 0.29, 3.413)
var player_name:String

func _enter_tree() -> void:
	name = str(get_multiplayer_authority())
	$ID.text = str(name)
	$Name.text = player_name

func _ready() -> void:
	#if player_current:
	#	$PhantomCamera3D.priority = 10
	#	print($PhantomCamera3D.priority)
	#$Camera3D.current = player_current
	$ColorRect.visible = player_current
	$PlayerVisual_TEMP.modulate = player_color
	if !is_multiplayer_authority():
		$PositionSync.free()
	

func _physics_process(delta: float) -> void:
	
	if GGS.srv_ok() and is_multiplayer_authority():
		# Индикация спец приёма костюма
		if $SuitTimer.is_stopped():
			$ColorRect.color = Color(0.0, 1.0, 0.0, 1.0)
		else : 
			var normal_time:float = GGS.normalize($SuitTimer.time_left,$SuitTimer.wait_time)
			$ColorRect.color = Color(normal_time, 1.0-normal_time, 0.0, 1.0)
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
				# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("left", "right", "up", "down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		var temp_jump: float = JUMP_VELOCITY
		if Input.is_action_pressed("suit_ability"):
			#print("Спец сила костюма!")
			match suit:
				1: 
					if Input.is_action_pressed("ui_accept") and is_on_floor() and $SuitTimer.is_stopped():
						temp_jump = SUIT_JUMP
						$SuitTimer.start()
				2:
					if velocity and $SuitTimer.is_stopped():
						$SuitTimer.start()
						velocity.x = direction.x * SUIT_SPEED
						velocity.z = direction.z * SUIT_SPEED
						move_and_slide()
		# Handle jump.
		if Input.is_action_pressed("ui_accept") and is_on_floor():
			velocity.y = temp_jump

			
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _on_position_sync_timeout() -> void:
	position_sync.rpc(position)
	#print("Синхронизация позиции " + name)

@rpc("call_remote", "unreliable")
func position_sync(pose:Vector3) -> void:
	position = pose
	#print("Удаленная синхронизация позиции " + name)

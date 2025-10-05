extends CharacterBody3D


const SPEED = 5.0
#const JUMP_VELOCITY = 4.5

var player_current: bool = false

var player_color:Color = Color(0.0, 0.29, 3.413)

func _enter_tree() -> void:
	name = str(get_multiplayer_authority())
	$ID.text = str(name)

func _ready() -> void:
	$Camera3D.current = player_current
	$PlayerVisual_TEMP.modulate = player_color

func _physics_process(delta: float) -> void:
	
	if GGS.srv_ok() and is_multiplayer_authority():
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

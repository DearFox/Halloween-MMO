extends CharacterBody3D


const SPEED: float = 5.0
const JUMP_VELOCITY: float = 6.5

const SUIT_JUMP: int = 15
const SUIT_SPEED: int = 15

const ROTATE_MODEL_SPEED:float = 10.0

var suit: int = 0 #Костюм. 0 - никакой, 1 - высокий прыжок, 2 - рывок, 3 - прохождение через особые стены

var player_current: bool = false
var player_color:Color = Color(1.0, 1.0, 1.0, 1.0)
var player_name:String
var last_poss:Vector3 = Vector3(0,0,0)

var prev_pos: Vector3
var target_pos: Vector3
var lerp_time := 0.05
var t := 1.0
var prev_rot: Vector3 = Vector3.ZERO
var target_rot: Vector3 = Vector3.ZERO
var prev_velocity_sync: Vector3 = Vector3.ZERO
var target_velocity_sync: Vector3 = Vector3.ZERO


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
	$CollisionShape3D.disabled = !player_current
	$PlayerVisual_TEMP.modulate = player_color
	$blockbench_export.get_node("AnimationPlayer").set_default_blend_time(0.5)
	if !is_multiplayer_authority():
		$PositionSync.free()

func _physics_process(delta: float) -> void:
	if velocity.x or velocity.z:
		$blockbench_export.get_node("AnimationPlayer").play("run")
	else:
		$blockbench_export.get_node("AnimationPlayer").play("idel")
	
	if GGS.srv_ok() and is_multiplayer_authority():
		if global_position.y <= -10:
			global_position = Vector3(0,2,0)
			#if PhantomCamera3D != null:
			#	print("Телепортируем камеру")
			#else:
			#	print("Камера не найдена")
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
		# print(is_on_floor())
		if Input.is_action_pressed("suit_ability") and !pdb.me_chatting:
			#print("Спец сила костюма!")
			match suit:
				1: 
					if Input.is_action_pressed("jump") and is_on_floor() and $SuitTimer.is_stopped():
						temp_jump = SUIT_JUMP
						$SuitTimer.start()
				2:
					if velocity and $SuitTimer.is_stopped():
						$SuitTimer.start()

						velocity.x = direction.x * SUIT_SPEED
						velocity.z = direction.z * SUIT_SPEED
						move_and_slide()
				3:
					if $SuitTimer.is_stopped():
						#print(collision_mask)
						if collision_mask == 5:
							collision_mask = 1
							$PlayerVisual_TEMP.modulate.a = 0.5
							$SuitTimer.start()
							return
						if collision_mask == 1:
							collision_mask = 5
							$PlayerVisual_TEMP.modulate.a = 1
							$SuitTimer.start()
							return
		if Input.is_action_just_pressed("suit_1"):
			suit = 1
			$ColorRect/Label.text = "высокий прыжок"
		if Input.is_action_just_pressed("suit_2"):
			suit = 2
			$ColorRect/Label.text = "рывок"
		if Input.is_action_just_pressed("suit_3"):
			suit = 3
			$ColorRect/Label.text = "прохождение через особые стены"
		if Input.is_action_just_pressed("no_suit"):
			suit = 0
			$ColorRect/Label.text = ""
		# Handle jump.
		if Input.is_action_pressed("jump") and is_on_floor() and !pdb.me_chatting:
			velocity.y = temp_jump

			
		if direction and !pdb.me_chatting:
			# Поворот модели игрока
			$blockbench_export.basis = lerp($blockbench_export.basis, Basis.looking_at(direction), ROTATE_MODEL_SPEED * delta)
			if is_on_floor():
				var acceleration = SPEED * 10.0  # Ускорение (чем больше - тем быстрее)
				velocity.x = move_toward(velocity.x, direction.x * SPEED, acceleration * delta)
				velocity.z = move_toward(velocity.z, direction.z * SPEED, acceleration * delta)
			else:
				# Ограниченное управление в воздухе - можем немного корректировать траекторию
				var air_acceleration = SPEED * 2.0  # Ускорение в воздухе (слабее чем на земле)
				
				# Вычисляем желаемое изменение скорости
				var desired_velocity_x = direction.x * SPEED
				var desired_velocity_z = direction.z * SPEED
				
				# Плавно приближаемся к желаемой скорости, но не мгновенно
				velocity.x = move_toward(velocity.x, desired_velocity_x, air_acceleration * delta)
				velocity.z = move_toward(velocity.z, desired_velocity_z, air_acceleration * delta)
		else:
			if is_on_floor():
				var deceleration = SPEED * 8.0  # Скорость торможения (можно сделать меньше для скольжения)
				velocity.x = move_toward(velocity.x, 0, deceleration * delta)
				velocity.z = move_toward(velocity.z, 0, deceleration * delta)
			else:
				# В воздухе без ввода - сохраняем инерцию
				pass
	else:
		if t < 1.0:
			t += delta / lerp_time
			var progress: float = clampf(t, 0.0, 1.0)
			global_position = prev_pos.lerp(target_pos, progress)
			velocity = prev_velocity_sync.lerp(target_velocity_sync, progress)
			_update_remote_visual_rotation(_lerp_rotation(prev_rot, target_rot, progress))
		else:
			global_position = target_pos
			velocity = target_velocity_sync
			_update_remote_visual_rotation(target_rot)
	move_and_slide()


func _on_position_sync_timeout() -> void:
	position_sync.rpc(global_position, $blockbench_export.rotation, velocity, suit)
	#print("Синхронизация позиции " + name)

@rpc("call_remote", "unreliable")
func position_sync(pose: Vector3, angle: Vector3, velocity: Vector3, suit: int) -> void:
	if is_multiplayer_authority():
		return
	prev_pos = global_position
	target_pos = pose
	prev_rot = $blockbench_export.rotation
	target_rot = angle
	prev_velocity_sync = velocity
	target_velocity_sync = velocity
	_update_remote_suit(suit)
	t = 0.0

	#print("Удаленная синхронизация позиции " + name)

func _lerp_rotation(from: Vector3, to: Vector3, weight: float) -> Vector3:
	var clamped_weight: float = clampf(weight, 0.0, 1.0)
	return Vector3(
		lerp_angle(from.x, to.x, clamped_weight),
		lerp_angle(from.y, to.y, clamped_weight),
		lerp_angle(from.z, to.z, clamped_weight)
	)

func _update_remote_visual_rotation(target: Vector3) -> void:
	$blockbench_export.rotation = target

func _update_remote_suit(new_suit: int) -> void:
	if suit == new_suit:
		return
	suit = new_suit
	match suit:
		1:
			$ColorRect/Label.text = "высокий прыжок"
		2:
			$ColorRect/Label.text = "рывок"
		3:
			$ColorRect/Label.text = "прохождение через особые стены"
		_:
			$ColorRect/Label.text = ""

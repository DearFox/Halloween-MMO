class_name Player
extends Area3D

@export var candy_count: int = 1
@export var is_active: bool = true
@export var respawn_time_sec: float = 10.0
@export var is_rotation: bool = true
@export var rotation_speed_deg: float = 45.0
@export var is_bobbing: bool = true
@export var bobbing_amplitude: float = 0.25
@export var bobbing_speed: float = 1.0


func respawn_candy() -> void:
	is_active = true
	visible = true

func despawn_candy() -> void:
	is_active = false
	visible = false
	# Wait for respawn time
	await get_tree().create_timer(respawn_time_sec).timeout
	respawn_candy()

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	visible = is_active

# Вращение и покачивание не синхронизированы, так как не влияют на геймплей
func _physics_process(delta: float) -> void:
	if is_rotation:
		rotate_y(deg_to_rad(rotation_speed_deg) * delta)
	if is_bobbing:
		var bobbing_offset: float = bobbing_amplitude * sin(GGS.CURRENT_TIME / 1000.0 * bobbing_speed * TAU)
		var new_position: Vector3 = global_position
		new_position.y = bobbing_offset
		global_position = new_position

func _on_body_entered(body):
	if is_active and body is CharacterBody3D and body.is_multiplayer_authority():
		print("Candy collected by: ", body)
		pdb.PlayerCandy += candy_count
		GGS.chat_message_on_client("You collected " + str(candy_count) + " candy!")
		GGS.chat_message_on_client("Собрано " + str(candy_count) + " конфет!")
		print("candy sync: ", pdb.PlayerCandy)
		GGS.sent_candy_count.rpc_id(1,candy_count)

		is_active = false
		await despawn_candy()

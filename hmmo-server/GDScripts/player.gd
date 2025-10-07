extends Node2D

func _enter_tree() -> void:
	name = str(get_multiplayer_authority())

@rpc("call_remote", "unreliable")
@warning_ignore("unused_parameter")
func position_sync(pose:Vector3) -> void:pass

extends Timer


func _on_timeout() -> void:
	sdb.db_save_candy_leaderboard(true)

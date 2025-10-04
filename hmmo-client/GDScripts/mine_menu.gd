extends Control


func _on_join_pressed() -> void:
	GGS.create_client($VBoxMenu/HBoxServer/IP.text)


func _on_button_pressed() -> void:
	GGS.rpc_test()

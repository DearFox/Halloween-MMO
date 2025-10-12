extends Control

var min_pose:Vector2 = Vector2(0.20,0.10) #Представлены в виде процентов записанные в виде float
var max_pose:Vector2 = Vector2(0.90,0.90) #Представлены в виде процентов записанные в виде float

func _ready() -> void:
	$ChatControl/RichTextLabel.scroll_following_visible_characters = false # Нужно что-бы исправить странный визуальный баг

func add_message(ChatMsg: String) -> void:
	$ChatControl/RichTextLabel.append_text("\n"+ChatMsg)

func _on_color_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and event.button_mask == 1:
		var screen_size:Vector2 = get_viewport().size
		var neo_pose:Vector2i = $ColorRect.position + event.position
		if neo_pose.x < (screen_size.x * min_pose.x) or neo_pose.x > (screen_size.x * max_pose.x) or neo_pose.y < (screen_size.y * min_pose.y) or neo_pose.y > (screen_size.y * max_pose.y):
			return
		chat_rich_text_on_down()
		$ColorRect.position = neo_pose
		$ChatControl.size.x = $ColorRect.global_position.x+8
		var size_y:float = screen_size.y-$ColorRect.global_position.y
		$ChatControl.size.y = size_y
		$ChatControl.position.y = screen_size.y-size_y

func chat_rich_text_on_down() -> void:
	if get_node("ChatControl/RichTextLabel/").get_child(0,true) and get_node("ChatControl/RichTextLabel/").get_child(0,true).visible:
		$ChatControl/RichTextLabel.scroll_following_visible_characters = false
		$ChatControl/RichTextLabel.scroll_following_visible_characters = true

func send_message(msg:String):
	if msg and GGS.srv_ok():
		GGS.send_my_chat_message_on_server.rpc_id(1,msg)
		chat_rich_text_on_down()
	if msg and !GGS.srv_ok():
		add_message("< DEMO > : "+msg)

func _on_send_pressed() -> void:
	send_message($ChatControl/HBoxContainer/Message.text)
	$ChatControl/HBoxContainer/Send.release_focus()
	$ChatControl/HBoxContainer/Message.text = ""


func _on_message_text_submitted(new_text: String) -> void:
	$ChatControl/HBoxContainer/Message.release_focus()
	send_message(new_text)
	$ChatControl/HBoxContainer/Message.text = ""


func _on_message_focus_entered() -> void:
	pdb.me_chatting = true



func _on_message_focus_exited() -> void:
	pdb.me_chatting = false

extends Control

var min_pose:Vector2 = Vector2(0.20,0.10) #Представлены в виде процентов записанные в виде float
var max_pose:Vector2 = Vector2(0.90,0.90) #Представлены в виде процентов записанные в виде float


func _on_color_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and event.button_mask == 1:
		var screen_size:Vector2 = get_viewport().size
		var neo_pose:Vector2i = $ColorRect.position + event.position
		if neo_pose.x < (screen_size.x * min_pose.x) or neo_pose.x > (screen_size.x * max_pose.x) or neo_pose.y < (screen_size.y * min_pose.y) or neo_pose.y > (screen_size.y * max_pose.y):
			return
		$ChatControl/RichTextLabel.scroll_following_visible_characters = false
		$ChatControl/RichTextLabel.scroll_following_visible_characters = true
		$ColorRect.position = neo_pose
		$ChatControl.size.x = $ColorRect.global_position.x+8
		var size_y:float = screen_size.y-$ColorRect.global_position.y
		$ChatControl.size.y = size_y
		$ChatControl.position.y = screen_size.y-size_y

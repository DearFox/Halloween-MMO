extends Node3D

@export var BuySuitItn:int = 0
@export var SuitPrice:int = 100
#0 , 1  слизь, 2  демон, 3  призрак.
var SuitsNames:Array = ["Никакой", "Слайма","Демона","Призрака"]

var suit_nodes: Array = ["blockbench_export/Node/Root/Body/Head/ghost_head_mesh","blockbench_export/Node/Root/Body/Head/demon_head_mesh","blockbench_export/Node/Root/Body/Tile/demon_tile_mesh","blockbench_export/Node/Root/Body/demon_body_mesh","blockbench_export/Node/Root/slime_root_mesh"]
# suit_visible - 0 все выключены, 1 только слизь, 2 только демон, 3 только призрак. Основано на иерархии нодов в suit_nodes
var suit_visible: Array = [[false,false,false,false,false],[false,false,false,false,true],[false,true,true,true,false],[true,false,false,false,false]]

func _ready() -> void:
	_update_suit(BuySuitItn)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.is_multiplayer_authority():
		body.shopping = BuySuitItn
		body.shopping_cost = SuitPrice
		print("Игрок вошел в магазин")
		GGS.chat_message_on_client("[color=green][font_size=24]You have entered the store![/font_size][/color]\n[color=green]Click the [color=orange][u]shift[/u][/color] to buy a [color=orange][u]"+ SuitsNames[BuySuitItn] +"[/u][/color] suit.[/color] Price: " + str(SuitPrice) + " candy.")
		GGS.chat_message_on_client("[font_size=14][color=green]Вы зашли в магазин![/color]\n[color=green]Нажмите на [color=orange][u]shift[/u][/color] что-бы купить [color=orange][u]"+ SuitsNames[BuySuitItn] +"[/u][/color] костюм.[/color][/font_size] Цена: " + str(SuitPrice) + " конфет.")


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D and body.is_multiplayer_authority():
		body.shopping = -1
		print("Игрок вышел из магазина")
		GGS.chat_message_on_client("[color=gray]You have left the store[/color]")
		GGS.chat_message_on_client("[font_size=14][color=gray]Вы ушли из магазина[/color][/font_size]")

func _update_suit(new_suit: int) -> void:
	for i in suit_nodes.size():
		get_node(suit_nodes[i]).visible = suit_visible[new_suit][i]

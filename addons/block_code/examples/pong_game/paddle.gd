@tool
class_name Paddle
extends CharacterBody2D


func get_custom_class():
	return "Paddle"


static func get_exposed_properties() -> Array[String]:
	return ["position"]


static func get_custom_blocks() -> Array[Block]:
	var b: Block
	var block_list: Array[Block] = []

	# Movement
	b = CategoryFactory.BLOCKS["statement_block"].instantiate()
	b.block_type = Types.BlockType.EXECUTE
	b.block_format = "Move with player 1 buttons, speed {speed: VECTOR2}"
	b.statement = 'velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")*{speed}\n' + "move_and_slide()"
	b.category = "Movement"
	block_list.append(b)

	b = CategoryFactory.BLOCKS["statement_block"].instantiate()
	b.block_type = Types.BlockType.EXECUTE
	b.block_format = "Move with player 2 buttons, speed {speed: VECTOR2}"
	b.statement = 'velocity = Input.get_vector("player_2_left", "player_2_right", "player_2_up", "player_2_down")*{speed}\n' + "move_and_slide()"
	b.category = "Movement"
	block_list.append(b)

	return block_list

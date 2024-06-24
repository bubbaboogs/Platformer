@tool
class_name BlockCategoryDisplay
extends MarginContainer

signal category_expanded(value: bool)

var category: BlockCategory

@onready var _button := %Button
@onready var _blocks_container := %BlocksContainer
@onready var _blocks := %Blocks
@onready var _background := %Background

const _unexpanded := Rect2(1, 1, 16, 16)
const _expanded := Rect2(20, 1, 16, 16)

var expanded: bool = false:
	set(value):
		_blocks_container.visible = value
		_button.icon.region = _expanded if value else _unexpanded
		category_expanded.emit(value)


func _ready():
	if category:
		_button.text = category.name
		_background.color = category.color.darkened(0.7)
		_background.color.a = 0.3

		for _block in category.block_list:
			var block: Block = _block as Block

			block.color = category.color

			_blocks.add_child(block)


func _on_button_toggled(toggled_on):
	expanded = toggled_on

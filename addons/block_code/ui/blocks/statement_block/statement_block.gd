@tool
class_name StatementBlock
extends Block

@export var block_format: String = ""
@export var statement: String = ""
@export var defaults: Dictionary = {}

@onready var _background := %Background
@onready var _hbox := %HBoxContainer

var param_name_input_pairs: Array
var param_input_strings: Dictionary  # Only loaded from serialized


func _ready():
	super()

	if block_type != Types.BlockType.EXECUTE:
		_background.show_top = false
	_background.color = color

	format()

	if param_input_strings:
		for pair in param_name_input_pairs:
			pair[1].set_raw_input(param_input_strings[pair[0]])


func _on_drag_drop_area_mouse_down():
	_drag_started()


func get_serialized_props() -> Array:
	var props := super()
	props.append_array(serialize_props(["block_format", "statement", "defaults"]))

	var _param_input_strings: Dictionary = {}
	for pair in param_name_input_pairs:
		_param_input_strings[pair[0]] = pair[1].get_raw_input()

	props.append(["param_input_strings", _param_input_strings])
	return props


static func get_block_class():
	return "StatementBlock"


static func get_scene_path():
	return "res://addons/block_code/ui/blocks/statement_block/statement_block.tscn"


# Override this method to create custom block functionality
func get_instruction_node() -> InstructionTree.TreeNode:
	var formatted_statement := statement

	for pair in param_name_input_pairs:
		formatted_statement = formatted_statement.replace("{%s}" % pair[0], pair[1].get_string())

	var statement_lines := formatted_statement.split("\n")

	var root: InstructionTree.TreeNode = InstructionTree.TreeNode.new(statement_lines[0])
	var node := root

	for i in range(1, statement_lines.size()):
		node.next = InstructionTree.TreeNode.new(statement_lines[i])
		node = node.next

	if bottom_snap:
		var snapped_block: Block = bottom_snap.get_snapped_block()
		if snapped_block:
			node.next = snapped_block.get_instruction_node()

	return root


func format():
	param_name_input_pairs = format_string(self, %HBoxContainer, block_format, defaults)


static func format_string(parent_block: Block, attach_to: Node, string: String, _defaults: Dictionary) -> Array:
	var _param_name_input_pairs = []
	var regex = RegEx.new()
	regex.compile("\\[([^\\]]+)\\]|\\{([^}]+)\\}")  # Capture things of format {test} or [test]
	var results := regex.search_all(string)

	var start: int = 0
	for result in results:
		var label_text := string.substr(start, result.get_start() - start)
		if label_text != "":
			var label = Label.new()
			label.add_theme_color_override("font_color", Color.WHITE)
			label.text = label_text
			attach_to.add_child(label)

		var param := result.get_string()
		var copy_block: bool = param[0] == "["
		param = param.substr(1, param.length() - 2)

		var split := param.split(": ")
		var param_name := split[0]
		var param_type_str := split[1]

		var param_type = null
		var option := false
		if param_type_str == "OPTION":  # Easy way to specify dropdown option
			option = true
		else:
			param_type = Types.STRING_TO_VARIANT_TYPE[param_type_str]

		var param_default = null
		if _defaults.has(param_name):
			param_default = _defaults[param_name]

		var param_input: ParameterInput = preload("res://addons/block_code/ui/blocks/utilities/parameter_input/parameter_input.tscn").instantiate()
		param_input.name = "ParameterInput%d" % start  # Unique path
		param_input.placeholder = param_name
		if param_type != null:
			param_input.variant_type = param_type
		elif option:
			param_input.option = true
		param_input.block = parent_block
		param_input.modified.connect(func(): parent_block.modified.emit())

		attach_to.add_child(param_input)
		if param_default:
			param_input.set_raw_input(param_default)

		_param_name_input_pairs.append([param_name, param_input])

		if copy_block:
			var new_block: Block = preload("res://addons/block_code/ui/blocks/parameter_block/parameter_block.tscn").instantiate()
			new_block.block_format = param_name
			new_block.statement = param_name
			new_block.variant_type = param_type
			new_block.color = parent_block.color
			param_input.block_type = Types.BlockType.NONE
			param_input.snap_point.block_type = Types.BlockType.NONE  # Necessary because already called ready
			param_input.snap_point.add_child(new_block)

		start = result.get_end()

	var label_text := string.substr(start)
	if label_text != "":
		var label = Label.new()
		label.add_theme_color_override("font_color", Color.WHITE)
		label.text = label_text
		attach_to.add_child(label)

	return _param_name_input_pairs

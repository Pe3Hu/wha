extends MarginContainer


#region vars
@onready var bg = $BG
@onready var designation = $Designation
@onready var limit = $Numbers/HBox/Limit

var proprietor = null
var type = null
var subtype = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	proprietor = input_.proprietor
	type = input_.type
	subtype = input_.subtype
	
	init_basic_setting(input_)


func init_basic_setting(input_: Dictionary) -> void:
	var input = {}
	input.type = type
	input.subtype = subtype
	designation.set_attributes(input)
	designation.custom_minimum_size = Vector2(Global.vec.size.token)
	
	input.type = "number"
	input.subtype = 1
	
	if input_.has("limit"):
		input.subtype = input_.limit
	
	limit.set_attributes(input)
	limit.custom_minimum_size = Vector2()
	
	match type:
		"element":
			init_bg()
			set_bg_color(Global.color.element[subtype])




func init_bg() -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color.SLATE_GRAY
	bg.set("theme_override_styles/panel", style)


func set_bg_color(color_: Color) -> void:
	var style = bg.get("theme_override_styles/panel")
	style.bg_color = color_
#endregion


#region limit treatment
func get_limit() -> int:
	return limit.get_number()


func change_limit(value_: int) -> void:
	limit.change_number(value_)


func set_limit(value_: int) -> void:
	limit.set_number(value_)
#endregion

extends MarginContainer


#region vars
@onready var workshop = $HBox/Workshop

var guild = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	guild = input_.guild
	
	init_basic_setting()


func init_basic_setting() -> void:
	var input = {}
	input.colletor = self
	workshop.set_attributes(input)
#endregion



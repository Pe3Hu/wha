extends MarginContainer


#region vars
@onready var tokens = $Tokens

var colletor = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	colletor = input_.colletor
	
	init_basic_setting()


func init_basic_setting() -> void:
	init_tokens()


func init_tokens() -> void:
	for element in Global.arr.element:
		var input = {}
		input.proprietor = self
		input.type = "element"
		input.subtype = element
		
		var token = Global.scene.token.instantiate()
		tokens.add_child(token)
		token.set_attributes(input)
#endregion

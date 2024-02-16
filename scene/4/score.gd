extends MarginContainer


#region vars
@onready var bg = $BG
@onready var tokens = $Tokens

var proprietor = null
var type = null
var subtype = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	proprietor = input_.proprietor
	type = input_.type
	subtype = input_.subtype
	
	init_basic_setting()


func init_basic_setting() -> void:
	init_tokens()


func init_tokens() -> void:
	var subtypes = null
	
	match type:
		"workshop":
			subtypes = ["supply", "demand"]
		"exhibit":
			subtypes = ["input", "utilization", "output", "total"]
	
	for _subtype in subtypes:
		var input = {}
		input.proprietor = self
		input.type = "score"
		input.subtype = _subtype
		
		var token = Global.scene.token.instantiate()
		tokens.add_child(token)
		token.set_attributes(input)
		
		token.bg.visible = false
		token.limit.set("size_flags_horizontal", SIZE_SHRINK_CENTER)
		token.limit.set("size_flags_vertical", SIZE_SHRINK_CENTER)
		token.designation.set("size_flags_horizontal", SIZE_EXPAND_FILL)
		token.designation.set("size_flags_vertical", SIZE_EXPAND_FILL)
		
		token.custom_minimum_size = Vector2(Global.vec.size.score)
		token.designation.custom_minimum_size = Vector2(Global.vec.size.score)
		token.limit.custom_minimum_size = Vector2(Global.vec.size.score)
		token.size = Vector2(Global.vec.size.score)
		token.designation.size = Vector2(Global.vec.size.score)
		token.limit.size = Vector2(Global.vec.size.score)


func get_token_based_on_subtype(subtype_: String) -> Variant:
	for token in tokens.get_children():
		if token.subtype == subtype_:
			return token
	
	return null
#endregion

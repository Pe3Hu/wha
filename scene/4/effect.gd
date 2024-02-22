extends "res://scene/3/token.gd"


#region vars
var count = null
#endregion


func _ready() -> void:
	var input = {}
	input.type = "number"
	input.subtype = 0
	
	count = Global.scene.icon.instantiate()
	add_child(count)
	count.set_attributes(input)
	count.set("size_flags_horizontal", SIZE_SHRINK_END)
	count.set("size_flags_vertical", SIZE_SHRINK_END)
	count.custom_minimum_size = Vector2(Global.vec.size.limit)


#region count treatment
func get_count() -> Variant:
	return count.get_number()


func change_count(value_: Variant) -> void:
	count.change_number(value_)


func set_count(value_: Variant) -> void:
	count.set_number(value_)
#endregion


func identical_check(token_: MarginContainer) -> bool:
	var flag = true
	var keys = ["type", "subtype", "limit"]
	
	for key in keys:
		var _vars = {}
		
		_vars.self = get(key)
		_vars.other = token_.get(key)
		
		if key == "limit":
			_vars.self = _vars.self.get_number()
			_vars.other = _vars.other.get_number()
		
		print(_vars)
		if _vars.other != _vars.self:
			return false
	
	return true
	

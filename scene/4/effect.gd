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

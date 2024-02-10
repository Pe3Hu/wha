extends "res://scene/3/token.gd"


#region vars
var current = null
#endregion


func _ready() -> void:
	#custom_minimum_size = Vector2(Global.vec.size.occupancy)
	
	var input = {}
	input.type = "number"
	input.subtype = 0
	
	current = Global.scene.icon.instantiate()
	add_child(current)
	current.set_attributes(input)
	current.set("size_flags_horizontal", SIZE_SHRINK_BEGIN)
	current.set("size_flags_vertical", SIZE_SHRINK_BEGIN)
	current.custom_minimum_size = Vector2(Global.vec.size.limit)
